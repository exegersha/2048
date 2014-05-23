function SettingsButtonsWidget (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<SettingsButtonsWidget>"
        WRITE_SETTINGS_BTN_INDEX: 0
        CLEAR_SETTINGS_BTN_INDEX: 1
        buttonsTexts: [
            CopyEnglish().WRITE_SETTINGS,
            CopyEnglish().SET_DEFAULTS
        ]
        msgBus: MessageBus()
        settingsModel: SettingsMenuModel()

        createUI: function () as Void
            m.buttonArea = MultiButtonArea()
            m.buttonArea.setButtons(m.buttonsTexts, m.WRITE_SETTINGS_BTN_INDEX)
            m.addChild(m.buttonArea)
        end function

        onLeftPressed: function() as Void
            m.buttonArea.onLeftPressed()
        end function

        onRightPressed: function() as Void
            m.buttonArea.onRightPressed()
        end function

        onSelectPressed: function() as Void
            if (m.buttonArea.getActiveButton() = m.WRITE_SETTINGS_BTN_INDEX)
                m.settingsModel.writeSettings()
            else
                m.settingsModel.resetToDefauls()
            end if
        end function

        onUpPressed: function() as Void
            m.msgBus.dispatchEvent(Event({
                eventType: "onWidgetUp",
                target: m
            }))
        end function

        onBackPressed: function() as Void
            m.msgBus.dispatchEvent(Event({
                target: m,
                eventType: "onSettingsBackPressed"
            }))
        end function

        onFocusIn: function (eventObj as Object) as Void
            m.buttonArea.setActive()
        end function

        onFocusOut: function (eventObj as Object) as Void
            m.buttonArea.setInactive()
        end function

        init: function (properties = {} as Object) as Void
            m.createUI()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
