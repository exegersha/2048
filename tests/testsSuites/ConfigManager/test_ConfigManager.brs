' UTILITY METHODS

function configManagerTestsSetup() as Object
    globalAA = getGLobalAA()

    globalAA.configData = {
        CONFIG: {
            keyA: "valueA",
            keyB: "valueB",
            keyC: "valueC",
        },
        DEFAULTS: {
            REGISTRY_SECTION: "CONFIG",
            Foo: "Bar",
            Baz: "Wie"
        },
        GENERATED_CONFIG: {}
    }

    globalAA.configData.GENERATED_CONFIG = Clone(globalAA.configData.DEFAULTS)
    for each property in globalAA.configData.CONFIG
        globalAA.configData.GENERATED_CONFIG.AddReplace(property, globalAA.configData.CONFIG[property])
    end for

    globalAA.cgm = ConfigManager()

    ' Overriding the RGM with the mock one
    globalAA.cgm.rgm = MockRegistryManager()

    return globalAA
end function

function configManagerTestsTearDown() as Void
    globalAA = getGLobalAA()

    globalAA.cgm = invalid
    globalAA.configData = invalid
    globalAA.delete("mockRegistryManagerInstance")
    globalAA.delete("configManagerInstance")
end function



' TESTS START HERE
' TESTS FOR THE init METHOD

function testInitNoConfig(t as Object) as Void
    globalAA = configManagerTestsSetup()

    ' Override actual defaults
    globalAA.cgm.defaultSettings = globalAA.configData.DEFAULTS

    globalAA.readConfigMethodCallCount = 0
    globalAA.prevReadConfigMethod = globalAA.cgm.readConfig

    globalAA.cgm.readConfig = function (url = "" as String) as Object
        globalAA = GetGlobalAA()
        globalAA.readConfigMethodCallCount = globalAA.readConfigMethodCallCount + 1
        globalAA.cgm.readConfig = globalAA.prevReadConfigMethod
        return globalAA.cgm.readConfig()
    end function

    globalAA.cgm.init()

    t.assertEqual(globalAA.readConfigMethodCallCount, 1)
    t.assertEqual(countObjectProperties(globalAA.cgm.config), countObjectProperties(globalAA.configData.DEFAULTS))

    configManagerTestsTearDown()
end function

function testInitWithConfig(t as Object) as Void
    globalAA = configManagerTestsSetup()

    ' Setup mock data
    globalAA.cgm.rgm.setMockData(globalAA.configData)
    ' Override actual defaults
    globalAA.cgm.defaultSettings = globalAA.configData.DEFAULTS

    globalAA.readConfigMethodCallCount = 0
    globalAA.prevReadConfigMethod = globalAA.cgm.readConfig

    globalAA.cgm.readConfig = function (url = "" as String) as Object
        globalAA = GetGlobalAA()
        globalAA.readConfigMethodCallCount = globalAA.readConfigMethodCallCount + 1
        globalAA.cgm.readConfig = globalAA.prevReadConfigMethod
        return globalAA.configData.CONFIG
    end function

    globalAA.cgm.init()

    t.assertEqual(globalAA.readConfigMethodCallCount, 1)
    t.assertEqual(globalAA.cgm.config, globalAA.configData.GENERATED_CONFIG)

    configManagerTestsTearDown()
end function



' ' TESTS FOR THE readConfig METHOD

function testReadConfig(t as Object) as Void
    globalAA = configManagerTestsSetup()

    ' Setup mock data
    globalAA.cgm.rgm.setMockData(globalAA.configData)
    globalAA.cgm.configRegistryKey = globalAA.configData.DEFAULTS.REGISTRY_SECTION

    config = globalAA.cgm.readConfig()

    t.assertEqual(globalAA.cgm.rgm.getMethodCallCount("readAll"), 1)
    t.assertEqual(config, globalAA.configData.CONFIG)

    configManagerTestsTearDown()
end function



' ' TESTS FOR THE writeConfig METHOD

function testWriteConfigNoParams(t as Object) as Void
    globalAA = configManagerTestsSetup()

    globalAA.cgm.configRegistryKey = globalAA.configData.DEFAULTS.REGISTRY_SECTION
    config = globalAA.cgm.writeConfig()

    t.assertEqual(globalAA.cgm.rgm.getMethodCallCount("writeAll"), 0)

    configManagerTestsTearDown()
end function

function testWriteConfig(t as Object) as Void
    globalAA = configManagerTestsSetup()

    globalAA.cgm.configRegistryKey = globalAA.configData.DEFAULTS.REGISTRY_SECTION
    config = globalAA.cgm.writeConfig(globalAA.configData.CONFIG)

    t.assertEqual(globalAA.cgm.rgm.getMethodCallCount("writeAll"), 1)

    configManagerTestsTearDown()
end function

function testWriteConfigNoParamsDoesntOverride(t as Object) as Void
    globalAA = configManagerTestsSetup()
    globalAA.cgm.configRegistryKey = globalAA.configData.DEFAULTS.REGISTRY_SECTION

    ' Setup/fake previous config
    globalAA.cgm.config = globalAA.configData.CONFIG
    config = globalAA.cgm.writeConfig()

    t.assertEqual(globalAA.cgm.rgm.getMethodCallCount("writeAll"), 0)
    t.assertEqual(globalAA.cgm.config, globalAA.configData.CONFIG)

    configManagerTestsTearDown()
end function

function testWriteConfigOverride(t as Object) as Void
    globalAA = configManagerTestsSetup()

    globalAA.cgm.configRegistryKey = globalAA.configData.DEFAULTS.REGISTRY_SECTION
    ' Setup/fake previous config
    globalAA.cgm.config = globalAA.configData.CONFIG

    ' Creating some overrides
    newConfig = globalAA.configData.CONFIG
    newConfig.keyB = "newKeyB"
    newConfig.keyD = "keyD"

    config = globalAA.cgm.writeConfig(newConfig)
    t.assertEqual(globalAA.cgm.config, newConfig)

    t.assertEqual(globalAA.cgm.rgm.getMethodCallCount("writeAll"), 1)

    configManagerTestsTearDown()
end function



' ' TESTS FOR THE getConfig METHOD

function testGetConfigUninitialised(t as Object) as Void
    globalAA = configManagerTestsSetup()

    config = globalAA.cgm.getConfig()

    t.assertEqual(config, {})

    configManagerTestsTearDown()
end function

function testGetConfig(t as Object) as Void
    globalAA = configManagerTestsSetup()

    ' Setup mock data
    globalAA.cgm.rgm.setMockData(globalAA.configData)
    ' Override actual defaults
    globalAA.cgm.defaultSettings = globalAA.configData.DEFAULTS

    globalAA.cgm.init()
    config = globalAA.cgm.getConfig()

    t.assertEqual(config, globalAA.configData.GENERATED_CONFIG)

    configManagerTestsTearDown()
end function

' ' TESTS FOR THE loadDefaults METHOD

function testLoadDefaults(t as Object) as Void
    globalAA = configManagerTestsSetup()

    globalAA.cgm.defaultSettings = globalAA.configData.DEFAULTS
    config = globalAA.cgm.loadDefaults()

    t.assertEqual(config, globalAA.configData.DEFAULTS)

    configManagerTestsTearDown()
end function
