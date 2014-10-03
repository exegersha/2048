'' TextFieldWithHighlight.brs


function TextFieldWithHighlight(style={} as Object) as Object

    this = TextField()

    ' STATIC PROPERTIES
    this.TOSTRING = "<TextFieldWithHighlight>"

    ' PROPERTIES
    this.highlight = ""
    this.highlightParts = []
    this.highlightColour = &h333333FF ' dark grey by default
    this.highlightFont = invalid

    if (style.highlightColour <> invalid)
        this.highlightColour = style.highlightColour
    end if

    if (style.highlightFont <> invalid)
        this.highlightFont = style.highlightFont
    end if

    ' METHODS
    this.render = function()
        if(m.font <> invalid AND m.screen <> invalid)
            'print m.text ; m.x ; m.y
            if (m.highlight <> "") AND (m.highlightParts.Count() >= 1)
                currX = m.globalX

                for each part in m.highlightParts
                    if(part[1] = true)
                        colour = m.highlightColour
                        font = m.highlightFont
                    else
                        colour = m.colour
                        font = m.font
                    end if

                    m.screen.drawText(part[0], currX, m.globalY, colour, font)
                    currX = currX + font.GetOneLineWidth(part[0], 9999) + font.GetOneLineWidth("", 9999)
                end for
            else
                m.screen.drawText(m.renderedText, m.globalX, m.globalY, m.colour, m.font)
            end if
        end if
    end function

    ' using setText ensures width of text are set
    this.setText = function(text as String, highlight="" as String)
        m.text = text
        m.renderedText = text
        m.highlight = highlight

        if (highlight <> "")
            m.setHighlightedText(text, highlight)
        end if

        if (m.font <> invalid)
            m.width = m.font.GetOneLineWidth(text, 99999)
            m.height = m.font.GetOneLineHeight()
        end if
    end function

    this.setHighlightedText = function(baseStr as String, highlight="" as String)

        i = 1
        currIndex = 1
        highlightLen = Len(highlight)
        m.highlightParts = []

        foundIndexes = []

        while i <= Len(baseStr)

            x = Instr(i, LCase(baseStr), LCase(highlight))

            if x = 0 then
                m.highlightParts.Push([Mid(baseStr, currIndex, Len(baseStr) - currIndex + 1), false])
                exit while
            endif

            if x > i then
                i = x
            endif

            foundIndexes.push(x)

            m.highlightParts.Push([Mid(baseStr, currIndex, x - currIndex ), false])
            m.highlightParts.Push([Mid(baseStr, x, highlightLen), true])

            i = i + highlightLen
            currIndex = i
        end while
    end function

    return this

end function