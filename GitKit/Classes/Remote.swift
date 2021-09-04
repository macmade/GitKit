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

public class Remote
{
    public                     let name:       String
    public                     let url:        URL
    private                    let remote:     OpaquePointer
    public private( set ) weak var repository: Repository?
    
    public init( repository: Repository, remote: OpaquePointer ) throws
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
    public func fetch( refspecs: [ String ], reflogMessage: String ) -> Bool
    {
        var options = git_fetch_options()
        let array   = StringArray( strings: refspecs )
        
        git_fetch_options_init( &options, UInt32( GIT_FETCH_OPTIONS_VERSION ) )
        
        options.callbacks.credentials = nil
        
        var strarray = array.array
        let status   = git_remote_fetch( self.remote, &strarray, &options, reflogMessage.cString( using: .utf8 ) )
        
        return status == 0
    }
}
