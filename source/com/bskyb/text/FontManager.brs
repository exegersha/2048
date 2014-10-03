'' FontManager.brs


' Singleton instance of fontManager - wraps roku fonts
Function FontManager() As Object
    
    if(m.fontManagerInstance = invalid)
    
        this = {}
            
        ' VARS
        this.fontList = {} ' add all fonts to here
        this.fonts = createobject("rofontregistry")
            
        ' METHODS
        ' register a font from a path (i.e. ttf or otf file)
        this.register = function(fontPath as String)
            m.fonts.register(fontPath)
        end function
        
        ' returns font of specified attributes. If not found, returns the default font  
        ' When a font is first retrieved, we create it once and insert it into a lookup table
        ' This speeds up the font retrieval process significantly.      
        this.getFont = function( fontName as String, size as Integer, bold=false as Boolean, italics=false as Boolean ) as Object
            
            fontID = fontName + size.toStr() + BoolToStr(bold) + BoolToStr(italics)
            lookup = m.fontList.Lookup(fontID)
            if(lookup <> invalid)
                ' font has already been requested before. Return it
                return lookup
            else
                ' create and add the new font
                font = m.fonts.getFont( fontName, size, bold, italics )
                
                if(font = invalid)
                    ' font is not in font registry, return default font     
                    font = m.fonts.getDefaultFont(size, bold, italics)
                else
                    m.fontList.AddReplace(fontID, font)
                end if
                
                return font
            end if
            
        end function
        
        ' removes font - removing the refernce to the font will free up video mem
        this.removeFont = function( fontName as String, size as Integer, bold=false as Boolean, italics=false as Boolean )
            fontID = fontName + size.toStr() + BoolToStr(bold) + BoolToStr(italics)
            lookup = m.fontList.Lookup(fontID)
            if(lookup <> invalid)
                ' font found, remove it from fontList
                m.fontList.Delete(fontID)
            end if
        end function
        
        ' returns default font
        this.getDefaultFont = function( size=21 as Integer, bold=false as Boolean, italics=false as Boolean) as Object
            return m.fonts.getDefaultFont(size, bold, italics)
        end function
        
        m.fontManagerInstance = this
    end if
    
    return m.fontManagerInstance
    
End Function
