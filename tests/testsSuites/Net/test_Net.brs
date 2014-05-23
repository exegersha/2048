' UTILITY METHODS

function netTestsSetup() as Object
    globalAA = GetGlobalAA()
    globalAA.delete("netInstance")

    globalAA.netTestsHandler = {
        success: function(data as Object) as Void
            GetGlobalAA().netResults.successCount = GetGlobalAA().netResults.successCount + 1
            GetGlobalAA().netResults.response = data
        end function

        failure: function(data as Object) as Void
            GetGlobalAA().netResults.errorCount = GetGlobalAA().netResults.errorCount + 1
            GetGlobalAA().netResults.response = data
        end function
    }

    globalAA.netTestsParams = {
        fakeRequests: [
            {
                url: "http://faketesturl1.com",
                req: {
                    onComplete: {
                        destination: globalAA.netTestsHandler,
                        success: "success",
                        failed: "failure"
                    },
                    request: {}
                }
            },
            {
                url: "http://faketesturl2.com",
                req: {
                    onComplete: {
                        destination: globalAA.netTestsHandler,
                        success: "success",
                        failed: "failure"
                    },
                    request: {}
                }
            },
            {
                url: "http://faketesturl3.com",
                req: {
                    onComplete: {
                        destination: globalAA.netTestsHandler,
                        success: "success",
                        failed: "failure"
                    },
                    request: {}
                }
            }
        ],
        fakeHeaders: {}
    }

    globalAA.netTestsParams.fakeHeaders.AddReplace("Foo-Header", "Bar")
    globalAA.netTestsParams.fakeHeaders.AddReplace("Content-Type", "application/json")

    globalAA.net = Net()
    ' Overriding the BFP with the mock one
    globalAA.net.bigFatPipe = MockBigFatPipe()

    globalAA.netResults = {
        successCount: 0,
        errorCount: 0,
        response: ""
    }

    return globalAA
end function

function netTestsTearDown() as Void
    globalAA = GetGlobalAA()
    globalAA.delete("netInstance")
    globalAA.delete("netTestsHandler")
    globalAA.delete("mockBigFatPipeInstance")

    globalAA.netResults = {
        successCount: 0,
        errorCount: 0,
        response: ""
    }
end function

' TESTS START HERE
' TESTS FOR THE getData METHOD
' --------------------------------------------------------------------------------

function testGetDataNoFailWithoutParams(t as Object) as Void
    globalAA = netTestsSetup()

    t.assertEqual(globalAA.net.getData(), false)

    netTestsTearDown()
end function

function testGetDataNoUrl(t as Object) as Void
    globalAA = netTestsSetup()

    called = globalAA.net.getData({}, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    t.assertEqual(called, true)
    t.assertEqual(globalAA.netResults.errorCount, 1)
    t.assertEqual(globalAA.netResults.successCount, 0)

    netTestsTearDown()
end function

function testGetDataEmptyUrl(t as Object) as Void
    globalAA = netTestsSetup()

    called = globalAA.net.getData({
        url: ""
    }, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    t.assertEqual(called, true)
    t.assertEqual(globalAA.netResults.errorCount, 1)
    t.assertEqual(globalAA.netResults.successCount, 0)

    netTestsTearDown()
end function

function testGetDataWithDefaultHeaders(t as Object) as Void
    globalAA = netTestsSetup()

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"

    data = globalAA.net.bigFatPipe.mockData[mockDataId]

    globalAA.net.bigFatPipe.setNextResponseData(mockDataId)

    called = globalAA.net.getData({
        url: data.url
    }, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })


    lastCallArgs = globalAA.net.bigFatPipe.getLastMethodCallArguments("load")

    t.assertEqual(called, true)
    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("load"), 1)
    t.assertEqual(lastCallArgs.urlReq.url, data.url)
    t.assertEqual(lastCallArgs.urlReq.method, "GET")
    t.assertEqual(countObjectProperties(lastCallArgs.urlReq.requestHeaders), 1)
    t.assertEqual(lastCallArgs.destination.id, globalAA.net.id)

    netTestsTearDown()
end function

function testGetDataWithSpecifiedHeaders(t as Object) as Void
    globalAA = netTestsSetup()

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"

    data = globalAA.net.bigFatPipe.mockData[mockDataId]

    globalAA.net.bigFatPipe.setNextResponseData(mockDataId)

    reqObj = {
        url: data.url,
        headers: globalAA.netTestsParams.fakeHeaders
    }

    called = globalAA.net.getData(reqObj, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    lastCallArgs = globalAA.net.bigFatPipe.getLastMethodCallArguments("load")

    t.assertEqual(called, true)
    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("load"), 1)
    t.assertEqual(lastCallArgs.urlReq.url, data.url)
    t.assertEqual(lastCallArgs.urlReq.method, "GET")
    t.assertEqual(countObjectProperties(lastCallArgs.urlReq.requestHeaders), 3)
    t.assertEqual(lastCallArgs.destination.id, globalAA.net.id)

    netTestsTearDown()
end function

function testGetDataWithOverrideHeaders (t as Object) as Void
    globalAA = netTestsSetup()

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"

    data = globalAA.net.bigFatPipe.mockData[mockDataId]

    globalAA.net.bigFatPipe.setNextResponseData(mockDataId)

    reqObj = {
        url: data.url,
        headers: globalAA.netTestsParams.fakeHeaders
    }

    ' This most be a header already specified as a default header,
    ' for this test to make sense
    reqObj.headers.AddReplace("Accept", "application/xml")

    called = globalAA.net.getData(reqObj, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    lastCallArgs = globalAA.net.bigFatPipe.getLastMethodCallArguments("load")

    t.assertEqual(called, true)
    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("load"), 1)
    t.assertEqual(lastCallArgs.urlReq.url, data.url)
    t.assertEqual(lastCallArgs.urlReq.method, "GET")
    t.assertEqual(countObjectProperties(lastCallArgs.urlReq.requestHeaders), 3)
    t.assertEqual(lastCallArgs.urlReq.requestHeaders, reqObj.headers)
    t.assertEqual(lastCallArgs.destination.id, globalAA.net.id)

    netTestsTearDown()
end function

function testGetDataWithPreExistingRequest(t as Object) as Void
    globalAA = netTestsSetup()

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"

    data = globalAA.net.bigFatPipe.mockData[mockDataId]

    ' Setting up pre-existing request on the net instance
    globalAA.net.requestHandlers[data.url] = {}

    globalAA.cancelMethodCallCount = 0
    globalAA.prevCancelReqMethod = globalAA.net.cancelRequest

    globalAA.net.cancelRequest = function(url="" as String) as void
        globalAA = GetGlobalAA()
        globalAA.cancelMethodCallCount = globalAA.cancelMethodCallCount + 1
        globalAA.net.cancelRequest = globalAA.prevCancelReqMethod
        globalAA.net.cancelRequest(url)
    end function


    globalAA.net.bigFatPipe.setNextResponseData(mockDataId)

    called = globalAA.net.getData({
        url: data.url
    }, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    lastCallArgs = globalAA.net.bigFatPipe.getLastMethodCallArguments("load")

    t.assertEqual(called, true)
    t.assertEqual(globalAA.cancelMethodCallCount, 1)
    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("load"), 1)
    t.assertEqual(lastCallArgs.urlReq.url, data.url)
    t.assertEqual(lastCallArgs.urlReq.method, "GET")
    t.assertEqual(countObjectProperties(lastCallArgs.urlReq.requestHeaders), 1)
    t.assertEqual(lastCallArgs.destination.id, globalAA.net.id)

    netTestsTearDown()
end function


' TESTS FOR THE postData METHOD

function testPostDataNoFailWithoutParams (t as Object) as void
    globalAA = netTestsSetup()

    t.assertEqual(globalAA.net.postData(), false)

    netTestsTearDown()
end function

function testPostDataNoUrl (t as Object) as void
    globalAA = netTestsSetup()

    called = globalAA.net.postData({}, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    t.assertEqual(called, true)
    t.assertEqual(globalAA.netResults.errorCount, 1)
    t.assertEqual(globalAA.netResults.successCount, 0)

    netTestsTearDown()
end function

function testPostDataEmptyUrl (t as Object) as void
    globalAA = netTestsSetup()

    called = globalAA.net.postData({
        url: ""
    }, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    t.assertEqual(called, true)
    t.assertEqual(globalAA.netResults.errorCount, 1)
    t.assertEqual(globalAA.netResults.successCount, 0)

    netTestsTearDown()
end function

function testPostDataNoPostParams (t as Object) as void
    globalAA = netTestsSetup()

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"
    data = globalAA.net.bigFatPipe.mockData[mockDataId]

    globalAA.net.bigFatPipe.setNextResponseData(mockDataId)

    called = globalAA.net.postData({
        url: data.url
    }, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    lastCallArgs = globalAA.net.bigFatPipe.getLastMethodCallArguments("load")

    t.assertEqual(called, true)
    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("load"), 1)
    t.assertEqual(lastCallArgs.urlReq.url, data.url)
    t.assertEqual(lastCallArgs.urlReq.method, "POST")
    t.assertEqual(countObjectProperties(lastCallArgs.urlReq.requestHeaders), 1)
    t.assertEqual(lastCallArgs.destination.id, globalAA.net.id)

    netTestsTearDown()
end function

function testPostDataWithEmptyParams (t as Object) as void
    globalAA = netTestsSetup()

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"
    data = globalAA.net.bigFatPipe.mockData[mockDataId]
    postParams = {}

    globalAA.net.bigFatPipe.setNextResponseData(mockDataId)

    called = globalAA.net.postData({
        url: data.url,
        data: postParams
    }, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    lastCallArgs = globalAA.net.bigFatPipe.getLastMethodCallArguments("load")

    t.assertEqual(called, true)
    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("load"), 1)
    t.assertEqual(lastCallArgs.urlReq.url, data.url)
    t.assertEqual(lastCallArgs.urlReq.method, "POST")
    t.assertEqual(countObjectProperties(lastCallArgs.urlReq.requestHeaders), 1)
    t.assertEqual(lastCallArgs.destination.id, globalAA.net.id)
    t.assertEqual(ParseJson(lastCallArgs.urlReq.data), postParams)

    netTestsTearDown()
end function

function testPostDataWithPostParams (t as Object) as void
    globalAA = netTestsSetup()

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"
    data = globalAA.net.bigFatPipe.mockData[mockDataId]
    postParams = {
        foo: "bar",
        baz: "bus",
        bool: true,
        number1: 21,
        number2: 0,
        number3: 1,
        numberStr: "55"
    }

    globalAA.net.bigFatPipe.setNextResponseData(mockDataId)

    called = globalAA.net.postData({
        url: data.url,
        data: postParams
    }, {
        destination: globalAA.netTestsHandler,
        success: "success",
        failed: "failure"
    })

    lastCallArgs = globalAA.net.bigFatPipe.getLastMethodCallArguments("load")

    t.assertEqual(called, true)
    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("load"), 1)
    t.assertEqual(lastCallArgs.urlReq.url, data.url)
    t.assertEqual(lastCallArgs.urlReq.method, "POST")
    t.assertEqual(countObjectProperties(lastCallArgs.urlReq.requestHeaders), 1)
    t.assertEqual(lastCallArgs.destination.id, globalAA.net.id)
    t.assertEqual(ParseJson(lastCallArgs.urlReq.data), postParams)

    netTestsTearDown()
end function

' TESTS FOR THE cancelRequest METHOD
' --------------------------------------------------------------------------------

function testCancelRequestNoParam (t as Object) as void
    globalAA = netTestsSetup()

    fakerequest = globalAA.netTestsParams.fakeRequests[0]

    globalAA.net.requestHandlers[fakerequest.url] = {
        onComplete: fakerequest.onComplete,
        request: fakerequest.request
    }

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 1)
    globalAA.net.cancelRequest()

    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("cancel"), 0)
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 1)

    netTestsTearDown()
end function

function testCancelRequest (t as Object) as void
    globalAA = netTestsSetup()

    fakerequest = globalAA.netTestsParams.fakeRequests[0]

    globalAA.net.requestHandlers[fakerequest.url] = {
        onComplete: fakerequest.onComplete,
        request: fakerequest.request
    }

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 1)
    globalAA.net.cancelRequest(fakerequest.url)

    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("cancel"), 1)
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 0)

    netTestsTearDown()
end function

function testCancelRequestWithMultiplePendingRequests (t as Object) as void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)
    globalAA.net.cancelRequest(fakeRequests[1].url)

    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("cancel"), 1)
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq - 1)

    ' test the canceled one is not present in the network class request handlers
    requestHandlers = globalAA.net.requestHandlers

    for each handler in requestHandlers
        t.assertNotEqual(handler, fakeRequests[1].url)
    end for

    netTestsTearDown()
end function




' TESTS FOR THE cancelAllRequests METHOD
' --------------------------------------------------------------------------------

function testCancelAllRequestsNoRequests(t as Object) as Void
    globalAA = netTestsSetup()

    globalAA.net.cancelAllRequests()

    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("cancel"), 0)
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 0)

    netTestsTearDown()
end function

function testCancelAllRequestsOneRequest(t as Object) as Void
    globalAA = netTestsSetup()

    fakerequest = globalAA.netTestsParams.fakeRequests[0]

    globalAA.net.requestHandlers[fakerequest.url] = {
        onComplete: fakerequest.onComplete,
        request: fakerequest.request
    }

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 1)

    globalAA.net.cancelAllRequests()

    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("cancel"), 1)
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 0)

    netTestsTearDown()
end function

function testCancelAllRequestsMultipleRequests(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.cancelAllRequests()

    t.assertEqual(globalAA.net.bigFatPipe.getMethodCallCount("cancel"), nbReq)
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), 0)

    netTestsTearDown()
end function



' TESTS FOR THE onRequestSuccess METHOD
' --------------------------------------------------------------------------------

function testOnRequestSuccessNoParams(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestSuccess()

    ' No parameters are passed, the method should exit and do nothing
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    netTestsTearDown()
end function

function testOnRequestSuccessParamsWithoutRefUrl(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestSuccess({})

    ' The url isn't specified, the method should exit and do nothings
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    netTestsTearDown()
end function

function testOnRequestSuccessWithRefUrlNotInPendingRequests(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestSuccess({
        refUrl: "http://anotherfakeurl"
    })

    ' The url doesn't exist in pending calls, so none should be deleted
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    netTestsTearDown()
end function

function testOnRequestSuccess(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request,
            headers: fakerequests[n].req.headers
        }
    end for

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"
    mockData = globalAA.net.bigFatPipe.mockData[mockDataId]

    ' Adding a request we know will be removed when processing the
    '   corresponding response

    globalAA.net.requestHandlers[mockData.url] = {
        onComplete: fakerequests[0].req.onComplete,
        request: fakerequests[0].req.request,
        headers: fakerequests[0].req.headers
    }

    nbReq = nbReq + 1

    fakeLdo = LoaderDataObject(mockData.url, mockData.body, 200, mockData.headers)

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestSuccess(fakeLdo)

    ' The url doesn't exist in pending calls, so none should be deleted
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq - 1)
    t.assertEqual(globalAA.netResults.errorCount, 0)
    t.assertEqual(globalAA.netResults.successCount, 1)

    response = globalAA.netResults.response

    t.assertEqual(response.eventType, "onNetRequestSuccess")
    t.assertEqual(response.payload.headers, mockData.headers)
    t.assertEqual(response.payload.refUrl, mockData.url)
    t.assertEqual(response.payload.httpStatusCode, 200)
    t.assertEqual(response.payload.body, mockData.body)

    ' test the processed request is not present anymore
    '   in the network class request handlers
    requestHandlers = globalAA.net.requestHandlers

    for each handler in requestHandlers
        t.assertNotEqual(handler, mockData.url)
    end for

    netTestsTearDown()
end function



' TESTS FOR THE onRequestFailure METHOD
' --------------------------------------------------------------------------------

function testOnRequestFailureNoParams(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestFailure()

    ' No parameters are passed, the method should exit and do nothing
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    netTestsTearDown()
end function

function testOnRequestFailureParamsWithoutRefUrl(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestFailure({})

    ' The url isn't specified, the method should exit and do nothings
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    netTestsTearDown()
end function

function testOnRequestFailureWithRefUrlNotInPendingRequests(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request
        }
    end for

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestFailure({
        refUrl: "http://anotherfakeurl"
    })

    ' The url doesn't exist in pending calls, so none should be deleted
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    netTestsTearDown()
end function

function testOnRequestFailure(t as Object) as Void
    globalAA = netTestsSetup()

    fakeRequests = globalAA.netTestsParams.fakeRequests
    nbReq = fakeRequests.Count()

    for n = 0 to (nbReq-1) step +1
        globalAA.net.requestHandlers[fakeRequests[n].url] = {
            onComplete: fakerequests[n].req.onComplete,
            request: fakerequests[n].req.request,
            headers: fakerequests[n].req.headers
        }
    end for

    ' Prepping the data for tests below
    mockDataId = "default_v117_config"
    mockData = globalAA.net.bigFatPipe.mockData[mockDataId]

    ' Adding a request we know will be removed when processing the
    '   corresponding response

    globalAA.net.requestHandlers[mockData.url] = {
        onComplete: fakerequests[0].req.onComplete,
        request: fakerequests[0].req.request,
        headers: fakerequests[0].req.headers
    }

    nbReq = nbReq + 1

    fakeLdo = LoaderDataObject(mockData.url, mockData.body, 404, mockData.headers)

    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq)

    globalAA.net.onRequestFailure(fakeLdo)

    ' The url doesn't exist in pending calls, so none should be deleted
    t.assertEqual(countObjectProperties(globalAA.net.requestHandlers), nbReq - 1)
    t.assertEqual(globalAA.netResults.errorCount, 1)
    t.assertEqual(globalAA.netResults.successCount, 0)

    response = globalAA.netResults.response

    t.assertEqual(response.eventType, "onNetRequestFailure")
    t.assertEqual(response.payload.headers, mockData.headers)
    t.assertEqual(response.payload.refUrl, mockData.url)
    t.assertEqual(response.payload.httpStatusCode, 404)
    t.assertEqual(response.payload.body, mockData.body)

    ' test the processed request is not present anymore
    '   in the network class request handlers
    requestHandlers = globalAA.net.requestHandlers

    for each handler in requestHandlers
        t.assertNotEqual(handler, mockData.url)
    end for

    netTestsTearDown()
end function



' TESTS FOR THE secureRequest METHOD
' --------------------------------------------------------------------------------

function testsecureRequestNoParams(t as Object) as Void
    globalAA = netTestsSetup()

    ' This shouldn't explode
    globalAA.net.secureRequest()

    netTestsTearDown()
end function

function testsecureGetRequest(t as Object) as Void
    globalAA = netTestsSetup()

    request = URLRequest()
    request.url = "https://a.fake.url"
    request.method = "GET"

    t.assertFalse(request.secure)
    globalAA.net.secureRequest(request)
    t.assertTrue(request.secure)

    netTestsTearDown()
end function

function testsecurePostRequest(t as Object) as Void
    globalAA = netTestsSetup()

    request = URLRequest()
    request.url = "https://a.fake.url"
    request.method = "POST"

    t.assertFalse(request.secure)
    globalAA.net.secureRequest(request)
    t.assertTrue(request.secure)

    netTestsTearDown()
end function
