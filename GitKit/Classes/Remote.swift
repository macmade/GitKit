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

@objc public class Remote: NSObject
{
    @objc public private( set ) dynamic      var name:       String
    @objc public private( set ) dynamic      var url:        URL
    @objc public private( set ) dynamic weak var repository: Repository?
    
    private var remote: OpaquePointer
    
    @objc public init( repository: Repository, remote: OpaquePointer ) throws
    {
        guard let name = git_remote_name( remote ) else
        {
            throw Error( "Cannot get remote name: \( repository.url.path )" )
        }
        
        guard let urlstr = git_remote_url( remote ) else
        {
            throw Error( "Cannot get remote url: \( repository.url.path )" )
        }
        
        guard let url = URL( string: String( cString: urlstr ) ) else
        {
            throw Error( "Invalid remote URL: \( urlstr )" )
        }
        
        self.name       = String( cString: name )
        self.url        = url
        self.repository = repository
        self.remote     = remote
    }
    
    deinit
    {
        git_remote_free( self.remote )
    }
    
    @discardableResult
    @objc public func fetch() -> Bool
    {
        var options = git_fetch_options()
        
        git_fetch_options_init( &options, UInt32( GIT_FETCH_OPTIONS_VERSION ) )
        
        options.callbacks.credentials = GKCredentialsHelperCallback
        
        if let delegate = self.repository?.delegate
        {
            let payload               = Unmanaged.passUnretained( delegate )
            options.callbacks.payload = payload.toOpaque()
        }
        
        let status = git_remote_fetch( self.remote, nil, &options, nil )
        
        #if DEBUG
        if status != 0
        {
            if let error = git_error_last()
            {
                let message = String( cString: error.pointee.message )
                
                print( "Failed to fetch \( self.name ) in \( self.repository?.url.path ?? "<nil>" ): \( message )" )
            }
            else
            {
                print( "Failed to fetch \( self.name ) in \( self.repository?.url.path ?? "<nil>" )" )
            }
        }
        #endif
        
        return status == 0
    }
    
    public override func isEqual( _ object: Any?) -> Bool
    {
        guard let object = object as? Remote else
        {
            return false
        }
        
        return self.repository == object.repository && self.url == object.url
    }
    
    public override func isEqual( to object: Any? ) -> Bool
    {
        self.isEqual( object )
    }
}
