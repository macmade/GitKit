/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation
import libgit2

public class Branch: Equatable
{
    public                     let name:       String
    private                    let ref:        OpaquePointer
    public private( set )      var lastCommit: Commit?
    public private( set ) weak var repository: Repository?
    
    public static func == ( lhs: Branch, rhs: Branch ) -> Bool
    {
        lhs.repository == rhs.repository && lhs.name == rhs.name
    }
    
    public init( repository: Repository, ref: OpaquePointer ) throws
    {
        var name: UnsafePointer< CChar >!
        
        if git_branch_name( &name, ref ) != 0 || name == nil
        {
            throw Error( "Cannot retrieve branch name: \( repository.url.path )" )
        }
        
        self.repository = repository
        self.ref        = ref
        self.name       = String( cString: name )
        
        var oid = git_reference_target( ref )
        
        if oid == nil
        {
            var commitRef: OpaquePointer!
            
            if git_reference_resolve( &commitRef, ref ) == 0, let commitRef = commitRef
            {
                oid = git_reference_target( commitRef )
            }
        }
        
        if let oid = oid
        {
            self.lastCommit = try? Commit( repository: repository, oid: oid, ref: nil )
        }
    }
    
    deinit
    {
        git_reference_free( self.ref )
    }
    
    public func graph( with branch: Branch ) -> ( ahead: Int, behind: Int )?
    {
        var oid1 = git_reference_target( self.ref )
        var oid2 = git_reference_target( branch.ref )
        
        if oid1 == nil
        {
            var ref: OpaquePointer!
            
            if git_reference_resolve( &ref, self.ref ) != 0 || ref == nil
            {
                return nil
            }
            
            oid1 = git_reference_target( ref )
        }
        
        if oid2 == nil
        {
            var ref: OpaquePointer!
            
            if git_reference_resolve( &ref, self.ref ) != 0 || ref == nil
            {
                return nil
            }
            
            oid2 = git_reference_target( ref )
        }
        
        guard let oid1 = oid1, let oid2 = oid2 else
        {
            return nil
        }
        
        var ahead:  Int = 0
        var behind: Int = 0
        
        if git_graph_ahead_behind( &ahead, &behind, self.repository?.repository, oid1, oid2 ) == 0
        {
            return ( ahead: ahead, behind: behind )
        }
        
        return nil
    }
}
