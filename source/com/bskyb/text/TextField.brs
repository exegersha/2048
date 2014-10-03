'' TextField.brs


function TextField(id="" as String) as Object
    
    'print "new TextField"
    'this = DisplayObject(id)
    this = InteractiveObject(id)
    
    ' STATIC PROPERTIES
    this.TOSTRING = "<TextField>"
    
    ' PROPERTIES
    this.text = ""
    this.renderedText = ""
    this.colour = &hFF ' black by default
    this.font = FontManager().getDefaultFont()
    this.password = false
    
    ' "PRIVATE" METHODS
    
    ' METHODS
    this.render = function()
        if(m.font <> invalid AND m.screen <> invalid)
            'print m.text ; m.x ; m.y
            m.screen.drawText(m.renderedText, m.globalX, m.globalY, m.colour, m.font)
        end if
    end function
    
    ' Use setFont to ensure height of text is set
    this.setFont = function(font as Object)
        m.font = font
        m.height = m.font.GetOneLineHeight()
    end function
    
    ' using setText ensures width of text are set
    this.setText = function(text as String)
        m.text = text
        m.renderedText = text
        
        ' Re-apply password text
        if (m.password)
            m.setPassword(m.password)
        end if
        
        if (m.font <> invalid)
            m.width = m.font.GetOneLineWidth(text, 99999)
            m.height = m.font.GetOneLineHeight()
        end if
    end function
    
    this.getText = function() as String
        return m.text
    end function
    
    this.setPassword = function(value as Boolean)
        m.password = value        
        if (value)
            m.renderedText = StringToPassword(m.getText())
        else
            m.renderedText = m.getText()
        end if
    end function
    
    this.getPassword = function() as Boolean
        return m.password
    end function
    
    this.dispose = function()
        m.font = invalid
    end function
    
    return this
    
end function