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
#import "Credentials.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wreserved-id-macro"
#pragma clang diagnostic ignored "-Wpedantic"
#pragma clang diagnostic ignored "-Wquoted-include-in-framework-header"
#import <git2.h>
#pragma clang diagnostic pop

int GKCredentialsHelperCallback( git_cred ** cred, const char * url, const char * usernameFromURL, unsigned int allowedTypes, void * payload )
{
    NSString * username;
    NSString * password;
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
    
    id< GKRepositoryDelegate > delegate    = ( __bridge id< GKRepositoryDelegate > )payload;
    GKCredentials            * credentials = [ delegate authenticationForURL: remoteURL ];
    
    if( credentials != nil )
    {
        username = credentials.username;
        password = credentials.password;
    }
    else
    {
        username = @"";
        password = @"";
    }
    
    if( git_cred_userpass_plaintext_new( cred, username.UTF8String, password.UTF8String ) == 0 )
    {
        return 0;
    }
    else
    {
        #ifdef DEBUG
        
        const git_error * error = git_error_last();
        
        NSLog( @"Error creating plaintext credentials: %s", error->message );
        
        #endif
        
        return -1;
    }
}
