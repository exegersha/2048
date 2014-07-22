function CoreElement (properties = {} as Object) as Object

    if (properties.id <> invalid)
        id = properties.id
    else
        id = ""
    end if

    this = DisplayObjectContainer(id)

    this.destroyAllChildren = function () as Void
        for each child in m.childrenMap
            m.destroyChild(m.childrenMap[child])
        end for
    end function

    this.destroyChild = function (child as Object) as Void
        m.removeChild(child)
        if child.dispose <> invalid
            child.dispose()
        else
            child = Invalid
        end if
    end function

    this.removeEvents = function () as Void
        MessageBus().clearEventListeners(m.id)
    end function

    this.removeProperties = function () as Void
        for each property in m
            m[property] = Invalid
        end for
    end function

    ' Is this really needed, are we expecting every element to have a timer?'
    ' this.removeTimer = function () as Void
    '     if (m.timer <> invalid)
    '         m.timer.removeEventListener({"onTimer", "", m})
    '         m.timer.removeEventListener("onTimerComplete", "", m)
    '         m.timer.stop()
    '         m.timer = invalid
    '     end if
    ' end function

    this.handleDispose = function () as Void
    end function

'----------------------------------------
'--- Public API -------------------------
'----------------------------------------

    this.dispose = function () as void
        m.handleDispose()
        ' m.removeTimer()
        m.removeEvents()
        Stage().removeFocus()

        if (m.clear <> invalid)
            m.clear()
        end if

        m.destroyAllChildren()
        m.removeProperties()
        m = Invalid
        RunGarbageCollector()
    end function

'----------------------------------------
'--- Constructors -----------------------
'----------------------------------------
    this.initCoreElement = function (properties)
        if (properties.parentContainer <> invalid)
            properties.parentContainer.addChild(m)
        end if

        if (properties.x <> invalid)
            m.setX(properties.x)
        end if

        if (properties.y <> invalid)
            m.setY(properties.y)
        end if
    end function

    this.init = function (properties = {} as Object) as Void
    end function

    for each property in properties
        this.AddReplace(property, properties[property])
    end for

    this.initCoreElement(properties)
    this.init(properties.initProperties)

    return this
end function