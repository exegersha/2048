function SettingsMenuView (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<SettingsMenuView>",
        controller: invalid,
        arrMenuWidgets: [],
        msgBus: MessageBus(),
        yPadding: 30

        createUI: function (menuEntries as Object) as Void
            menuItemY = 0
            length = menuEntries.count()

            for i = 0 to length - 1 step 1
                m.arrMenuWidgets.push(SettingsMenuItemView({
                    parentContainer: m,
                    y: menuItemY,
                    initProperties: {
                        title: menuEntries[i].title,
                        value: menuEntries[i].value
                    }
                }))
                menuItemY = menuItemY + m.yPadding
            end for
        end function,

        updateUI: function (menuEntries as Object) as Void
            length = menuEntries.count()

            for i = 0 to length - 1 step 1
                m.arrMenuWidgets[i].updateValue(menuEntries[i].value)
            end for
        end function,

        unfocusItem: function (index) as Void
            m.arrMenuWidgets[index].setInactive()
        end function,

        focusItem: function (index) as Void
            m.arrMenuWidgets[index].setActive()
        end function,

        selectItem: function (index) as Void
            m.arrMenuWidgets[index].setSelected()
        end function,

        onFocusIn: function (eventObj as Object) as Void
            m.controller.focusSelectedItem()
        end function,

        onFocusOut: function (eventObj as Object) as Void
            m.controller.selectSelectedItem()
        end function,

        onUpPressed: function () as Void
            m.controller.onUpPressed()
        end function,

        onDownPressed: function () as Void
            m.controller.onDownPressed()
        end function,

        onLeftPressed: function () as Void
            m.controller.onLeftPressed()
        end function,

        onRightPressed: function () as Void
            m.controller.onRightPressed()
        end function,

        onBackPressed: function() as Void
            m.controller.onBackPressed()
        end function

        init: function (properties = {} as Object) as Void
            m.controller = properties.controller
            m.createUI(properties.arrMenuEntries)
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
