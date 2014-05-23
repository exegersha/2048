'
' Controller used to manage the connection between the corresponding
' model (SettingsMenuModel) and the view (SettingsMenuView).
'
' @param {Object} properties, inital properties passed to this module's init method on creation.
' @return {Object} SettingsMenuController, the actual controller for the settings menu as a SINGLETON.
'
function SettingsMenuController (properties = {} as Object) as Object

    this = {
        TOSTRING: "<SettingsMenuController>",
        msgBus: MessageBus(),
        arrMenuEntries: [],
        view: invalid,

        INITIAL_INDEX_SELECTION: 0,
        selectedItemIndex: invalid,
        previousSelectedItemIndex: invalid,
        settingsModel: SettingsMenuModel(),

        ' Gets the corresponding view.
        ' @return {Object} the view corresponding to and managed by this module.
        getView: function () as Object
            return m.view
        end function,

        ' Focuses the currently selected item in the view, using index, and
        ' unfocuses the previously selected item if available.
        focusSelectedItem: function () as Void
            if (m.previousSelectedItemIndex <> invalid AND m.arrMenuEntries[m.previousSelectedItemIndex] <> invalid)
                m.view.unfocusItem(m.previousSelectedItemIndex)
            end if

            m.view.focusItem(m.selectedItemIndex)
        end function,

        ' Sets the currently selected item as selected in the view,
        ' using index.
        selectSelectedItem: function ()
            m.view.selectItem(m.selectedItemIndex)
        end function,

        onUpPressed: function () as Void
            if (m.arrMenuEntries[m.selectedItemIndex - 1] <> invalid)
                m.previousSelectedItemIndex = m.selectedItemIndex
                m.selectedItemIndex = m.selectedItemIndex - 1
                m.focusSelectedItem()
            else
                m.msgBus.dispatchEvent(Event({
                    eventType: "onWidgetUp",
                    target: m
                }))
            end if
        end function,

        onDownPressed: function () as Void
            if (m.arrMenuEntries[m.selectedItemIndex + 1] <> invalid)
                m.previousSelectedItemIndex = m.selectedItemIndex
                m.selectedItemIndex = m.selectedItemIndex + 1

                m.focusSelectedItem()
            else
                m.msgBus.dispatchEvent(Event({
                    eventType: "onWidgetBottom",
                    target: m
                }))
            end if
        end function,

        onLeftPressed: function () as Void
            if (m.arrMenuEntries[m.selectedItemIndex] <> invalid)
                key = m.arrMenuEntries[m.selectedItemIndex].title
                m.arrMenuEntries[m.selectedItemIndex].value = m.settingsModel.getPreviousMenuEntryOption(key)

                m.view.updateUI(m.arrMenuEntries)
            end if
        end function,

        onRightPressed: function () as Void
            if (m.arrMenuEntries[m.selectedItemIndex] <> invalid)
                key = m.arrMenuEntries[m.selectedItemIndex].title
                m.arrMenuEntries[m.selectedItemIndex].value = m.settingsModel.getNextMenuEntryOption(key)

                m.view.updateUI(m.arrMenuEntries)
            end if
        end function,

        onBackPressed: function () as Void
            m.msgBus.dispatchEvent(Event({
                target: m,
                eventType: "onSettingsBackPressed"
            }))
        end function

        ' Handler for the onResetToDefaults event. It updates all menu entries in the view
        ' any time the settings are being reset to default by the model.
        onSettingsResetToDefaultsHandler: function (eventObj as Object) as Void
            aaSettingsModel = eventObj.payload.settingsModel
            i = 0

            for each key in aaSettingsModel
                settingsEntry = aaSettingsModel[key]
                m.arrMenuEntries[i].value = settingsEntry.OPTIONS[settingsEntry.SELECTED].humanReadable
                i = i + 1
            end for

            m.view.updateUI(m.arrMenuEntries)
        end function,

        ' Creates a menu entry specially designed to be used by the view.
        ' @param {String} key, the title/name of the menu entry (i.e. "ENVIRONMENT", "REGISTRY_SECTION", etc.).
        ' @param {String} value, the value of the menu entry as a human redable (i.e. "PRODUCTION", "CONFIG", etc.).
        ' @return {Object} the menu entry designed to be used by the view.
        createMenuEntry: function (key, value) as Object
            return {
                title: key,
                value: value
            }
        end function

        init: function (properties = {} as Object) as Void
            m.selectedItemIndex = m.INITIAL_INDEX_SELECTION

            m.msgBus.addEventListener({
                context: m,
                eventType: "onSettingsResetToDefaults",
                handler: "onSettingsResetToDefaultsHandler"
            })

            aaSettings = m.settingsModel.getMenu()
            for each key in aaSettings
                settingsEntry = aaSettings[key]
                menuEntry = m.createMenuEntry(key, settingsEntry.OPTIONS[settingsEntry.SELECTED].humanReadable)
                m.arrMenuEntries.push(menuEntry)
            end for

            m.view = SettingsMenuView({
                parentContainer: properties.parentContainer,
                x: 64,
                y: 50,
                initProperties: {
                    controller: m,
                    arrMenuEntries: m.arrMenuEntries
                }
            })
        end function
    }

    this.init(properties)

    return this

end function
