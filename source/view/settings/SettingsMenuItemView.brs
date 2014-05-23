function SettingsMenuItemView (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<SettingsMenuItemView>",
        title: "",
        value: "",
        settingTF: invalid,
        valueTF: invalid,
        style: {
            xPadding: 300,
            focused: {
                settingTFColour: &hFFFFFFFF,
                valueTFFColour: &hFFFFFFFF
            },
            unfocused: {
                settingTFColour: &h000000FF,
                valueTFFColour: &h000000FF
            },
            selected: {
                settingTFColour: &hFF00FFFF,
                valueTFFColour: &hFF00FFFF
            }
        }

        createUI: function () as Void
            m.settingTF = TextField()
            m.settingTF.setText(m.title)
            m.addChild(m.settingTF)

            m.valueTF = TextField()
            m.valueTF.setText(m.value)
            m.valueTF.setX(m.style.xPadding)
            m.addChild(m.valueTF)
        end function,

        updateValue: function (value = "" as String) as Void
            m.value = uCase(value)
            m.valueTF.setText(m.value)
        end function,

        init: function (properties = {} as Object) as Void
            m.title = uCase(properties.title)
            m.value = uCase(properties.value)
            m.createUI()
        end function,

        setActive: function () as Void
            m.settingTF.colour = m.style.focused.settingTFColour
            m.valueTF.colour = m.style.focused.valueTFFColour
        end function,

        setInactive: function () as Void
            m.settingTF.colour = m.style.unfocused.settingTFColour
            m.valueTF.colour = m.style.unfocused.valueTFFColour
        end function,

        setSelected: function () as Void
            m.settingTF.colour = m.style.selected.settingTFColour
            m.valueTF.colour = m.style.selected.valueTFFColour
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
