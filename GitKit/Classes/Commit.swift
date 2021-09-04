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

public class Commit
{
    public private( set ) weak var repository: Repository?
    private                    let commit:     OpaquePointer
    private                    let ref:        OpaquePointer?
    private                    let oid:        UnsafePointer< git_oid >
    public                     let hash:       String
    
    public convenience init( repository: Repository, ref: OpaquePointer ) throws
    {
        guard let oid = git_reference_target( ref ) else
        {
            throw Error( "Cannot get reference target: \( repository.url.path )" );
        }
        
        try self.init( repository: repository, oid: oid, ref: ref )
    }
    
    public init( repository: Repository, oid: UnsafePointer< git_oid >, ref: OpaquePointer? ) throws
    {
        var commit: OpaquePointer!
        
        if git_commit_lookup( &commit, repository.repository, oid ) != 0 || commit == nil
        {
            throw Error( "Cannot lookup commit: \( repository.url.path )" );
        }
        
        let hashLength = Int( GIT_OID_HEXSZ ) + 1
        let hash       = UnsafeMutablePointer< CChar >.allocate( capacity: hashLength )
        
        defer { hash.deallocate() }
        
        hash.initialize( repeating: 0, count: hashLength )
        
        if git_oid_tostr( hash, Int( GIT_OID_HEXSZ ) + 1, oid ) == nil
        {
            throw Error( "Cannot get commit hash: \( repository.url.path )" );
        }
        
        self.oid        = oid
        self.commit     = commit
        self.repository = repository
        self.ref        = ref
        self.hash       = String( cString: hash )
    }
    
    deinit
    {
        if let ref = self.ref
        {
            git_reference_free( ref )
        }
        
        git_commit_free( self.commit )
    }
}
