'/////////////////////////////////////////////////////
'//
'// Application initialisation
'//
'// Responsible for initialising all core dependency
'//     components for other elements of the app.
'// This includes setting-up application constants.
'//     application version, configuration and other
'//     utilities.
'//
'/////////////////////////////////////////////////////
function appInit() as Void

    ' ## Initialising application constants
    m.constants = Constants()
    m.constants.APP = GetAppVersion()

    ' ## Initialising dependencies
    m.regm = RegistryManager()
    m.focusMngr = FocusManager()
    m.confm = configManager()
    m.net = Net()
    m.messageBus = MessageBus()
    m.keyCmbMngr = KeyComboManager()
    m.stage = Stage()

    ' ## Loading configuration from registry, if present, otherwise returns app defautls.
    m.confm.init()
    config = m.confm.getConfig()

    ' ## Adding current app version number
    '   This cannot be in the registry config, as it's
    '   dependent on the code.
    config.versionNumber = m.constants.APP.VERSION_NUMBER

    ' ## Initialising the URLs manager so our app
    '   targets specific environments, both for
    '   client API and static data. Any override
    '   will be done automatically within the
    '   URLManager providing that the keys in the
    '   config match the properties in the URLManager
    m.urlMgr = URLManager(config)

    ' ## Registering the close event listener and
    '   handler. This will be used only when pressing
    '   the back button from the main scene.
    m.messageBus.addEventListener({
        context: m,
        eventType: "closeApp",
        handler: "closeAppHandler"
    })

    m.closeAppHandler = function (eventObj as Object)
        m.stage.closeApp()
    end function

    ' Only enable settings view if it is NOT release build.
    if NOT (m.constants.APP.RELEASE_BUILD)
        ' Where should the keyCombo callback be placed?
        m.tmpSettingsCbk = function ()
            m.focusMngr.setFocus(SettingsController({
                parentContainer: m.stage
                }))
        end function

        m.keyCmbMngr.add(m.constants.KEY_COMBO.SETTINGS, m, "tmpSettingsCbk")
    end if

    m.focusMngr.setFocus(MainScene({
                parentContainer: m.stage
                }))

    ' ## Starting the main app loop
    m.stage.start() 'This is commented out for now, because we don't have a way to exit the app yet, and no visual components either.
end function
