' UTILITY METHODS

function urlManagerTestsSetup() as Object
    globalAA = GetGlobalAA()
    globalAA.delete("urlMngrInstance")

    m.versionNumber = {
        SHORT: "0.0",
        MEDIUM: "0.0.0",
        EXTENDED: "0.0.0.123456"
    }

    return globalAA
end function

function urlManagerTestsTearDown() as Void
    globalAA = GetGlobalAA()
    globalAA.delete("urlMngrInstance")
    m.versionNumber = invalid
end function


' TESTS START HERE

' This ensures that the urlManager doesn't initialise
'   if no version number is passed.
function testNoVersion (t as Object)
    urlManagerTestsSetup()
    consts = Constants().URLS

    settings = MergeObjects(consts, {})
    urlMgr = URLManager(settings)

    t.assertInvalid(urlMgr)

    urlManagerTestsTearDown()
end function

' This ensures the default URLs are the production ones
function testDefaults (t as Object)
    urlManagerTestsSetup()
    consts = Constants().URLS

    settings = MergeObjects(consts, {versionNumber: m.versionNumber})
    urlMgr = URLManager(settings)

    t.assertNotInvalid(urlMgr)
    t.assertEqual("https://services.com/", urlMgr.getServiceAPIUrl())
    t.assertEqual("http://client.com/", urlMgr.getClientAPIUrl())
    t.assertEqual("http://roku.static.com/prod/app/0.0/", urlMgr.getStaticDataUrl())

    urlManagerTestsTearDown()
end function

' This ensures the correct urls are set when explicitly
'   setting the environment to PROD
function testPRODEnvironment (t as Object)
    urlManagerTestsSetup()
    consts = Constants().URLS

    overrides = {
        versionNumber: m.versionNumber,
        ENVIRONMENT: consts.ENV.PRODUCTION
    }

    settings = MergeObjects(consts, overrides)
    urlMgr = URLManager(settings)

    t.assertNotInvalid(urlMgr)
    t.assertEqual("https://services.com/", urlMgr.getServiceAPIUrl())
    t.assertEqual("http://client.com/", urlMgr.getClientAPIUrl())
    t.assertEqual("http://roku.static.com/prod/app/0.0/", urlMgr.getStaticDataUrl())

    urlManagerTestsTearDown()
end function

' This ensures the correct urls are set when explicitly
'   setting the environment to INTEGRATION
function testINTEGRATIONEnvironment (t as Object)
    urlManagerTestsSetup()
    consts = Constants().URLS

    overrides = {
        versionNumber: m.versionNumber,
        ENVIRONMENT: consts.ENV.INTEGRATION
    }

    settings = MergeObjects(consts, overrides)
    urlMgr = URLManager(settings)

    t.assertNotInvalid(urlMgr)
    t.assertEqual("http://services.integration.com/", urlMgr.getServiceAPIUrl())
    t.assertEqual("http://client.integration.com/", urlMgr.getClientAPIUrl())
    t.assertEqual("http://roku.static.com/prod/app/0.0/", urlMgr.getStaticDataUrl())

    urlManagerTestsTearDown()
end function

' This ensures the correct urls are set when explicitly
'   setting the static data environment to PROD, as a
'   way to check that nothing changed from DEFAULTS
function testPRODStaticEnvironment (t as Object)
    urlManagerTestsSetup()
    consts = Constants().URLS

    overrides = {
        versionNumber: m.versionNumber,
        STATIC_ENVIRONMENT: consts.STATIC.PRODUCTION
    }

    settings = MergeObjects(consts, overrides)
    urlMgr = URLManager(settings)

    t.assertNotInvalid(urlMgr)
    t.assertEqual("https://services.com/", urlMgr.getServiceAPIUrl())
    t.assertEqual("http://client.com/", urlMgr.getClientAPIUrl())
    t.assertEqual("http://roku.static.com/prod/app/0.0/", urlMgr.getStaticDataUrl())

    urlManagerTestsTearDown()
end function

' This ensures the correct urls are set when explicitly
'   setting the static data environment to STAGE, as a
'   way to check the override on sTATIC DATA
function testSTAGEStaticEnvironment (t as Object)
    urlManagerTestsSetup()
    consts = Constants().URLS

    overrides = {
        versionNumber: m.versionNumber,
        STATIC_ENVIRONMENT: consts.STATIC.STAGE
    }

    settings = MergeObjects(consts, overrides)
    urlMgr = URLManager(settings)

    t.assertNotInvalid(urlMgr)
    t.assertEqual("https://services.com/", urlMgr.getServiceAPIUrl())
    t.assertEqual("http://client.com/", urlMgr.getClientAPIUrl())
    t.assertEqual("http://roku.static.com/stage/app/0.0/", urlMgr.getStaticDataUrl())

    urlManagerTestsTearDown()
end function
