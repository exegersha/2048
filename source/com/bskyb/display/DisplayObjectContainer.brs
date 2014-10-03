'' DisplayObjectContainer.brs


function DisplayObjectContainer(id="" as String) as Object

    'print "new DisplayObjectContainer: " + id
    this = InteractiveObject(id)

    ' STATIC PROPERTIES
    this.TOSTRING = "<DisplayObjectContainer>"

    ' PROPERTIES
    this.children = []
    this.childrenMap = {}

    ' METHODS
    this.setScreen = function(screen as Object)
        m.screen = screen
        for each c in m.children
            c.setScreen(screen)
        end for
        if (screen <> invalid) m.dispatchEvent(Event({
            eventType: "onAddedToStage",
            target: m
        }))
    end function

    this.unshiftChild = function(child as Object) as Void
        if(m.contains(child)) return

        m.children.unshift(child)
        m.setupNewChild(child)
    end function

    this.addChild = function(child as Object) as Void
        if(m.contains(child)) return

        m.children.push(child)
        m.childrenMap[child.id] = child
        m.setupNewChild(child)
    end function

    this.insertChild = function(child as Object, position as Integer) as Void
        if(m.contains(child)) return

        childAdded = false
        newChildrenArray = []

        for currentPosition=0 to m.children.count() step +1
            if (currentPosition = position)
                ' This is the correct position of the new child.
                childAdded = true
                newChildrenArray.push(child)
            end if

            if (m.children[currentPosition] <> invalid)
                newChildrenArray.push(m.children[currentPosition])
            end if
        end for

        if (childAdded)
            ' Child was added so sort ou the children array and continue adding the child.
            m.children.clear()
            m.children.append(newChildrenArray)
            m.setupNewChild(child)
        end if
    end function

    this.setupNewChild = function(child as Object) as Void
        ' Pass handle to screen to children
        if(m.screen <> invalid) child.setScreen(m.screen)

        ' handle to parent
        child.parent = m

        child.setXY(child.x, child.y)
    end function

    this.contains = function(child as Object) as Boolean
        for each c in m.children
            if(child.id = c.id) return true
        end for
        return false
    end function

    this.removeChild = function(child as Object) as Void
        index = 0
        for each c in m.children
            if(child.id = c.id)
                c.parent = invalid 'remove reference to parent
                c.setScreen(invalid)
                m.children.delete(index)
            end if
            index = index + 1
        end for
        m.childrenMap.delete(child.id)
    end function

    this.render = function() as Void
       if (m.visible <> invalid AND m.visible)
           for each c in m.children
                if (c.visible <> invalid AND c.visible) c.render()
           end for
       end if
    end function

    this.setX = function(x as Integer)
        m.x = x
        if(m.parent <> invalid)
            m.globalX = m.parent.globalX + x
        else
            m.globalX = x
        end if

        for each c in m.children
            c.setX(c.x)
        end for
    end function

    this.setY = function(y as Integer)
        m.y = y
        if(m.parent <> invalid)
            m.globalY = m.parent.globalY + y
        else
            m.globalY = y
        end if

        for each c in m.children
            c.setY(c.y)
        end for
    end function

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

        for each c in m.children
            c.setXY(c.x, c.y)
        end for

    end function

    ' Returns a reference to an object which matches the object id
    this.findObjectFromId = function(id as String) as Object
        ' Check properties
        for each prop in m
            propType = type(m[prop])
            if (propType = "roAssociativeArray") and (m[prop].id <> invalid) and (m[prop].id = id) return m[prop]
        end for
        ' Check children
        for each child in m.children
            if (child.id = id)
                return child
            else
                obj = child.findObjectFromId(id)
                if (obj <> invalid) return obj
            end if
        end for
        return invalid
    end function

    ' Returns an XML string of an object that matches the instance id passed
    this.getObjectsForInstance = function(id as String) as String
        target = m.findObjectFromId(id)
        if (target = invalid) return "OBJECT '" + id + "' NOT FOUND"
        return target.getObjects()
    end function

    ' Returns an XML string of a list of objects for this object
    this.getObjects = function() as String
        objType = StringReplace(m.TOSTRING, "<", "")
        objType = StringReplace(objType, ">", "")
        xmlString = "<" + objType + " id='" + m.id + "' x='" + m.x.toStr() + "' y='" + m.y.toStr() + "'>"
        for each c in m.children
            xmlString = xmlString + c.getObjects()
        end for
        return xmlString + "</" + objType + ">"
    end function

    return this

end function