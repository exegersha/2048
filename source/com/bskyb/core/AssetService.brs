'' AssetService.brs


function AssetService() as Object

    if (m.assetService = invalid)

        this = {}

        ' STATIC PROPERTIES
        this.TOSTRING = "<AssetService>"
        this.MAX_ITEMS = 25

        ' PROPERTIES
        this.itemCount = 0
        this.manager = CreateObject("roTextureManager")
        this.msgPort = invalid
        this.requests = {}
        this.embeddedAssets = {} ' contains internal assets. we lazy load these (as and when they are required)

        ' METHODS
        this.init = function(msgPort as Object)
            m.msgPort = msgPort
            m.manager.setMessagePort(msgPort)
        end function

        this.processMessage = function(msg as Object) as Void
            id = "tr_" + msg.getId().toStr()
            req = m.requests[id]
            state = msg.getState()
            retryExecuted = false

            'print m.TOSTRING; " processMessage: "; id

            if (req = invalid)
                'print "NOT FOUND"
                return
            end if

            if (state = 0) 'requested
                print "requested"

            else if (state = 1) 'downloading
                print "downloading"

            'else if (state = 2) 'downloaded
            '    print "downloaded"

            else if (state = 3) 'ready
                'print "ready"
                bitmap = msg.getBitmap()
                if (type(bitmap) <> "roBitmap")
                    print "unable to create roBitmap"
                    retryExecuted = m.handleRequestFailure(req)
                else
                    req.destination[req.successCallback](bitmap)
                end if

            else if (state = 4) or (state = 2)'failed
                'print "failed"
                retryExecuted = m.handleRequestFailure(req)
            end if

            if NOT(retryExecuted)
                req = invalid
                m.requests.delete(id)
            end if
        end function

        ' Returns "true" if the request was retried and "false" if the requestor was called back with the failure.
        this.handleRequestFailure = function(req as Object) as Boolean
            if (req.retryCount > 0)
                'print "!!! Retrying load"

                ' Retry the load. Might just have failed because the cache was full and needed cleaning.
                req.retryCount = req.retryCount - 1
                m.manager.requestTexture(req.request)

                return true
            else
                'print "!!! Retry has failed. Returning failure."

                ' No retry required. Return the failure.
                req.destination[req.failCallback]()

                return false
            end if
        end function

        this.updateItemCount = function()
            m.itemCount = m.itemCount + 1
            if (m.itemCount > m.MAX_ITEMS)
                print m.TOSTRING; " TOO MANY ITEMS"
                m.clean()
            end if
        end function

        ' Makes a request for an roBitmap with the attributes specified by the roTexturRequest.
        this.load = function(request as Object, destination as Object, successCallback as String, failCallback as String) as Void
            if (m.msgPort = invalid)
                print m.TOSTRING; " no message port attached"
                return
            end if

            m.updateItemCount()
            id = "tr_" + request.getId().toStr()
            'print m.TOSTRING; " load: "; id
            m.requests[id] = {destination:destination, successCallback:successCallback, failCallback:failCallback, request:request, retryCount:1}
            m.manager.requestTexture(request)
        end function

        ' Cancels the request specified by the roTextureRequest
        this.cancel = function(request as Object)
            id = "tr_" + request.getId().toStr()
            'print m.TOSTRING; " cancel: "; id
            m.manager.cancelRequest(request)
            m.requests.delete(id)
        end function

        ' Removes a bitmap from the roTextureManager with the specific URI
        this.unloadBitmap = function(uri as String)
            'print m.TOSTRING; " unloadBitmap: "; uri
            m.manager.unloadBitmap(uri)
        end function

        ' Removes all bitmaps from the roTextureManager
        this.clean = function()
            'print "!!!!"; m.TOSTRING; " clean. Manager content:"

            'for each currentId in m.manager
            '    print "!!!!     ";currentId;" : ";m.manager[currentId]
            'end for

            m.itemCount = 0
            'm.requests = {}
            m.manager.cleanUp()
            retriedRequests = {}

            for each currentId in m.requests
                if (m.handleRequestFailure(m.requests[currentId]))
                    ' Request was retried so keep it in the requests object.
                    retriedRequests[currentId] = m.requests[currentId]
                end if
            end for

            m.requests = retriedRequests

            Stage().reRender() ' this will complete the textureManager cleanup process
        end function

        ' Internal assets are loaded in synchronously
        this.loadInternal = function(path as String) as Object

            asset = m.embeddedAssets.lookup(path)
            ' check if this has already been loaded
            if(asset <> invalid)
                ' asset found - return it
                return asset
            else
                ' new load - create and add it to assetList
                bitmap = createObject("roBitmap", path)
                if(bitmap <> invalid) m.embeddedAssets.AddReplace(path, bitmap)

                return bitmap
            end if

        end function

        ' Clears out internal asset list
        this.cleanInternal = function()
            'print "!!!!"; m.TOSTRING; " cleanInternal. Embedded assets content:"

            'for each currentId in m.embeddedAssets
            '    print "!!!!     ";currentId;" : ";m.embeddedAssets[currentId]
            'end for

            m.embeddedAssets = {}
        end function

        ' Destroy an internal asset from its path
        this.cleanInternalFromPath = function(path as String)
            asset = m.embeddedAssets.lookup(path)
            if(asset <> invalid)
                m.embeddedAssets.delete(path)
            end if
        end function

        m.assetService = this

    end if

    return m.assetService

end function

