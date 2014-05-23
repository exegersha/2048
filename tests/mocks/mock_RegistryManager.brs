function MockRegistryManager() as Object

    if(m.mockRegistryManagerInstance = invalid)

        classDefinition = {

            TOSTRING: "<MockRegistryManager>"

            mockData: {}

            setMockData: function(data={} as Object)
                m.mockData = data
            end function

            '  MOCKED METHODS

            write: function(key=invalid as Dynamic, value=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Void

                m.storeMethodCall("write", { key: key, value: value, section: section})

            end function

            ' Writes the object to the registry under the specified section
            writeAll: function(registryList=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Void

                m.storeMethodCall("writeAll", { registryList: registryList, section: section})

            end function

            ' Returns the value for the specified key and section from the registry
            read: function(key=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Dynamic
                value = invalid

                m.storeMethodCall("read", { key: key, section: section})

                if (key <> invalid) AND (type(key) = "roString") AND (m.mockData[section] <> invalid)
                    value = m.mockData[section][key]
                end if

                return value
            end function

            ' Returns the full registry content for the specified section in an object
            readAll: function(section=m.DEFAULT_SECTION as String) as Object

                m.storeMethodCall("readAll", { section: section})

                if (m.mockData[section] = invalid)
                    return {} ' This is what the actual readAll return on invalid ("" empty) section
                else
                    return m.mockData[section]
                end if
            end function

            ' Deletes a value from the registry
            remove: function(key=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Void

                m.storeMethodCall("remove", { key: key, section: section})

            end function

            ' Deletes an entire section from the registry
            removeAll: function(section=m.DEFAULT_SECTION as String) as Void

                m.storeMethodCall("removeAll", { section: section})

            end function

            ' Checks if a key exists in registry under the specified section
            exists: function(key=invalid as Dynamic, section=m.DEFAULT_SECTION as String) as Boolean

                m.storeMethodCall("exists", { key: key, section: section})

                present = false

                if (key <> invalid) AND (type(key) = "roString") AND (m.mockData[section] <> invalid)
                    value = m.mockData[section].DoesExist(key)
                end if

                return present
            end function

        }

        m.mockRegistryManagerInstance = BaseMock(classDefinition)

    end if

    return m.mockRegistryManagerInstance

end function
