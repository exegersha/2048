function Defaults ()
    consts = Constants()

    return {
        SETTINGS: {
            REGISTRY_SECTION: "CONFIG",
            ENVIRONMENT: consts.URLS.ENV.PRODUCTION,
            STATIC_ENVIRONMENT: consts.URLS.STATIC.PRODUCTION
        }
    }
end function
