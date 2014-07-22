' Component that creates a Rectangle with borders added.
' @name BorderedRectangle
' @inherits Rectangle
' @param {String} id, unique id of this particular instance. Defaults to ""(empty)
' @return {Object} this, an instance of a BorderedRectangle
function BorderedRectangle (id = "" as String) as Object

    this = Rectangle(id)

    this.TOSTRING = "<BorderedRectangle>"
    this.borderColour = &h00 ' Transparent by default
    this.border = {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
    }

    ' Draws the borders around the rectangle.
    this.drawBorder = function () as Void
        ' Top
        if (m.border.top > 0)
            m.screen.drawRect(m.globalX, m.globalY, (m.border.left + m.border.right + m.width) * m.scaleX, m.border.top * m.scaleY, m.borderColour)
        end if

        ' Right
        if (m.border.right > 0)
            m.screen.drawRect(m.globalX + m.border.left + m.width, (m.globalY + m.border.top), m.border.right * m.scaleX, m.height * m.scaleY, m.borderColour)
        end if

        ' Bottom
        if (m.border.bottom > 0)
            m.screen.drawRect(m.globalX, m.globalY + m.border.top + m.height, (m.border.left + m.border.right + m.width) * m.scaleX, m.border.bottom  * m.scaleY, m.borderColour)
        end if

        ' Left
        if (m.border.left > 0)
            m.screen.drawRect(m.globalX, m.globalY + m.border.top, m.border.left, m.height * m.scaleY, m.borderColour)
        end if
    end function

    ' Sets all borders to a unified width
    ' @param {Integer} width, border width
    this.setUnifiedBorderWidth = function (width = 0 as Integer) as Void
        m.border = {
            top: width,
            right: width,
            bottom: width,
            left: width
        }
    end function

    ' Renders the component
    ' @Override
    ' @See Rectangle
    this.render = function () as Void
        m.screen.drawRect(m.globalX + m.border.left, m.globalY + m.border.top, m.width * m.scaleX, m.height * m.scaleY, m.colour)
        m.drawBorder()
    end function

    ' Disposes the component
    this.dispose =  function () as Void
        m.border = invalid
        m = invalid
    end function

    return this

end function
