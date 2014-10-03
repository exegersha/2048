'' KeyComboManager.brs


function KeyComboManager() as Object

    if(m.keyComboManagerInstance = invalid)

        this = {}

        ' STATIC PROPERTIES
        this.TOSTRING = "<KeyComboManager>"
        this.COMBO_LENGTH = 6 ' all key combos should be this long

        ' PROPERTIES
        this.keyHistory = []
        this.keyCombos = {}

        ' METHODS
        this.add = function(keyCombo=invalid as Dynamic, destination=invalid as Dynamic, callback="" as String) as Void

            if(keyCombo = invalid) OR (destination = invalid) OR (callback = "") return
            if(keyCombo.count() <> m.COMBO_LENGTH) return

            ' combine keys into a string
            keyString = m.createKeyString(keyCombo)

            m.keyCombos.addReplace(keyString,{destination:destination, callback:callback})

        end function

        this.remove = function(keyCombo=invalid as Dynamic) as Void

            if (keyCombo = invalid) return

            ' combine keys into a string
            keyString = m.createKeyString(keyCombo)

            if (m.keyCombos.doesExist(keyString))
                m.keyCombos.delete(keyString)
            end if

        end function

        this.createKeyString = function(keyCombo=[] as Object) as String
            keyString = ""
            for each key in keyCombo
                if (type(key) = "roInteger")
                    keyString = keyString + Str(key)
                end if
            end for

            return keyString
        end function

        this.processKey = function(keyCode=invalid as Dynamic) as Void

            ' The following checks have been commented out because they would
            '   be executed on EVERY key press.
            ' While this would be nice to ensure the method is bomproof
            '   it is totally unnecessary since it will *only* be used in a call
            '   from the main loop in Stage(), upon reception of a keyPress
            '   message port event. This will *always* send a roInteger, so
            '   these checks are kind of unnecessary.
            if (keyCode = invalid) 'OR NOT (GetInterface(keyCode, "ifInt") <> invalid AND (Type(keyCode) = "roInt" OR Type(keyCode) = "roInteger" OR Type(keyCode) = "Integer"))
                return
            end if

            check = false
            m.keyHistory.push(keyCode)

            if(m.keyHistory.count() = m.COMBO_LENGTH)
                ' check
                check = true

            else if(m.keyHistory.count() > m.COMBO_LENGTH)
                ' shift and check
                m.keyHistory.shift()
                check = true

            end if

            if (check)
                keyString = m.createKeyString(m.keyHistory)
                callbackObject = m.keyCombos.lookup(keyString)
                'print m.TOSTRING; " processKey: "; keyString

                if(callbackObject <> invalid)
                    d = callbackObject.destination
                    if(d <> invalid)
                        c = callbackObject.callback
                        if(d[c] <> invalid) ' callback function found and called
                            d[c]()
                            m.keyHistory.clear() ' clear the history for next combo
                        end if
                    end if
                end if
            end if

        end function

        m.keyComboManagerInstance = this

    end if

    return m.keyComboManagerInstance

end function
