'' BigFatPipe.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function BigFatPipe() as Object

    if(m.bigFatPipeInstance = invalid)

        this = {}

        ' STATIC PROPERTIES
        this.TOSTRING = "<BigFatPipe>"

        ' PROPERTIES
        this.msgPort = invalid
        this.requestQueue = createObject("roList")
        this.idleConnections = createObject("roList")
        this.connectionIds = {}

        this.timeoutTimer = Timer("BigFatPipeTimeouts")
        this.timeoutTimer.addEventListener({
            eventType: "onTimer",
            handler: "checkForTimedOutRequests",
            context: m
        })

        ' METHODS
        this.checkForTimedOutRequests = function(eventObj as Object)
            ' print m.TOSTRING; " checkForTimedOutRequests"
            currTime = Stage().getTimeSinceAppStart()
            for each prop in m.connectionIds
                connection = m.connectionIds[prop]
                loader = connection.loader
                if (loader <> invalid)
                    currLoadTime = currTime - loader.requestedAt ' difference between when request was made and time now
                    if (currLoadTime > loader.urlReq.timeout)
                        ldo = LoaderDataObject(loader.urlReq.url, "", 408) ' 408 = HTTP Status for Request Timeout
                        loader.destination[loader.failCallback](ldo) ' send requests fail callback

                        ' Free up the connection again
                        m.addToIdle(connection)
                    end if
                end if
            end for
        end function

        this.processRequests = function()
            ' look through the request queue - see if there are any outstanding requests
            ' look through the idleconnections list - see if there are any available
            while ((m.requestQueue.GetHead() <> invalid) AND (m.idleConnections.GetHead() <> invalid))
                l = m.requestQueue.RemoveHead() ' get first request from queue
                connection = m.idleConnections.removeHead() ' get a free connection

                ' set up connection as per loader object
                connection.loader = l
                urlReq = l.urlReq
                urlTransfer = connection.urlTransfer
                urlTransfer.setHeaders(urlReq.requestHeaders)

                urlTransfer.setUrl(urlReq.url)

                requestFailed = false ' request has not completed

                'print m.TOSTRING; " ("; urlTransfer.getIdentity().toStr(); ") load: "; urlReq.url

                ' Output more detailed debug information on the request
                'print m.TOSTRING; " ("; urlTransfer.getIdentity().toStr(); ") load: body: "; urlReq.data

                'headerCount = 0

                'for each header in urlReq.requestHeaders
                '    print m.TOSTRING; " ("; urlTransfer.getIdentity().toStr(); ") load: header(";StringFromInt(headerCount);"): ";header;" - ";urlReq.requestHeaders.lookUp(header)
                '    headerCount = headerCount + 1
                'end for
                ' End detailed debug output

                l.requestedAt = Stage().getTimeSinceAppStart()

                ' process method
                if(urlReq.method = "GET")
                    if(NOT urlTransfer.AsyncGetToString())
                        requestFailed = true
                    end if
                else if(urlReq.method = "POST")
                    if(NOT urlTransfer.AsyncPostFromString(urlReq.data))
                        requestFailed = true
                    end if
                end if

                ' Occasionally, requests seem to fail at the SDK level. This just ensures these are caught and dealt with gracefully
                if(requestFailed)
                    loader = connection.loader
                    ldo = LoaderDataObject(loader.urlReq.url, "", 404) ' 404 = request hasn't completed
                    loader.destination[loader.failCallback](ldo)
                    m.addToIdle(connection)
                end if

            end while

            if (m.idleConnections.count() = m.maxConnections)
                m.timeoutTimer.stop()
            else
                m.timeoutTimer.start()
            end if

        end function

        ' METHODS
        this.init = function( msgPort as Object, maxConnections as Integer )
            m.msgPort = msgPort
            m.maxConnections = maxConnections

            ' set up idle connections queue
            for i=1 to m.maxConnections

                urlTransfer = CreateObject("roUrlTransfer")
                urlTransfer.setMessagePort(msgPort)
                urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
                urlTransfer.InitClientCertificates()
                urlTransfer.retainBodyOnError(true)

                connection = {
                    urlTransfer : urlTransfer
                    response : invalid
                    loader : invalid
                }

                ' get urltransfer id from loader
                urlTransferId = Stri(urlTransfer.GetIdentity())

                m.idleConnections.AddTail(connection)
                m.connectionIds[urlTransferId] = connection ' for quick handles to connection by ID
            end for

        end function

        this.processMessage = function(msg as Object) as Void
            connection = m.connectionIds[Stri(msg.getSourceIdentity())] ' get connection from its ID

            if (connection = invalid) OR (connection.loader = invalid) return

            ldo = LoaderDataObject(connection.loader.urlReq.url, msg.getString(), msg.getResponseCode(), msg.getResponseHeaders())

            if(isRequestSuccessful(msg.getResponseCode()))
                connection.loader.destination[connection.loader.successCallback](ldo)
            else
                connection.loader.destination[connection.loader.failCallback](ldo)
            end if

            ' Free up the connection again
            m.addToIdle(connection)
        end function

        this.load = function(urlReq as Object, destination as Object, successCallback as String, failCallback as String)
            'print m.TOSTRING; " load: "; urlReq.url
            if (not urlReq.url.instr("pkg://") = -1)
                'internal file
                destination[successCallback](LoaderDataObject(urlReq.url, ReadAsciiFile(urlReq.url), 200))
            else
                'external file
                loaderObj = {urlReq:urlReq, destination:destination, successCallback:successCallback, failCallback:failCallback}
                m.requestQueue.AddTail(loaderObj)
                m.processRequests() ' immediately try to act on the request
            end if
        end function

        this.addToIdle = function (con as Object) as Void

            for each c in m.idleConnections
                if(con.urlTransfer.GetIdentity() = c.urlTransfer.getIdentity())
                    return
                end if
            end for

            ' Clear the loader object
            con.urlTransfer.AsyncCancel()
            con.urlTransfer.setUrl("")
            con.loader = invalid
            m.idleConnections.addTail(con)
            m.processRequests()

        end function

        this.cancel = function(url as String) as Void

            for each id in m.connectionIds
                connection = m.connectionIds[id]
                if (connection.urlTransfer.getUrl() = url)
                    m.addToIdle(connection)
                    return
                end if
            end for

        end function

        m.bigFatPipeInstance = this

    end if

    return m.bigFatPipeInstance

end function

function isRequestSuccessful(statusCode) as Boolean
    'print statusCode
    if (statusCode = 200 or statusCode = 201) return true
    return false
end function
