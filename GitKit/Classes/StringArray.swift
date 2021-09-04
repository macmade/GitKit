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

public class StringArray
{
    public private( set ) var strings = [ String? ]()
    public private( set ) var array   = git_strarray()
    
    private var ownsMemory = false
    
    public init( strings: [ String ] )
    {
        self.strings     = strings
        self.array.count = strings.count
        self.ownsMemory  = true
        
        if strings.count == 0
        {
            self.array.strings = nil
        }
        else
        {
            self.array.strings = UnsafeMutablePointer< UnsafeMutablePointer< CChar >? >.allocate( capacity: strings.count )
            
            for i in 0 ..< strings.count
            {
                let s = strings[ i ]
                
                guard let cstr = s.cString( using: .utf8 ) else
                {
                    array.strings[ i ] = nil
                    
                    continue
                }
                
                array.strings[ i ] = UnsafeMutablePointer< CChar >.allocate( capacity: s.count + 1 )
                
                array.strings[ i ]?.initialize( from: cstr, count: s.count )
            }
        }
    }
    
    public init( array: git_strarray )
    {
        for i in 0 ..< array.count
        {
            if let p = array.strings[ i ]
            {
                strings.append( String( cString: p ) )
            }
            else
            {
                strings.append( nil )
            }
        }
    }
    
    deinit
    {
        if self.ownsMemory
        {
            for i in 0 ..< self.array.count
            {
                self.array.strings[ i ]?.deallocate()
            }
            
            self.array.strings?.deallocate()
        }
    }
}
