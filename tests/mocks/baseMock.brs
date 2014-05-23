function BaseMock(properties = {} as Object) as Object

    mock = {

        TOSTRING: "<BaseMock>"

        ' Will hold the calls placed on this instance as objects like
        '   methodName: {nb: <Integer>}
        methodCalls: {}

        storeMethodCall: function (methodName="" as String, arguments={} as Object) as Void
            if (m.methodCalls[methodName] = invalid)
                m.methodCalls[methodName] = []
            end if

            m.methodCalls[methodName].push(arguments)
        end function

        getMethodCallCount: function (methodName="" as String) as Integer
            nb = 0

            if (m.methodCalls[methodName] <> invalid)
                nb = m.methodCalls[methodName].Count()
            end if

            return nb
        end function

        getLastMethodCallArguments: function (methodName="" as String) as Object
            args = {}

            if (m.methodCalls[methodName] <> invalid)
                l = m.getMethodCallCount(methodName)
                args = m.methodCalls[methodName][l-1]
            end if

            return args
        end function
    }


    for each property in properties
        mock.AddReplace(property, properties[property])
    end for

    return mock

end function
