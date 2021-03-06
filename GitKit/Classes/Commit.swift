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

@objc public class Commit: NSObject
{
    @objc public private( set ) dynamic weak var repository: Repository?
    @objc public private( set ) dynamic      var commitHash: String
    @objc public private( set ) dynamic      var body:       String?
    @objc public private( set ) dynamic      var message:    String?
    @objc public private( set ) dynamic      var summary:    String?
    @objc public private( set ) dynamic      var date:       Date
    @objc public private( set ) dynamic      var author:     Signature
    @objc public private( set ) dynamic      var committer:  Signature
    
    private var commit: OpaquePointer
    private var ref:    OpaquePointer?
    private var oid:    UnsafePointer< git_oid >
    
    @objc public convenience init( repository: Repository, ref: OpaquePointer ) throws
    {
        guard let oid = git_reference_target( ref ) else
        {
            throw Error( "Cannot get reference target: \( repository.url.path )" );
        }
        
        try self.init( repository: repository, oid: oid, ref: ref )
    }
    
    @objc public init( repository: Repository, oid: UnsafePointer< git_oid >, ref: OpaquePointer? ) throws
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
        
        guard let author = git_commit_author( commit ) else
        {
            throw Error( "Cannot get commit author: \( repository.url.path )" );
        }
        
        guard let committer = git_commit_committer( commit ) else
        {
            throw Error( "Cannot get commit committer: \( repository.url.path )" );
        }
        
        if let body = git_commit_body( commit )
        {
            self.body = String( cString: body )
        }
        
        if let message = git_commit_message( commit )
        {
            self.message = String( cString: message )
        }
        
        if let summary = git_commit_message( commit )
        {
            self.summary = String( cString: summary )
        }
        
        self.oid        = oid
        self.commit     = commit
        self.repository = repository
        self.ref        = ref
        self.commitHash = String( cString: hash )
        self.date       = Date( timeIntervalSince1970: TimeInterval( git_commit_time( commit ) ) )
        self.author     = Signature( signature: author )
        self.committer  = Signature( signature: committer )
    }
    
    deinit
    {
        if let ref = self.ref
        {
            git_reference_free( ref )
        }
        
        git_commit_free( self.commit )
    }
    
    public override func isEqual( _ object: Any?) -> Bool
    {
        guard let object = object as? Commit else
        {
            return false
        }
        
        return self.repository == object.repository && self.commitHash == object.commitHash
    }
    
    public override func isEqual( to object: Any? ) -> Bool
    {
        self.isEqual( object )
    }
}
