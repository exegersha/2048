function BaseController (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<BaseController>"
        msgBus: MessageBus()
        defaultFocus: invalid
        model: invalid

        ' Set focus to the view specified at Init()->setDefaultFocus() in sub-classes
        onFocusIn: function (eventObj as Object) as Void
            if (m.defaultFocus <> invalid)
                Stage().setFocus(m.defaultFocus)
            else
                print m.TOSTRING; " has NO defaultFocus!!!"
            end if
        end function

        ' Common behavior to dispose a widget and restore focus
        onBackPressed: function() as Void
            m.dispose()
            FocusManager().setPreviousFocus()
        end function

        getModel: function() as Object
            return m.model
        end function

        ' Must be overriden by sub-class
        createView: function () as Void
        end function

        ' Must be overriden by sub-class
        setDefaultFocus: function() as Void
        end function

        ' Must be overriden by sub-class, assigning the model to m.model
        createModel: function() as Void
        end function

         ' Must be overriden by sub-class
        registerListeners: function() as Void
        end function

        ' Common behavior to initialize a widget from the controller
        init: function (properties = {} as Object) as Void
            ' First of all create the Model to have it ready for the views
            m.createModel()

            m.createView()
            m.setDefaultFocus()
            
            m.registerListeners()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
