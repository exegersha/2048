function Net () as Object
    if (m.netInstance = invalid)
        this = EventDispatcher()

        ' Dependencies
        this.bigFatPipe = BigFatPipe()

        ' Private
        this.requestHandlers = {}

        this.addDefaultRequestHeaders = function (request as Object) as void
            request.addRequestHeader("Accept", "application/json")
            ' request.addRequestHeader("Content-Type", "application/json")
            ' request.addRequestHeader("X-NowTV-ClientID", m.TODO)
        end function

        this.overrideRequestHeaders = function (request as Object, headers) as void
            if (headers <> invalid)
                for each header in headers
                    request.addRequestHeader(header, headers[header])
                end for
            end if
        end function

        this.onRequestSuccess = function (dataObj=invalid as Object) as Void
            if (dataObj=invalid) OR (dataObj.refUrl=invalid) return

            if (m.requestHandlers[dataObj.refUrl] <> invalid)
                onComplete = m.requestHandlers[dataObj.refUrl].onComplete
                eventObj = Event({
                    target: m,
                    eventType: "onNetRequestSuccess",
                    payload: {
                        headers: dataObj.responseHeaders,
                        refUrl: dataObj.refUrl,
                        httpStatusCode: dataObj.httpStatusCode,
                        body: dataObj.response
                    }
                })

                if ((onComplete <> invalid) AND (onComplete.destination <> invalid) AND (onComplete.success <> invalid))
                    onComplete.destination[onComplete.success](eventObj)
                end if

                m.requestHandlers.delete(dataObj.refUrl)
            end if
        end function

        this.onRequestFailure = function (dataObj=invalid as Object) as Void
            if (dataObj=invalid) OR (dataObj.refUrl=invalid) return

            if (m.requestHandlers[dataObj.refUrl] <> invalid)
                onComplete = m.requestHandlers[dataObj.refUrl].onComplete
                eventObj = Event({
                    target: m,
                    eventType: "onNetRequestFailure",
                    payload: {
                        headers: dataObj.responseHeaders,
                        httpStatusCode: dataObj.httpStatusCode,
                        refUrl: dataObj.refUrl,
                        body: dataObj.response
                    }
                })

                if ((onComplete <> invalid) AND (onComplete.destination <> invalid) AND (onComplete.failed <> invalid))
                    onComplete.destination[onComplete.failed](eventObj)
                end if

                m.requestHandlers.delete(dataObj.refUrl)
            end if
        end function

        this.cancelRequest = function (url="" as String) as void
            if (m.requestHandlers.DoesExist(url))
                m.bigFatPipe.cancel(url)
                m.requestHandlers.delete(url)
            end if
        end function

        ' this.cancelRequestsByDestinationId = function (id as String) as void
        '     for each handler in m.requestHandlers
        '         if (m.requestHandlers[handler].onComplete.destination.id = id)
        '             m.bigFatPipe.cancel(handler)
        '             m.requestHandlers.delete(handler)
        '         end if
        '     end for
        ' end function

        this.cancelAllRequests = function () as void
            for each handler in m.requestHandlers
                m.bigFatPipe.cancel(handler)
                m.requestHandlers.delete(handler)
            end for
        end function

        this.getData = function (reqObject = invalid as Dynamic, reqHandler = invalid as Dynamic) as boolean
            if (reqObject = invalid OR reqHandler = invalid)
                return false
            else
                urlReq = URLRequest()
                urlReq.method = "GET"
                urlReq.url = reqObject.url

                m.addDefaultRequestHeaders(urlReq)
                m.overrideRequestHeaders(urlReq, reqObject.headers)

                return m.fetchData(urlReq, reqHandler)
            end if
        end function

        this.postData = function (reqObject = invalid as Dynamic, reqHandler = invalid as Dynamic) as boolean
            if (reqObject = invalid OR reqHandler = invalid)
                return false
            else
                urlReq = URLRequest()
                urlReq.method = "POST"
                urlReq.url = reqObject.url
                ' Serialising the post data
                urlReq.data = toJSON(reqObject.data)

                m.addDefaultRequestHeaders(urlReq)
                m.overrideRequestHeaders(urlReq, reqObject.headers)

                return m.fetchData(urlReq, reqHandler)
            end if
        end function

        this.fetchData = function (urlReq = invalid as Object, reqHandler = invalid as Dynamic) as boolean
            if (reqHandler = invalid OR urlReq = invalid)
                return false
            end if

            if (urlReq.url = "" OR urlReq.url = invalid)
                reqHandler.destination[reqHandler.failed]({})
            else
                if (m.requestHandlers[urlReq.url] <> invalid)
                    m.cancelRequest(urlReq.url)
                end if

                m.requestHandlers[urlReq.url] = {
                    onComplete: reqHandler,
                    request: urlReq
                }

                m.secureRequest(urlReq)
                m.bigFatPipe.load(urlReq, m, "onRequestSuccess", "onRequestFailure")
            end if

            return true
        end function

        this.secureRequest = function (request = invalid as Object) as Void
            if (request <> invalid) AND (instr(1, request.url, "https://") > 0)
                request.secure = true
            end if
        end function

        m.netInstance = this
    end if

  return m.netInstance
end function
