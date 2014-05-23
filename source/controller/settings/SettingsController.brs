function SettingsController (properties = {} as Object) as Object

    '  This object is passed to the BaseController constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<SettingsController>"
        defaultFocus: invalid
        settingsView: invalid
        settingsButtonsView: invalid
        model: invalid


        onWidgetBottomHandler: function (eventObj as Object) as Void
            Stage().setFocus(m.settingsButtonsView)
        end function,

        onWidgetUpHandler: function (eventObj as Object) as Void
            Stage().setFocus(m.settingsView)
        end function,

        onSettingsBackPressedHandler: function(eventObj as Object) as Void
            m.onBackPressed()
        end function

        registerListeners: function() as Void
             m.msgBus.addEventListener({
                context: m,
                eventType: "onWidgetBottom",
                handler: "onWidgetBottomHandler"
            })

            m.msgBus.addEventListener({
                context: m,
                eventType: "onWidgetUp",
                handler: "onWidgetUpHandler"
            })

            m.msgBus.addEventListener({
                context: m,
                eventType: "onSettingsBackPressed",
                handler: "onSettingsBackPressedHandler"
            })
        end function

        createView: function () as Void
            m.settingsView = SettingsView({
                parentContainer: m,
                width: 1280,
                height: 720,
                initProperties: {
                    controller: m
                }
            })

            m.settingsButtonsView = SettingsButtonsWidget({
                parentContainer: m,
                x: 64,
                y: 400
            })
        end function

        ' Set the view to take focus onFocusIn() in BaseController
        setDefaultFocus: function() as Void
            m.defaultFocus = m.settingsView
        end function

        createModel: function() as Void
            m.model = SettingsMenuModel()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = BaseController(classDefinition)

    return this

end function
