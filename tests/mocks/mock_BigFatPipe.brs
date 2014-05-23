function MockBigFatPipe() as Object

    if(m.mockBigFatPipeInstance = invalid)

        classDefinition = {

            TOSTRING: "<MockBigFatPipe>"
            mockDataPath: "pkg://source/mocks/data/net.json"

            ' Default response data if no mock data is set
            '   as part of a test
            nextResponseData: {
                url: ""
                body:"",
                headers: []
            }

            ' Property used to fail the next request with
            '   this specific code. Should be an HTTP error code
            '   or a code from http://sdkdocs.roku.com/display/sdkdoc/roUrlEvent
            failCode: invalid



            '  UTILITY METHODS
            initMockData: function() as Void
                rawData = ReadASCIIFile(m.mockDataPath)
                m.mockData = ParseJSON(rawData)
            end function

            failNext: function(code=404 as Integer)
                m.failCode = code
            end function

            setNextResponseData: function(dataId="" as String)
                if (dataId <> "") AND (m.mockData[dataId] <> invalid)
                    m.nextResponseData = m.mockData[dataId]
                end if
            end function



            '  MOCKED METHODS

            load: function(urlReq as Object, destination as Object, successCallback as String, failCallback as String)

                m.storeMethodCall("load", { urlReq: urlReq, destination: destination, successCallback: successCallback, failCallback: failCallback })

                if (not urlReq.url.instr("pkg://") = -1)
                    'internal file
                    ldo = LoaderDataObject(urlReq.url, ReadAsciiFile(urlReq.url), 200)
                    destination[successCallback](ldo)
                else
                    ' get here the data associated for a request
                    reqData = m.nextResponseData

                    if (m.failCode <> invalid)
                        ldo = LoaderDataObject(urlReq.url, reqData.body, m.failCode, reqData.headers)
                        destination[failCallback](ldo)
                        m.failCode = invalid
                    else
                        ldo = LoaderDataObject(urlReq.url, reqData.body, 200, reqData.headers)
                        destination[successCallback](ldo)
                    end if
                end if

            end function

            init: function( msgPort as Object, maxConnections as Integer )
                m.storeMethodCall("init", { msgPort: msgPort, maxConnections: maxConnections })
                ' The mock init method does not need to do anything since it's
                '   only used in the real class to setup message port, connections
                '   and max connections.
                ' We don't need any of this in this mock
            end function

            processRequests: function()
                m.storeMethodCall("processRequests")
                ' The mock processRequests method will never be called as
                '   it's used in the real class only to iterate through
                '   active and idle connections
            end function

            processMessage: function(msg as Object) as Void
                m.storeMethodCall("processMessage", { msg: msg})
                ' The mock processMessage method will never be called as
                '   it's used in the real class only to process Stage() messages
            end function

            addToIdle: function (connection as Object) as Void
                m.storeMethodCall("addToIdle", { connection: connection})
                ' The mock addToIdle method will never be called as
                '   it's used in the real class only to manage max connections
            end function

            cancel: function(url as String) as Void
                m.storeMethodCall("cancel", { url: url})
                ' The mock cancel method does nothing else as mock requests
                '   are processed straight away.
            end function
        }

        mock = BaseMock(classDefinition)
        mock.initMockData()

        m.mockBigFatPipeInstance = mock

    end if

    return m.mockBigFatPipeInstance

end function
