' Component that creates a simple Rectangle without any borders.
' @name Rectangle
' @inherits DisplayObject
' @param {String} id, unique id of this particular instance. Defaults to ""(empty)
' @return {Object} this, an instance of a Rectangle
function Rectangle (id = "" as String) as Object

    this = DisplayObject(id)

    this.TOSTRING = "<Rectangle>"
    this.colour = &hFF ' black by default

    ' Renders the component
    this.render = function () as Void
        m.screen.drawRect(m.globalX, m.globalY, m.width * m.scaleX, m.height * m.scaleY, m.colour)
    end function

    return this

end function
