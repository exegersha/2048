function SettingsView (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<SettingsView>"
        msgBus: MessageBus()
        style: StyleUtils().settingsView
        bg: invalid
        versionDisplay: invalid
        defaultFocus: invalid
        controller: invalid

        onFocusIn: function (eventObj as Object) as Void
            if (m.defaultFocus <> invalid)
                Stage().setFocus(m.defaultFocus)
            else
                print m.TOSTRING; " has NO defaultFocus!!!"
            end if
        end function

        createUI: function () as Void
            m.bg = Rectangle()
            m.bg.width = m.width
            m.bg.height = m.height
            m.bg.colour = m.style.bgColour
            m.addChild(m.bg)

            m.versionDisplay = TextField()
            appVersion = m.controller.getModel().getAppVersion()
            m.versionDisplay.setText(CopyEnglish().VERSION + ": " + appVersion)
            m.versionDisplay.setXY(m.width - m.versionDisplay.width - 64, 50)
            m.addChild(m.versionDisplay)

            m.settingsMenuCtrl = SettingsMenuController({
                parentContainer: m
            })

            ' Pass the focus to the next controller
            m.defaultFocus = m.settingsMenuCtrl.getView()
        end function

        init: function (properties = {} as Object) as Void
            m.controller = properties.controller
            m.createUI()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
