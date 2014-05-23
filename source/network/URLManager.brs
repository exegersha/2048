function URLManager (properties = {} as Object) as Object
    globalAA = GetGLobalAA()

    if (globalAA.urlMngrInstance = invalid)

        this = {
            urlConstants: Constants().URLS,
            urlDefaults: Defaults().SETTINGS,

            ' This must be overriden with the properties parameters
            versionNumber: invalid,

            ' Environment constants
            CLIENT_API: invalid,
            SERVICES_API: invalid,

            ' Selected environment
            ENVIRONMENT: invalid,
            STATIC_ENVIRONMENT: invalid,

            ' Static URL:s
            STATIC_DATA_URL: invalid,

            ' Dynamic endpoints
            CLIENT_BACKEND: "",

            getServiceAPIUrl: function () as String
                return m.SERVICES_API
            end function,

            getClientAPIUrl: function () as String
                return m.CLIENT_API
            end function,

            getStaticDataUrl: function () as String
                return m.STATIC_DATA_URL
            end function,

            init: function () as Boolean
                if(m.versionNumber = invalid)
                    print " /!\/!\ URLManager failed to initialise: version number was not defined /!\/!\ "
                    return false
                end if

                ' Set up DYNAMIC environment
                if (m.ENVIRONMENT = m.urlConstants.ENV.PRODUCTION OR m.ENVIRONMENT = m.urlConstants.ENV.STAGE)

                    m.CLIENT_API = m.urlConstants.PROTOCOL.HTTP + m.urlConstants.SUB_DOMAINS.CLIENT + m.ENVIRONMENT
                    m.SERVICES_API = m.urlConstants.PROTOCOL.HTTPS + m.urlConstants.SUB_DOMAINS.SERVICES + m.ENVIRONMENT

                else
                    m.CLIENT_API = m.urlConstants.PROTOCOL.HTTP + m.urlConstants.SUB_DOMAINS.CLIENT + m.ENVIRONMENT
                    m.SERVICES_API = m.urlConstants.PROTOCOL.HTTP + m.urlConstants.SUB_DOMAINS.SERVICES + m.ENVIRONMENT
                end if

                m.buildUrls()

                return true
            end function,

            buildUrls: function ()

                ' Set up STATIC environment
                m.STATIC_DATA_URL = m.urlConstants.PROTOCOL.HTTP + m.urlConstants.STATIC.BASE + m.STATIC_ENVIRONMENT + "app/" + m.versionNumber.SHORT + "/"

                ' Set up client API URL
                m.CLIENT_BACKEND = m.CLIENT_API + m.ENVIRONMENT

                ' ...
                ' ...
            end function
        }

        ' Setting defaults
        this.ENVIRONMENT = this.urlDefaults.ENVIRONMENT
        this.STATIC_ENVIRONMENT = this.urlDefaults.STATIC_ENVIRONMENT

        this.CLIENT_API = this.urlConstants.PROTOCOL.HTTP + this.urlConstants.SUB_DOMAINS.CLIENT + this.urlConstants.ENV.PRODUCTION
        this.SERVICES_API = this.urlConstants.PROTOCOL.HTTPS + this.urlConstants.SUB_DOMAINS.SERVICES + this.urlConstants.ENV.PRODUCTION

        ' Overriding defaults with configuration parameters
        for each property in properties
            this.AddReplace(property, properties[property])
        end for

        if (this.init())
            globalAA.urlMngrInstance = this
        else
            globalAA.delete("urlMngrInstance")
        end if
    end if

    return globalAA.urlMngrInstance

end function
