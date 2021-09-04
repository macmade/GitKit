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

public class Repository: Equatable
{
    
    public                let url:        URL
    public private( set ) var branches:   [ Branch ] = []
    public private( set ) var remotes:    [ Remote ] = []
    public private( set ) var head:       Either< Branch, Commit >?
    internal              var repository: OpaquePointer!
    
    public static func == ( lhs: Repository, rhs: Repository ) -> Bool
    {
        lhs.url == rhs.url
    }
    
    public convenience init( path: String ) throws
    {
        try self.init( url: URL( fileURLWithPath: path ) )
    }
    
    public init( url: URL ) throws
    {
        var repository: OpaquePointer!
        
        git_libgit2_init()
        
        if git_repository_open( &repository, url.path.cString( using: .utf8 ) ) != 0 || repository == nil
        {
            throw Error( "Cannot open repository: \( url.path )" )
        }
        
        self.url        = url
        self.repository = repository
        
        self.update()
    }
    
    deinit
    {
        git_repository_free( self.repository )
    }
    
    public func update()
    {
        try? self.updateBranches()
        try? self.updateRemotes()
        try? self.updateHead()
    }
    
    private func updateBranches() throws
    {
        self.branches.removeAll()
        
        var it: OpaquePointer!
        
        if git_branch_iterator_new( &it, repository, GIT_BRANCH_ALL ) != 0 || it == nil
        {
            throw Error( "Cannot iterate branches: \( url.path )" )
        }
        
        defer
        {
            git_branch_iterator_free( it )
        }
        
        var ref:   OpaquePointer!
        var type = git_branch_t( 0 )
        
        while git_branch_next( &ref, &type, it ) == 0
        {
            if let ref = ref
            {
                self.branches.append( try Branch( repository: self, ref: ref ) )
            }
        }
    }
    
    private func updateRemotes() throws
    {
        self.remotes.removeAll()
        
        var names = git_strarray()
        
        if git_remote_list( &names, repository ) == 0
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
    
    private func updateHead() throws
    {
        self.head = nil
        
        var head: OpaquePointer!
        
        if git_repository_head( &head, repository ) != 0 || head == nil
        {
            throw Error( "Cannot get head: \( url.path )" )
        }
        
        if let branch = try? Branch( repository: self, ref: head )
        {
            self.head = .first( branch )
        }
        else if let commit = try? Commit( repository: self, ref: head )
        {
            self.head = .second( commit )
        }
    }
    
    public func isDirty() -> Bool
    {
        var list:     OpaquePointer!
        var options = git_status_options()
        
        git_status_options_init( &options, UInt32( GIT_STATUS_OPTIONS_VERSION ) )
        
        if git_status_list_new( &list, repository, &options ) == 0, let list = list
        {
            defer
            {
                git_status_list_free( list )
            }
            
            for i in 0 ..< git_status_list_entrycount( list )
            {
                guard let entry = git_status_byindex( list, i ) else
                {
                    continue
                }
                
                if entry.pointee.status.rawValue != 0
                {
                    return true
                }
            }
        }
        
        return false
    }
}
