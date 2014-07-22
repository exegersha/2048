'' TextArea.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function TextArea(id="" as String) as Object
    
    this = DisplaySurface(id)
    
    ' STATIC PROPERTIES
    this.TOSTRING = "<TextArea>"
    this.LEFT_ALIGN = "left" 
    this.CENTER_ALIGN = "centre" 
    this.RIGHT_ALIGN = "right"  ' TODO: right align
    
    ' PROPERTIES
    this.text = ""
    this.bgColour = &h00000000
    this.colour = &hFF ' black by default
    this.font = invalid
    
    this.multiline = false
    this.lineSpacing = 0
    this.numLines = 1
    this.textWidth = 0 ' This is the width of the text only, if it exceeds the width of the surface it is the same as the surface width
    this.textHeight = 0 ' This is the height of the text only, not necessarily related to the height of this surface
    this.align = this.LEFT_ALIGN ' default left align
    
    this.dispose = function()
        m.surface = invalid
        m.font = invalid
    end function
    
    ' redraw text to surface
    this.refresh = function()
        xpos = 0
        if(m.multiline)
            textLeft = m.text
            
            currentY = 0
            m.numLines = 0
            endOfLineIndexOffset = 0
            
            while (currentY < m.height)
                
                ' truncate line at \n before evaluating its width
                textLeftToAppend = invalid
                if (textLeft.instr("\n") > 0)
                    aux = textLeft
                    textLeft = Mid(aux, 0, textLeft.instr("\n")+2)
                    textLeftToAppend = Mid(aux, aux.instr("\n")+3)
                end if

                ' grab one line of text
                lineText = StringTruncateFromWidth(textLeft, m.font, m.width, true)  

                ' restore truncated line
                if (textLeftToAppend <> invalid)
                    textLeft = textLeft + textLeftToAppend
                end if

                if(Len(lineText) = 0) exit while ' exit if there is no text left to draw
                
                ' search for newline character
                newLineIndex = lineText.instr("\n")
                if(newLineIndex = 0) ' newline found at start of string
                    endOfLineIndexOffset = 1
                    lineText = "  " ' insert a space and move on
                else if(newLineIndex > 0)
                    ' found new line
                    lineText = Mid(textLeft, 0, newLineIndex)
                    endOfLineIndexOffset = 3
                else
                    endOfLineIndexOffset = 2
                end if
                
                if (m.align = m.CENTER_ALIGN)
                    textWidth = m.font.GetOneLineWidth(lineText,9999)
                    xpos = (m.width - textWidth)/2
                end if
                
                ' draw it
                m.surface.drawText(lineText, xpos, currentY, m.colour, m.font)
                ' deduct line from text left
                textLeft = Mid(textLeft, Len(lineText)+endOfLineIndexOffset)
                ' increment by linespace
                currentY = currentY + m.linespacing
                m.numLines = m.numLines + 1
            end while
            m.textHeight = currentY
        else
            m.numLines = 1
            m.textHeight = m.linespacing
            ' draw without wrapping
            m.surface.drawText(m.text, 0, 0, m.colour, m.font)
        end if
        
    end function
    
    this.setFont = function(font as Object)
        m.font = font
        m.lineSpacing = font.GetOneLineHeight()
    end function
    
    this.setText = function(text as String) as Void
        if(m.surface = invalid) return
        m.clear(m.bgColour)
        
        m.text = text
        m.textWidth = m.font.GetOneLineWidth(text, m.width)

        m.refresh()
    end function
    
    return this
    
end function