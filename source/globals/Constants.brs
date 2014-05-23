function Constants ()
    consts = {
        URLS: {
            ' Protocols
            PROTOCOL: {
                HTTP: "http://",
                HTTPS: "https://"
            },

            ' Sub-domains
            SUB_DOMAINS: {
                CLIENT: "client.",
                SERVICES: "services."
            },

            ' Environments
            ENV: {
                PRODUCTION: "production.com/",
                INTEGRATION: "integration.com/",
                QUALITY: "quality.com/",
                STAGE: "stage.com/"
            },

            ' Static data
            STATIC: {
                BASE: "roku.com/",
                PRODUCTION: "prod/",
                STAGE: "stage/"
            }
        },
        KEY_COMBO: {
            ' SETTINGS: [13, 5, 6, 3, 2, 10] ' PLAY, RIGHT, OK, DOWN, UP, STAR (PROD US)
            SETTINGS: [13, 13, 13, 13, 13, 13] ' PLAY x6
        }
    }

    return consts
end function
