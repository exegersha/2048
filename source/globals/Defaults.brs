function Defaults ()
    consts = Constants()

    return {
        SETTINGS: {
            REGISTRY_SECTION: "2048CONFIG"
            ENVIRONMENT: consts.URLS.ENV.PRODUCTION
            STATIC_ENVIRONMENT: consts.URLS.STATIC.PRODUCTION
        	SCORE: "0" 		'Registry Write() expects String values
        	BEST_SCORE: "0"	'Registry Write() expects String values
            GAME_MATRIX: "" 'String representig gameMaxtrix rows from left-to-right and top-down'
        }
    }
end function
