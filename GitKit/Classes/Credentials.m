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

#import "Credentials.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wreserved-id-macro"
#pragma clang diagnostic ignored "-Wpedantic"
#pragma clang diagnostic ignored "-Wquoted-include-in-framework-header"
#import <git2.h>
#pragma clang diagnostic pop

int GitKit_Credentials( git_cred ** cred, const char * url, const char * usernameFromURL, unsigned int allowedTypes, void * payload )
{
    *( cred ) = NULL;
    
    ( void )cred;
    ( void )url;
    ( void )usernameFromURL;
    ( void )allowedTypes;
    ( void )payload;
    
    return 0;
    /*
    Utility::Credentials c;
    std::string          user;
    std::string          password;
    
    if( c.retrieve( Utility::Arguments::sharedInstance().keychainItem(), user, password ) )
    {
        if( git_cred_userpass_plaintext_new( cred, user.c_str(), password.c_str() ) == 0 )
        {
            return 0;
        }
        
        *( cred ) = nullptr;
    }
    */
}
/*
        {
            SecKeychainRef          keychain( nullptr );
            CFStringRef             itemName;
            CFMutableDictionaryRef  query;
            SecKeychainItemRef      item( nullptr );
            std::string             u;
            std::string             p;
            
            if( SecKeychainCopyDefault( &keychain ) != errSecSuccess || keychain == nullptr )
            {
                return false;
            }
            
            if( SecKeychainUnlock( keychain, 0, nullptr, false ) != errSecSuccess )
            {
                CFRelease( keychain );
                
                return false;
            }
            
            itemName = CFStringCreateWithCString( nullptr, name.c_str(), kCFStringEncodingUTF8 );
            query    = CFDictionaryCreateMutable( nullptr, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
            
            CFDictionarySetValue( query, kSecMatchLimit, kSecMatchLimitOne );
            CFDictionarySetValue( query, kSecClass, kSecClassGenericPassword );
            CFDictionarySetValue( query, kSecAttrLabel, itemName );
            
            if( SecItemCopyMatching( query, static_cast< CFTypeRef * >( const_cast< const void ** >( reinterpret_cast< void ** >( &item ) ) ) ) == errSecSuccess && item != nullptr )
            {
                do
                {
                    {
                        SecKeychainAttributeInfo * info( nullptr );
                        SecKeychainAttributeList * list;
                        UInt32                     length;
                        void                     * data;
                        
                        if( item == nullptr || CFGetTypeID( item ) != SecKeychainItemGetTypeID() )
                        {
                            break;
                        }
                        
                        if( SecKeychainAttributeInfoForItemID( keychain, CSSM_DL_DB_RECORD_GENERIC_PASSWORD, &info ) != errSecSuccess || info == nullptr )
                        {
                            break;
                        }
                        
                        if( SecKeychainItemCopyAttributesAndData( item, info, NULL, &list, &length, &data ) != errSecSuccess )
                        {
                            break;
                        }
                        
                        for( UInt32 i = 0; i < list->count; i++ )
                        {
                            if( list->attr[ i ].tag == kSecAccountItemAttr )
                            {
                                u = std::string( static_cast< const char * >( list->attr[ i ].data ), list->attr[ i ].length );
                            }
                        }
                        
                        p = std::string( static_cast< const char * >( data ), length );
                        
                        SecKeychainItemFreeAttributesAndData( list, data );
                    }
                }
                while( 0 );
            }
            
            if( item != nullptr )
            {
                CFRelease( item );
            }
            
            CFRelease( query );
            CFRelease( itemName );
            CFRelease( keychain );
            
            if( u.length() > 0 && p.length() > 0 )
            {
                user     = u;
                password = p;
                
                return true;
            }
            
            return false;
        }
        
        #else
        
        return false;
        
        #endif
    }
*/
