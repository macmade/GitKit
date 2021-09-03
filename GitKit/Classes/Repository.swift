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

public class Repository
{
    public                let url:        URL
    public private( set ) var branches:   [ Branch ] = []
    public private( set ) var remotes:    [ Remote ] = []
    private               var repository: OpaquePointer!
    
    public convenience init( path: String ) throws
    {
        try self.init( url: URL( fileURLWithPath: path ) )
    }
    
    public init( url: URL ) throws
    {
        var repository: OpaquePointer!
        var it:         OpaquePointer!
        var ref:        OpaquePointer!
        var type:       git_branch_t!
        
        git_libgit2_init()
        
        if git_repository_open( &repository, nil ) != 0 || repository == nil
        {
            throw Error( "Cannot open repository: \( url.path )" )
        }
        
        if git_branch_iterator_new( &it, self.repository, GIT_BRANCH_ALL ) != 0 || it == nil
        {
            throw Error( "Cannot iterate branches: \( url.path )" )
        }
        
        defer
        {
            git_branch_iterator_free( it )
        }
        
        self.url        = url
        self.repository = repository
        
        while git_branch_next( &ref, &type, it ) == 0
        {
            if let ref = ref
            {
                self.branches.append( try Branch( repository: self, ref: ref ) )
            }
        }
        
        var names = git_strarray()
        
        if git_remote_list( &names , repository ) == 0
        {
            for i in 0 ..< names.count
            {
                var remote: OpaquePointer!
                
                if git_remote_lookup( &remote, repository, names.strings[ i ] ) != 0 || remote == nil
                {
                    throw Error( "Cannot lookup remote: \( url.path )" )
                }
                
                self.remotes.append( try Remote( repository: self, remote: remote ) )
            }
        }
    }
    
    deinit
    {
        self.branches.forEach { git_reference_free( $0.ref ) }
        self.remotes.forEach  { git_remote_free( $0.remote ) }
        
        git_repository_free( self.repository )
    }
}
