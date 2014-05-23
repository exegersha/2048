function ConfigManager () as Object
    if (m.configManagerInstance = invalid)

        mgr = {
            id: "configManagerInstance",

            ' dependencies
            rgm: RegistryManager(),
            defaultSettings: Defaults().SETTINGS,

            ' properties
            configRegistryKey: "",
            config: {},

            init: function () as Void
                m.configRegistryKey = m.defaultSettings.REGISTRY_SECTION
                defaultConf = m.loadDefaults()
                regConf = m.readConfig()

                ' Override defaults with registry values
                if (regConf <> invalid)
                    for each property in regConf
                        defaultConf.AddReplace(property, regConf[property])
                    end for
                end if

                if (defaultConf <> invalid)
                    m.config = defaultConf
                end if
            end function,

            loadDefaults: function () as Object
                return m.defaultSettings
            end function,

            readConfig: function () as Object
                return m.rgm.readAll(m.configRegistryKey)
            end function,

            writeConfig: function (newConfig = invalid as Dynamic) as Void
                if (newConfig <> invalid)
                    m.rgm.writeAll(newConfig, m.configRegistryKey)
                    m.config = newConfig
                end if
            end function,

            getConfig: function () as Object
                return m.config
            end function
        }

        m.configManagerInstance = mgr
    end if

    return m.configManagerInstance
end function

