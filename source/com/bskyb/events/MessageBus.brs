function MessageBus () as Object

    if (m.messageBus = invalid)
        m.messageBus = EventDispatcher("MessageBus")
    end if

    return m.messageBus
end function