'' DisplayObject.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function DisplayObject(id="" as String) as Object

    this = EventDispatcher(id)

    ' STATIC PROPERTIES
    this.TOSTRING = "<DisplayObject>"

    ' PROPERTIES
    this.x = 0
    this.y = 0
    this.scaleX = 1
    this.scaleY = 1
    this.globalX = 0
    this.globalY = 0
    this.width = 0
    this.height = 0
    this.visible = true
    this.screen = invalid
    this.parent = invalid

    ' METHODS

    ' Any display object will need to override this
    this.render = function() as Void
    end function

    this.setScreen = function(screen as Object)
        m.screen = screen
        if (screen <> invalid) m.dispatchEvent(Event({
            eventType: "onAddedToStage",
            target: m
        }))
    end function

    ' Use SetX to adjust X position as this will ensure relative position to parent
    this.setX = function(x as Integer)
        m.x = x
        if (m.parent <> invalid)
            m.globalX = m.parent.globalX + x
        else
            m.globalX = x
        end if
    end function

    ' Use SetX to adjust Y position as this will ensure relative position to parent
    this.setY = function(y as Integer)
        m.y = y
        if (m.parent <> invalid)
            m.globalY = m.parent.globalY + y
        else
            m.globalY = y
        end if
    end function

    ' Use SetXY as this will ensure relative position to parent
    this.setXY = function(x as Integer, y as Integer)
        m.x = x
        m.y = y
        if (m.parent <> invalid)
            m.globalX = m.parent.globalX + m.x
            m.globalY = m.parent.globalY + m.y
        else
            m.globalX = m.x
            m.globalY = m.y
        end if
        'print "new position of " ; m.id ; ": " ; m.x.toStr() ; " x " ; m.y.toStr() ; " (" ; m.globalX.toStr() ; " x " ; m.globalY.toStr() ; ")"
    end function

    this.setScale = function(scaleX as Float, scaleY as Float)
        m.scaleX = scaleX
        m.scaleY = scaleY
    end function

    ' Returns a reference to an object which matches the object id
    this.findObjectFromId = function(id as String) as Object
        for each prop in m
            propType = type(m[prop])
            if (propType = "roAssociativeArray") and (m[prop].id <> invalid) and (m[prop].id = id) return m[prop]
        end for
        return invalid
    end function

    ' Returns an XML string of a list of objects for this object
    this.getObjects = function() as String
        objType = StringReplace(m.TOSTRING, "<", "")
        objType = StringReplace(objType, ">", "")
        return "<" + objType + " id='" + m.id + "' x='" + m.x.toStr() + "' y='" + m.y.toStr() + "'/>"
    end function

    this.getPropertiesForInstance = function(id as String) as String
        target = m.findObjectFromId(id)
        if (target = invalid) return "OBJECT '" + id + "' NOT FOUND"
        return target.getProperties()
    end function

    ' Returns an XML string of a list of properties for this object
    this.getProperties = function() as String
        objType = StringReplace(m.TOSTRING, "<", "")
        objType = StringReplace(objType, ">", "")
        xmlString = "<" + objType + " id='" + m.id + "'>"
        for each prop in m
            propId = ""
            propType = type(m[prop])

            if (propType = "roString") or (propType = "string")
                propValue = m[prop]

            else if (propType = "roInteger")
                propValue = m[prop].toStr()

            else if (propType = "roBoolean")
                propValue = BoolToStr(m[prop])

            else
                propValue = propType
                if (propType = "roAssociativeArray") and (m[prop].id <> invalid) propId = m[prop].id

            end if

            if (propType = "roArray")
                xmlString = xmlString + "<" + prop + " id='" + propId + "' value='" + propValue + "' count='" + m[prop].count().toStr() + "'/>"
            else
                xmlString = xmlString + "<" + prop + " id='" + propId + "' value='" + propValue + "'/>"
            end if
        end for
        return xmlString + "</" + objType + ">"
    end function

    return this

end function
