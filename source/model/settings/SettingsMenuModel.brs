'
' Model used to manage and manipulate the app configs
' displayed in the SettingsMenuView, read from the registry
' using the ConfigManager to read and write.
'
' @return {Object} SettingsMenuModel, the actual settings menu model as a SINGLETON.
'
function SettingsMenuModel () as Object

    if (m.settingsMenuModelInstance = invalid)
        cfgMngr = ConfigManager()

        m.settingsMenuModelInstance = {
            TOSTRING: "<SettingsMenuModel>"
            cfgMngr: cfgMngr
            defaultSettings: Defaults().SETTINGS
            currentSettings: cfgMngr.getConfig()

            ' Setting Menu MODEL structure:
            ' {
            '     ENVIRONMENT: {
            '         OPTIONS: [{
            '             humanReadable: "stage",
            '             stage: "someValue2"
            '         }, {
            '             humanReadable: "prod",
            '             prod: "someValue1"
            '         }],
            '         SELECTED: 0
            '     },
            '     ...
            '     ...
            ' }
            settingsModel: {}

            ' Gets the settings model.
            ' @return {Object} the settings model.
            getMenu: function () as Object
                return m.settingsModel
            end function

            ' Gets menu entry specified by key.
            ' @param {String} key, the menu entry to get.
            ' @return {Object} the complete menu entry.
            getMenuEntry: function (key as String) as Object
                return m.settingsModel[key]
            end function

            ' Gets the previous option for as specified menu entry.
            ' @param {String} key, the menu entry to get previous option of.
            ' @return {String} a human readable representation of the previous menu option.
            getPreviousMenuEntryOption: function (key as String) as String
                index = m.settingsModel[key].SELECTED - 1

                ' Loop the options if we reach the beginning.
                if (index < 0)
                    index = m.settingsModel[key].OPTIONS.count() - 1
                end if

                m.settingsModel[key].SELECTED = index

                return m.settingsModel[key].OPTIONS[index].humanReadable
            end function

            ' Gets the next option for as specified menu entry.
            ' @param {String} key, the menu entry to get next option of.
            ' @return {String} a human readable representation of the next menu option.
            getNextMenuEntryOption: function (key as String) as String
                index = m.settingsModel[key].SELECTED + 1

                ' Loop the options if we reach the end.
                if (index > m.settingsModel[key].OPTIONS.count() - 1)
                    index = 0
                end if

                m.settingsModel[key].SELECTED = index

                return m.settingsModel[key].OPTIONS[index].humanReadable
            end function

            ' Gets the full app version.
            ' @return {String} the extended version of the app version number (e.g. Major.Minor.BuildVersion.BuildTime)
            getAppVersion: function () as String
                return m.currentSettings.versionNumber.extended
            end function

            ' Updates the OPTION SELECTED in the menu entry for key passed by argument.
            ' @param {AssocArr} menuEntry, array containing the available options
            ' @param {String} key, the option to set as SELECTED
            setSelectedSetting: function (menuEntry, key)
                options = menuEntry.OPTIONS
                length = options.count()
                index = 0

                for i = index to length - 1 step 1
                    if (options[i][options[i].humanReadable] = key)
                        index = i
                        i = length
                    end if
                end for

                menuEntry.SELECTED = index
            end function

            ' Resets all settings to the app defaults and dispatches an event,
            ' passing the updated settings model as payload.
            resetToDefauls: function () as Void
                for each key in m.settingsModel
                    m.setSelectedSetting(m.settingsModel[key], m.defaultSettings[key])
                end for

                MessageBus().dispatchEvent(Event({
                    eventType: "onSettingsResetToDefaults",
                    target: m,
                    payload: {
                        settingsModel: m.settingsModel
                    }
                }))
            end function

            ' Builds an Object out of the settingsModel to pass to the ConfigManager to write to the registry.
            writeSettings: function () as Void
                newConfig = {}
                for each key in m.settingsModel
                    menuEntry = m.settingsModel[key]
                    optionSelected = menuEntry.OPTIONS[menuEntry.SELECTED]
                    newConfig[key] = optionSelected[optionSelected.humanReadable]
                end for
                m.cfgMngr.writeConfig(newConfig)
            end function

            'PRIVATE Methods

            ' Creates the initial settings menu model
            createMenu: function () as Void
                ' Creates menu options form an associative array and
                ' adds each KEY available in the menu entry as a literal (human readable)
                ' @param {AssocArr} assocArr, array containing the available options for one menu entry
                ' @return {Array} arr, E.g. [{
                '   humanReadable: "stage",
                '   stage: "someValue2"
                ' }, ...]
                createOptions = function (assocArr as Object) as Object
                    arr = []
                    if (assocArr <> invalid)
                        for each k in assocArr
                            obj = {
                                humanReadable: k
                            }
                            obj[k] = assocArr[k]
                            arr.push(obj)
                        end for
                    end if

                    return arr
                end function

                ' ENVIRONMENT
                menuEntry = {
                    ENVIRONMENT: {
                        OPTIONS: createOptions(Constants().URLS.ENV),
                        SELECTED: 0
                    }
                }
                m.setSelectedSetting(menuEntry.ENVIRONMENT, m.currentSettings.ENVIRONMENT)
                m.settingsModel.append(menuEntry)

                ' STATIC_ENVIRONMENT
                menuEntry = {
                    STATIC_ENVIRONMENT: {
                        OPTIONS: createOptions({
                            PRODUCTION: Constants().URLS.STATIC.PRODUCTION,
                            STAGE: Constants().URLS.STATIC.STAGE
                        })
                        SELECTED: 0
                    }
                }
                m.setSelectedSetting(menuEntry.STATIC_ENVIRONMENT, m.currentSettings.STATIC_ENVIRONMENT)
                m.settingsModel.append(menuEntry)

                ' REGISTRY_SECTION
                menuEntry = {
                    REGISTRY_SECTION: {
                        OPTIONS: createOptions({
                            CONFIG: m.currentSettings.REGISTRY_SECTION
                        })
                        SELECTED: 0
                    }
                }
                m.setSelectedSetting(menuEntry.REGISTRY_SECTION, m.currentSettings.REGISTRY_SECTION)
                m.settingsModel.append(menuEntry)
            end function

            init: function () as Void
                m.createMenu()
            end function
        }

        m.settingsMenuModelInstance.init()
    end if

    return m.settingsMenuModelInstance
end function
