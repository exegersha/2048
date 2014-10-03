'' TextFieldMulti.brs


' Displays multiple text fields in a line, adjusting their X positions to look like a single sentence 
' on the display. Set the default field information on construction and then change individual fields 
' after that.
'
' Fields can have completely different sizes, bold states, fonts, colours etc. from each other.
'
' Call fit() to adjust after changes. Must be called at least once after the fields are first setup.
'
' No padding is inserted between text fields so include spaces at the start and/or end of your strings 
' to get a normal looking sentence.
' 
function TextFieldMulti(textFieldCount as Integer, defaultColour as Integer, defaultFont as Object, id="" as String) as Object
    'print "new TextField"
    this = DisplayObjectContainer(id)
    
    ' STATIC PROPERTIES
    this.TOSTRING = "<TextFieldMulti>"
    
    ' PROPERTIES
    this.textFields = invalid
    this.textFieldCount = textFieldCount
    
    'METHODS
    this.dispose = function()
        for n = 0 to (m.textFieldCount-1) step +1
            m.removeChild(m.textFields[n])
            m.textFields[n].dispose()
            m.textFields[n] = invalid
        end for
        
        m.textFields = invalid
    end function
    
    this.fit = function()
        currentX = 0
        m.width = 0
        for n = 0 to (m.textFieldCount-1) step +1
            m.textFields[n].setXY(currentX, 0)
            
            ' Adjust the X positon so that the next field appears after the current one to form a sentence.
            currentX = currentX + m.textFields[n].width
            
            m.width = m.width + m.textFields[n].width
        end for
        
        if (m.textFields[0] <> invalid)
            m.height = m.textFields[0].height
        end if    
    end function
    
    ' CONSTRUCTOR CODE
    this.textFields = []
    
    for n = 0 to (this.textFieldCount-1) step +1
        this.textFields[n] = TextField()
        this.textFields[n].colour = defaultColour
        this.textFields[n].setFont(defaultFont)
        this.addChild(this.textFields[n])
    end for
    
    return this
    
end function