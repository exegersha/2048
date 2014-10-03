'' EventDispatcher.brs

function EventDispatcher (id = "" as String) as Object
    this = {
        id: id,
        listeners: {}
    }

    if (this.id = "") this.id = "instance" + InstanceCount().getNext().toStr()

    ' METHODS
    this.addEventListener = function (properties = {} as Object) as void
        if (properties.handler = invalid OR properties.eventType = invalid OR properties.context = invalid)
            print "Error: Listener NOT added, missing properties."
            print "Error: properties.eventType = " + properties.eventType
            print "Error: properties.handler = " + properties.handler
            print "Error: properties.context = " + properties.context
        else
            m.listeners.AddReplace(properties.handler + properties.eventType, {
                eventType: properties.eventType,
                handler: properties.handler,
                context: properties.context
            })
        end if
    end function

    this.dispatchEvent = function (eventObj = {} as Object) as Boolean
        eventType = eventObj.eventType

        for each listenerObj in m.listeners
            if (m.listeners[listenerObj].eventType = eventType)
                if (m.listeners[listenerObj].context[m.listeners[listenerObj].handler] <> invalid)
                    m.listeners[listenerObj].context[m.listeners[listenerObj].handler](eventObj)
                end if
            end if
        end for

    end function

    this.removeAllListeners = function () as void
        for each listenerObj in m.listeners
            m.listeners.delete(m.listeners[listenerObj].handler + m.listeners[listenerObj].eventType)
        end for
    end function

    this.removeEventListener = function (properties = {} as Object) as void
        if (properties.handler = invalid OR properties.eventType = invalid OR properties.context = invalid)
            print "Error: Listener NOT removed, missing properties."
            print "Error: properties.eventType = " + properties.eventType
            print "Error: properties.handler = " + properties.handler
            print "Error: properties.context = " + properties.context
        else
            for each listenerObj in m.listeners
                if (m.listeners[listenerObj].context.id = properties.context.id AND m.listeners[listenerObj].eventType = properties.eventType AND m.listeners[listenerObj].handler = properties.handler)
                    m.listeners.delete(m.listeners[listenerObj].handler + m.listeners[listenerObj].eventType)
                    return
                end if
            end for
        end if
    end function

    this.clearEventListeners = function (listenerId) as void
        for each listenerObj in m.listeners
            if (m.listeners[listenerObj].context.id = listenerId)
                m.listeners.delete(m.listeners[listenerObj].handler + m.listeners[listenerObj].eventType)
            end if
        end for
    end function

    return this

end function