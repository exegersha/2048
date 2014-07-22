'' ScrollTextArea.brs
function ScrollTextArea(properties={} as Object) as Object
    
    if(properties.id = invalid)
        properties.id = ""
    end if

    this = DisplaySurface(properties.id)
    
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
    
    this.lineSpacing = 0
    this.textWidth = 0 ' This is the width of the text only, if it exceeds the width of the surface it is the same as the surface width
    this.textHeight = 0 ' This is the height of the text only, not necessarily related to the height of this surface
    this.align = this.LEFT_ALIGN ' default left align
    this.scrollBarWidth = 5
    this.scrollBarLeftMargin = 15
    this.scrollBarColour = &h767676FF
    this.scrollBarThumbColour = &hFFFFFFFF
    
    this.pages = []
    this.pageIndex = 0
    this.maxPageIndex = 0

    'TODO: CHENGE THESE STUPID NAMES
    this.topLineL = 0
    this.prevTopLineL = 0

    this.progressCallback = function()
        ' print "default progress callback"
    end function

    this.dispose = function()
        m.surface = invalid
        m.textZone.surface = invalid
        m.textZone = invalid
        m.font = invalid
    end function
    
    ' redraw text to surface
    this.paginate = function()
        textLeft = m.text
        m.pages = [{lines:[]}]
        pageIndex = 0
        
        lineText = StringTruncateFromWidth(textLeft, m.font, m.textWidth, true)
        currentY = 0

        while (Len(lineText) <> 0)
            ' search for newline character
            newLineIndex = lineText.instr("\n")
            xpos = 0
            EOLOffset = 0

            if(newLineIndex = 0) ' newline found at start of string
                EOLOffset = 1
                lineText = " " ' insert a space and move on
            else if(newLineIndex > 0)
                ' found new line
                lineText = Mid(textLeft, 0, newLineIndex)
                EOLOffset = 3
            else
                EOLOffset = 1
                newLineIndex = lineText.instr(chr(10))

                if(newLineIndex = 0) ' newline found at start of string
                    lineText = " " ' insert a space and move on
                else if(newLineIndex > 0)
                    ' found new line
                    lineText = Mid(textLeft, 0, newLineIndex)
                end if
            end if
            
            if (m.align = m.CENTER_ALIGN)
                lineWidth = m.font.GetOneLineWidth(lineText,9999)
                xpos = (m.textWidth - lineWidth)/2
            end if
            
            lineL = Len(lineText)+EOLOffset

            if (currentY >= (m.height - m.lineSpacing))
                pageIndex = pageIndex + 1
                currentY = m.linespacing

                ' Add previous page's bottom line as the first line in the current page
                lastLineAdded.Y = 0
                m.pages[pageIndex] = {lines:[lastLineAdded]}
            end if

            lineY = currentY

            m.pages[pageIndex].lines.push({text: lineText, X: xpos, Y: lineY, length: lineL})            
            lastLineAdded = {text: lineText, X: xpos, Y: lineY, length: lineL}

            ' increment by linespace
            currentY = currentY + m.linespacing
            textLeft = Mid(textLeft, lineL+1)
            lineText = StringTruncateFromWidth(textLeft, m.font, m.textWidth, true)
            m.progressCallback()
        end while

        m.maxPageIndex = pageIndex
        m.textHeight = currentY

        thumbHeight =  int(m.height / (pageIndex+1))
        
        m.scrollBar = DisplaySurface()
        m.scrollBar.init(m.scrollBarWidth, thumbHeight*(pageIndex+1))
        m.scrollBar.clear(m.scrollBarColour)
        m.scrollBar.setXY(m.width - m.scrollBarWidth, 0)

        m.scrollBarThumb = DisplaySurface()
        m.scrollBarThumb.init(m.scrollBarWidth, thumbHeight)
        m.scrollBarThumb.clear(m.scrollBarThumbColour)
        m.scrollBarThumb.setX(m.width - m.scrollBarWidth)

        m.refresh()
    end function

    this.hideScrollBar = function() as Void
        m.scrollBarWidth = 0
        m.redrawScrollBar()
    end function

    this.showScrollBar = function() as Void
        if (m.pages.count() > 1)
            m.scrollBarWidth = 5
            m.redrawScrollBar(m.scrollBarColour, m.scrollBarThumbColour)            
        end if
    end function

    this.redrawScrollBar = function(scrollBarColour=&h00000000 as Integer, scrollBarThumbColour=&h00000000 as Integer)
        m.scrollBar.clear(scrollBarColour)            
        m.drawTo(m.scrollBar)

        m.scrollBarThumb.clear(scrollBarThumbColour)
        m.drawTo(m.scrollBarThumb)
    end function

    this.refresh = function()
        m.textZone.clear(m.bgColour)
        
        for each line in m.pages[m.pageIndex].lines
            m.textZone.surface.drawText(line.text, line.X, line.Y, m.colour, m.font)
        end for

        m.drawTo(m.textZone)
        m.drawTo(m.scrollBar)
        m.scrollBarThumb.setY(m.pageIndex * m.scrollBarThumb.height)
        m.drawTo(m.scrollBarThumb)
    end function
    
    this.scrollDown = function()
        ' print m.TOSTRING; "scrollDown"
        m.pageIndex = m.pageIndex + 1
        if (m.pageIndex > m.maxPageIndex)
            m.pageIndex = m.maxPageIndex
        end if
        
        ' TweenManager().to(m.textZone, 15, {x:0, y:-m.height, ease:EaseOutQuad, onComplete: {destination:m, callback:"refresh"}})
        
        m.refresh()
    end function

    this.scrollUp = function()
        ' print m.TOSTRING; "scrollUp"
        m.pageIndex = m.pageIndex - 1
        if (m.pageIndex < 0)
            m.pageIndex = 0
        end if
        
        m.refresh()
    end function

    this.setFont = function(font as Object)
        m.font = font
        m.lineSpacing = font.GetOneLineHeight()
    end function
    
    this.setText = function(text as String) as Void
        if(m.surface = invalid) return

        m.text = text

        m.paginate()
    end function
    
    this.initialise = function(width=1000 as Integer, height=1000 as Integer)
        m.textWidth = width - m.scrollBarWidth - m.scrollBarLeftMargin
        m.textZone = DisplaySurface()
        m.textZone.init(m.textWidth, height)

        if (m.onProgress <> invalid) AND (m.onProgress.destination <> invalid) AND (m.onProgress.callback <> invalid)

            m.progressCallback = m.onProgress.destination[m.onProgress.callback]
        end if
        
        m.init(width, height)
    end function

    for each property in properties
        this.AddReplace(property, properties[property])
    end for

    return this
    
end function