function Button (properties = {} as Object) as Object

    this = DisplaySurface()

    argStyle = properties.style
    if (argStyle = invalid)
        argStyle = {}
    end if

    colours = {
        WHITE: &hE9E9E9FF, ' Safe white
        WHITE_25: &hE9E9E940, ' Safe white - 25% opacity

        BLACK: &h080808FF, ' Safe Black
        GREY: &hE9E9E9FF ' Grey
    }

    style = MergeObjects({
        font: invalid,
        minWidth: 50,
        minHeight: 50,

        padding: {
            top: 5,
            right: 10,
            bottom: 5,
            left: 10
        },
        margin: {
            top: 0,
            right: 0,
            bottom: 0,
            left: 0
        },

        inactive: {
            textColour: colours.WHITE
            backgroundColour: colours.WHITE_25
        },
        active: {
            textColour: colours.BLACK
            backgroundColour: colours.GREY
        }
    }, argStyle)

    btnText = properties.text
    if (btnText = invalid)
        btnText = ""
    end if

    this.TOSTRING = "<Button>"

    this.style = style
    this.btnText = btnText
    this.active = false

    this.createUI = function () as Void
        style = m.style

        text = TextField()
        text.colour = style.inactive.textColour
        if (style.font <> invalid)
            text.setFont(style.font)
        end if
        text.setText(m.btnText)
        m.text = text

        m.update()
    end function

    this.dispose = function ()
        m.clear()
        m.surface = invalid
        m.text = invalid
    end function

    this.update = function () as Void
        style = m.style

        width = m.text.width + style.padding.left + style.padding.right
        height = m.text.height + style.padding.top + style.padding.bottom

        ' minimum width for buttons
        if (width < style.minWidth)
            width = style.minWidth
        end if

        if (height < style.minHeight)
            height = style.minHeight
        end if

        m.width = width
        m.height = height

        textX = m.style.padding.left
        textY = m.style.padding.top
        m.text.setXY(textX, textY)

        if (m.active)
            m.bgColour = m.style.active.backgroundColour
            m.text.colour = m.style.active.textColour
        else
            m.bgColour = m.style.inactive.backgroundColour
            m.text.colour = m.style.inactive.textColour
        end if

        m.init(width, height)

        m.clear(m.bgColour)
        m.drawTo(m.text)
    end function

    this.onFocusIn = function (eventObj as Object) as Void
        m.setActive()
    end function

    this.onFocusOut = function (eventObj as Object) as Void
        m.setInactive()
    end function

    this.getWidth = function () as Integer
        return m.width + m.style.margin.left + m.style.margin.right
    end function

    this.getHeight = function () as Integer
        return m.height + m.style.margin.top + m.style.margin.bottom
    end function

    this.setText = function (text = "" as String) as Void
        m.text.setText(text)
        m.update()
    end function

    this.getText = function () as String
        return m.text.getText()
    end function

    this.setStyle = function (style = {} as Object) as Void
        m.style = MergeObjects(m.style, style)
        m.update()
    end function

    this.setActive = function () as Void
        m.active = true
        m.update()
    end function

    this.setInactive = function () as Void
        m.active = false
        m.update()
    end function

    this.createUI()

    return this
end function
