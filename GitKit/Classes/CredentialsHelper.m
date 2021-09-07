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

#import "CredentialsHelper.h"
#import "RepositoryDelegate.h"
#import "HTTPCredentials.h"
#import "SSHCredentials.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wreserved-id-macro"
#pragma clang diagnostic ignored "-Wpedantic"
#pragma clang diagnostic ignored "-Wquoted-include-in-framework-header"
#import <git2.h>
#pragma clang diagnostic pop

int GKCredentialsHelperCallback( git_cred ** cred, const char * url, const char * usernameFromURL, unsigned int allowedTypes, void * payload )
{
    NSString * urlString;
    NSURL    * remoteURL;
    
    ( void )usernameFromURL;
    ( void )allowedTypes;
    
    *( cred ) = NULL;
    urlString = [ NSString stringWithCString: url encoding: NSUTF8StringEncoding ];
    
    if( urlString == nil )
    {
        return -1;
    }
    
    remoteURL = [ NSURL URLWithString: urlString ];
    
    if( remoteURL == nil )
    {
        return -1;
    }
    
    id< GKRepositoryDelegate > delegate = ( __bridge id< GKRepositoryDelegate > )payload;
    
    if( [ remoteURL.scheme.lowercaseString isEqualToString: @"http" ] || [ remoteURL.scheme.lowercaseString isEqualToString: @"https" ] )
    {
        GKHTTPCredentials * credentials = [ delegate HTTPAuthenticationForURL: remoteURL ];
        
        if( credentials == nil )
        {
            return git_cred_userpass_plaintext_new( cred, "", "" );
        }
        
        return git_cred_userpass_plaintext_new
        (
            cred,
            credentials.username.UTF8String,
            credentials.password.UTF8String
        );
    }
    else
    {
        GKSSHCredentials * credentials = [ delegate SSHAuthenticationForURL: remoteURL ];
        
        if( credentials == nil )
        {
            return -1;
        }
        
        return git_cred_ssh_key_new
        (
            cred,
            usernameFromURL,
            credentials.publicKey.path.UTF8String,
            credentials.privateKey.path.UTF8String,
            credentials.password.UTF8String
        );
    }
}
