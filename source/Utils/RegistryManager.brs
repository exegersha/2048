function RegistryManager () as Object

    if (m.registryManager = invalid )
        m.registryManager = {

            TOSTRING: "<RegistryManager>"

            DEFAULT_SECTION: "DEFAULT_SECTION"

            ' Writes the entry <key, value> to the registry under the specified section
            write: function(key=invalid as Dynamic, value=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Void

                if (key <> invalid) AND (type(key) = "roString" OR (type(key) = "String")) AND (value <> invalid) AND (type(value) = "roString" OR (type(value) = "String"))

                    RegWrite(key, value, section)
                end if
            end function

            ' Writes the object to the registry under the specified section
            writeAll: function(registryList=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Void

                if (registryList <> invalid AND type(registryList) = "roAssociativeArray")
                    for each regEntry in registryList
                        RegWrite(regEntry, registryList[regEntry], section)
                    end for
                end if
            end function

            ' Returns the value for the specified key and section from the registry
            read: function(key=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Dynamic
                value = invalid

                if (key <> invalid) AND (type(key) = "roString" OR (type(key) = "String"))
                    value = RegRead(key, section)
                end if

                return value
            end function

            ' Returns the full registry content for the specified section in an object
            readAll: function(section=m.DEFAULT_SECTION as String) as Object
                keyList = RegKeyList(section)
                registryList = {}

                for each key in keyList
                    value = RegRead(key, section)
                    registryList[key] = value
                end for

                return registryList
            end function

            ' Deletes a value from the registry
            remove: function(key=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Void
                if (key <> invalid)
                    RegDelete(key, section)
                end if
            end function

            ' Deletes an entire section from the registry
            removeAll: function(section=m.DEFAULT_SECTION as String) as Void
                keyList = RegKeyList(section)
                for each key in keyList
                    m.remove(key, section)
                end for
            end function

            ' Checks if a key exists in registry under the specified section
            exists: function(key=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Boolean

                present = false

                if (key <> invalid)
                    present = RegKeyExists(key, section)
                end if

                return present
            end function
        }
    end if

    return m.registryManager

end function
