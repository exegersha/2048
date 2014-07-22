' Copyright: Conviva Inc. 2011-2012
' Conviva LivePass Brightscript Client library for Roku devices
' LivePass Version: 2.78.0.16704
' authors: Alex Roitman <shura@conviva.com>
'          George Necula <necula@conviva.com>
'

'==== Public interface to the ConvivaLivePass library ====
' The code below should be used in the integrations.
'==== Public interface to the ConvivaLivePass library ====

'''
''' ConvivaLivePassInstace is a singleton that returns ConvivaLivePass
''' that was created with ConvivaLivePassInit
'''
function ConvivaLivePassInstance() as dynamic
    globalAA = getGLobalAA()
    return globalAA.ConvivaLivePass
end function

'''
''' ConvivaWait() should be used instead of regular wait()
'''
''' <param name="customWait">a customWait function for the third party,
''' in case they have a similar replacement for wait() </param>
'''
function ConvivaWait(timeout as integer, port as object, customWait as dynamic) as dynamic
    Conviva = ConvivaLivePassInstance()
    return Conviva.utils.wait(timeout, port, customWait, Conviva)
end function

'''
''' ConvivaContentInfo class
''' Encapsulates the information about a video stream
''' <param name="assetName">an asset name  (video title) for this session </param>
''' <param name="tags">a dictionary with *case-sensitive* keys corresponding to the tags</param>
'''
function ConvivaContentInfo (assetName as string, tags as object)
    self = { }

    self.assetName = assetName

    ' A set of key-value pairs used in resource selection and policy evaluation
    self.tags      = tags

    '''''''''''''''''''''''''''''''''''''''''
    '''
    ''' The remaining fields are optional
    '''
    '''''''''''''''''''''''''''''''''''''''''

    ' Set this to the bitrate (1000 bits-per-second) to be used for the integrations
    ' where the streamer does not know the bitrate being played. This value is used
    ' until the streamer reports a bitrate.
    self.defaultReportingBitrateKbps = invalid

    ' A string identifying the CDN used to stream video.  This must be
    ' chosen from the list of CDN_NAME_* constants in this class.
    '
    ' If you use a CDN whose name is not in the list of CDN_NAME_*
    ' constants, please use CDN_NAME_OTHER temporarily and initiate a
    ' service request with Conviva so that we can add your CDN to the
    ' list.
    '
    ' If content is served in-house instead of using a CDN, use CDN_NAME_IN_HOUSE.
    self.defaultReportingCdnName = invalid

    ' Set this to a string that will be used as the resource name for the integrations
    ' where the streamer does not itself know the resource being played. If this is null,
    ' then the value of cdnName is used for this purpose.
    self.defaultReportingResource = invalid

    ' A string identifying the viewer.
    self.viewerId = invalid

    ' PD-7686:
    ' A string identifying the player in use, preferably human-readable.
    ' If you have multiple players, this can be used to distinguish between them.
    self.playerName = invalid

    ' The URL from which video is loaded.
    ' Note: If this changes during a session, there is no need to update
    ' this value - just use the URL from which loading initially occurs.
    self.streamUrl = invalid

    ' Set to true if the session includes live content, and false otherwise.
    self.isLive = invalid

    ' PD-8962: Smooth Streaming support
    ' Allow player to specify streamFormat if known
    self.streamFormat = invalid

    ' PD-10673: contentLength support
    self.contentLength = invalid

    return self
end function


'''------------
''' Conviva LivePass class
''' Constructs, initializes and returns a ConvivaLivePass object.
'''
''' <param name="apiKey">a key assigned by Conviva to uniquely identify a Conviva customer </param>
''' <returns>A ConvivaLivePass object
function ConvivaLivePassInit (apiKey as string)
    return ConvivaLivePassInitWithSettings(apiKey, invalid)
end function

'==== End of the Public interface to the ConvivaLivePass library ====
' The code below should not be accessed directly by integrations.
'==== End of the Public interface to the ConvivaLivePass library ====


'''------------
''' Conviva LivePass class
''' Constructs, initializes and returns a ConvivaLivePass object.
'''
''' <param name="apiKey">a key assigned by Conviva to uniquely identify a Conviva customer </param>
''' <param name="settings">an optional associative array with advanced configuration settings. This parameter should be used only with guidance from Conviva</param>
''' <returns>A ConvivaLivePass object
function ConvivaLivePassInitWithSettings (apiKey as string, settings as object)
    ' Singleton mechanism
    conviva = ConvivaLivePassInstance()
    if conviva <> invalid then
        return conviva
    end if

    self = {}
    '' Potential values for the cdnName field (constants)
    self.CDN_NAME_AKAMAI = "AKAMAI"
    self.CDN_NAME_AMAZON = "AMAZON"
    self.CDN_NAME_ATT = "ATT"
    self.CDN_NAME_BITGRAVITY = "BITGRAVITY"
    self.CDN_NAME_BT = "BT"
    self.CDN_NAME_CDNETWORKS = "CDNETWORKS"
    self.CDN_NAME_CHINACACHE = "CHINACACHE"
    self.CDN_NAME_EDGECAST = "EDGECAST"
    self.CDN_NAME_HIGHWINDS = "HIGHWINDS"
    self.CDN_NAME_INTERNAP = "INTERNAP"
    self.CDN_NAME_LEVEL3 = "LEVEL3"
    self.CDN_NAME_LIMELIGHT = "LIMELIGHT"
    self.CDN_NAME_OCTOSHAPE = "OCTOSHAPE"
    self.CDN_NAME_SWARMCAST = "SWARMCAST"
    self.CDN_NAME_VELOCIX = "VELOCIX"
    self.CDN_NAME_TELEFONICA = "TELEFONICA"
    self.CDN_NAME_MICROSOFT = "MICROSOFT"
    self.CDN_NAME_CDNVIDEO = "CDNVIDEO"
    self.CDN_NAME_QBRICK = "QBRICK"
    self.CDN_NAME_NGENIX = "NGENIX"
    self.CDN_NAME_IPONLY = "IPONLY"
    self.CDN_NAME_INHOUSE = "INHOUSE"
    self.CDN_NAME_COMCAST = "COMCAST"
    self.CDN_NAME_NICE = "NICE"
    self.CDN_NAME_TELENOR = "TELENOR"
    self.CDN_NAME_OTHER = "OTHER"

    self.utils = cwsConvivaUtils()
    self.sendLogs = false
    self.cfg = self.utils.settings
    ' Copy the settings over
    if settings <> invalid then
        for each key in settings:
            self.cfg[key] = settings[key]
        end for
    end if

    self.apiKey  = apiKey
    self.instanceId = int(self.utils.epochTimeSec())

    self.clId    = self.utils.readLocalData ("clientId")
    if self.clId = "" then
        self.clId = "0" ' This will signal to the back-end that we need a new client id
    end if
    self.session = invalid
    self.regexes = self.utils.regexes

    self.log = function (msg as string)
         m.utils.log(msg)
    end function

    ' Collect the platform metadata
    devinfo = CreateObject("roDeviceInfo")
    self.platformMeta = {
        sch : "rk1",  ' The schema name
        m : devinfo.GetModel(),
        v : devinfo.GetVersion(),
        did : devinfo.GetDeviceUniqueId(),
        dt : devinfo.GetDisplayType(),
        dm : devinfo.GetDisplayMode()
    }
    self.utils.log("CWS init done")

    ''
    '' Clean the Conviva LivePass
    ''
    self.cleanup = function () as void
        self = m
        if self.utils = invalid then
            ' Already cleaned
            return
        end if
        self.utils.log("LivePass.cleanup")

        if self.session <> invalid then
            self.utils.log("Destroying session "+stri(self.session.sessionId))
            self.session.cleanup( )
            self.utils.log("Session destroyed")
        end if
        self.clId = invalid
        self.session = invalid
        self.utils.cleanup ()
        self.utils = invalid

        globalAA = getGLobalAA()
        globalAA.delete("ConvivaLivePass")

    end function

    '''
    ''' createSession : Create a monitoring session, without Conviva PreCision control.
    ''' screen - the roVideoScreen to monitor for video events
    ''' contentInfo - an instance of ConvivaContentInfo with fields set to appropriate values
    ''' notificationPeriod - the interval in seconds to receive playback position events from the screen. This
    '''                      parameter is necessary because Conviva LivePass must change the default PositionNotificationPeriod
    '''                      to 1 second.
    self.createSession = function (screen as object, contentInfo as object, positionNotificationPeriod as integer) as object
        self = m
        if self.utils = invalid then
            print "ERROR: called createSession on uninitialized LivePass"
            return invalid
        end if
        if self.session <> invalid then
            self.utils.log("Automatically closing previous session with id "+stri(self.session.sessionId))
            self.cleanupSession(self.session)
        end if
        sess = cwsConvivaSession(self, screen, contentInfo, positionNotificationPeriod)
        self.session = sess
        return sess
    end function


    '''
    ''' sendSessionEvent - send Conviva Player Inside Event, with a name and a list of key value pair as event attributes.
    '''
    ''' session - returned by the createSession, createPrecisionSession
    ''' eventName - a name for the event
    ''' eventAttributes - a dictionary of key value pair associated with the convivaEvent. The dictionary is modified in place.
    self.sendSessionEvent = function (session as object, eventName as string, eventAttributes as object) as void
        self = m
        if self.utils = invalid then
            print "ERROR: called sendEvent on uninitialized LivePass"
            return
        end if
        self.checkCurrentSession(session)
        self.utils.log("sendEvent "+eventName)
        eventAttributes["t"] = "CwsCustomEvent"
        eventAttributes["name"] = eventName
        session.cwsSessSendEvent("CwsCustomEvent", eventAttributes)
    end function

    '''
    ''' setCurrentStreamInfo : Set the current bitrate and/or current resource
    '''
    ''' bitrateKbps - the new bitrate (ignored if -1)
    ''' cdnName     - the new CDN (ignored if invalid)
    ''' resource    - the new resource (ignored if invalid)
    self.setCurrentStreamInfo = function (session as object, bitrateKbps as dynamic, cdnName as dynamic, resource as dynamic) as void
        self = m
        if self.utils = invalid then
            print "ERROR: called setCurrentStreamInfo on uninitialized LivePass"
            return
        end if
        self.utils.log("setCurrentStreamInfo")
        self.checkCurrentSession(session)
        session.setCurrentStreamInfo(bitrateKbps, cdnName, resource)
    end function

    '''
    ''' setCurrentStreamMetadata : Set various metadata parameters for the stream
    '''
    ''' The metadata object should be a dictionary from metadata field names to metadata values (as strings).
    ''' The names of the valid keys are defined in ConvivaLivePass as constants:
    '''  - duration  (duration of the stream in seconds)
    '''  - framerate (encoded framerate)
    ''' Other keys are ignored.
    ''' If the callback is called multiple times, the most recent value for each key will be used. For
    ''' example, calling the callback first with { "duration":"100" } and immediately thereafter with
    ''' { "framerate":"30" } is equivalent to calling it once with { "duration":"100", "framerate":"30" }.
    self.setCurrentStreamMetadata = function (session as object, metadata as object) as void
        self = m
        if self.utils = invalid then
            print "ERROR: called setCurrentStreamMetadata on uninitialized LivePass"
            return
        end if
        self.utils.log("setCurrentStreamMetadata")
        self.checkCurrentSession(session)
        session.setCurrentStreamMetadata(metadata)
    end function

    '''
    ''' cleanupSession : should be called when a video session is over
    '''
    self.cleanupSession = function (session) as void
        self = m
        if self.utils = invalid then
            print "ERROR: called cleanupSession on uninitialized LivePass"
            return
        end if
        self.utils.log("Cleaning session")
        self.checkCurrentSession(session)
        session.cleanup ()
        self.session = invalid
    end function


    '''
    ''' toggleTraces : toggle the printing of the Conviva traces to the debugging console
    '''
    self.toggleTraces = function (toggleOn as boolean) as void
        self = m
        if self.utils = invalid then
            print "ERROR: called toggleTraces on uninitialized LivePass"
            return
        end if
        self.utils.log("toggleTraces")
        self.utils.settings.enableLogging = toggleOn
    end function

    ' Check that the given session is the current one
    self.checkCurrentSession = function (session as object)
        self = m
        if self.session = invalid or session.sessionId <> self.session.sessionId then
            self.utils.err("Called cleanupSession for an untracked session")
        end if
    end function

    ' Store ourselves in the globalAA for future use
    globalAA = getGLobalAA()
    globalAA.ConvivaLivePass = self

    return self
end function



'--------------
' Session class
'--------------
function cwsConvivaSession(cws as object, screen as object, contentInfo as object, notificationPeriod as integer) as object
    self = {}
    self.screen = screen
    self.contentInfo = contentInfo
    self.notificationPeriod = notificationPeriod
    self.notificationTimer = invalid ' will be created lazily

    self.cws = cws

    'The values have to be strings because they will be
    'used as keys in other dictionaries.
    self.ps = {
        stopped:        "1",
        error:         "99",
        buffering:      "6",
        playing:        "3",
        paused:        "12"
    }

    self.utils = cws.utils

    self.sessionId = int(2147483647*rnd(0))
    self.sessionFlags = 7  ' SFLAG_VIDEO | SFLAG_QUALITY_METRICS | SFLAG_BITRATE_METRICS

    if screen <> invalid then
        screen.SetPositionNotificationPeriod(1)
    end if

    callback = function (sess as dynamic)
         sess.cwsSessSendHb()
    end function
    self.hbTimer = self.utils.createTimer(callback, self, self.utils.settings.heartbeatIntervalMs, "heartbeat")

    ' We need to remember last PHT occurence to detect buffering with hls
    self.lastPhtTimer = CreateObject("roTimespan")
    callback = function(sess as dynamic)
        sess.cwsPhtCheck()
    end function
    self.phtCheckTimer = self.utils.createTimer(callback, self, 400, "phtCheck")

    self.utils.log("Created new session with id "+stri(self.sessionId)+" for asset "+contentInfo.assetName)

    ' Sanitize the tags
    for each tk in contentInfo.tags
        if contentInfo.tags[tk] = invalid then
            self.utils.log("WARNING: correcting null value for tag key "+tk)
            contentInfo.tags[tk] = "null"
        end if
    end for
    ' Sanitize CdnName
    if contentInfo.defaultReportingCdnName = invalid then
        contentInfo.defaultReportingCdnName = cws.CDN_NAME_OTHER
    end if
    ' Sanitize the resource
    if contentInfo.defaultReportingResource = invalid then
        contentInfo.defaultReportingResource = contentInfo.defaultReportingCdnName
    end if
    ' Sanitize the bitrateKbps
    ' PD-10535: don't send negative or invalid bitrates
    if type(contentInfo.defaultReportingBitrateKbps)<>"roInteger" or contentInfo.defaultReportingBitrateKbps < -1 then
        if contentInfo.defaultReportingBitrateKbps <> invalid then
            self.utils.log("Invalid ConvivaContentInfo.defaultReportingBitrateKbps. Expecting >= -1 roInteger.")
        end if
        contentInfo.defaultReportingBitrateKbps = -1
    end if
    ' PD-10673: contentLength support, sanitize
    if type(contentInfo.contentLength)<>"roInteger" or contentInfo.contentLength < 0 then
        if contentInfo.contentLength <> invalid then
            self.utils.log("Invalid ConvivaContentInfo.contentLength. Expecting >= 0 roInteger.")
        end if
        contentInfo.contentLength = invalid
    end if

    ' PD-8962: Smooth Streaming support
    self.streamFormat = contentInfo.streamFormat
    if self.streamFormat <> invalid and self.streamFormat <> "mp4" and self.streamFormat <> "ism" and self.streamFormat <> "hls" then
        self.utils.log("Received invalid streamFormat from player: " + self.streamFormat)
        self.utils.log("Valid streamFormats : mp4, ism, hls")
        self.streamFormat = invalid
    end if
    self.videoBitrate = -1
    self.audioBitrate = -1
    self.totalBitrate = contentInfo.defaultReportingBitrateKbps

    self.sessionTimer = CreateObject("roTimespan")
    self.sessionTimer.mark()
    self.sessionStartTimeMs = CreateObject("roDateTime").asSeconds()*1000
    self.eventSeqNumber = 0
    self.psm = cwsConvivaPlayerState(self)
    self.numPlayingFpsObservations = 0
    self.playingFpsTotal = 0
    self.playingBitsTotal = 0

    self.hb = {
        cid : cws.apiKey,
        clid: cws.clId,
        sid: self.sessionId,
        iid : cws.instanceId,
        sf : self.sessionFlags,
        seq: 0,
        an: contentInfo.assetName,
        pver: cws.cfg.protocolVersion,
        t: "CwsSessionHb",
        dv: cws.cfg.device,
        dvv: cws.cfg.deviceVersion,
        dvt: cws.cfg.deviceType,
        os: cws.cfg.os,
        osv: cws.cfg.osVersion,
        pt: cws.cfg.platform,
        clv : cws.cfg.version,
        ptv: cws.cfg.platformVersion,
        pm : cws.platformMeta,
        st: 0,
        tags: contentInfo.tags,
        evs: [],
        lv: false
    }
    vid = contentInfo.viewerId
    if (type(vid)="String" or type(vid)="roString") and vid <> "" then
        self.hb.vid = vid
    end if

    ' PD-7686: add "pn" field to heartbeat
    pn = contentInfo.playerName
    if (type(pn)="String" or type(pn)="roString") and pn <> "" then
        self.hb.pn = pn
    end if

    ' PD-10341: add "lv" field to heartbeat
    lv = contentInfo.isLive
    if type(lv)="roBoolean" or type(lv)="Boolean" then
        self.hb.lv = lv
    end if

    ' PD-10673: add "cl" field to heartbeat
    cl = contentInfo.contentLength
    if type(cl)="roInteger" then
        self.hb.cl = cl
    end if

    self.cleanup  = function () as void
        self = m
        if self.utils = invalid then
            return
        end if

        ' Schedule a last heartbeat
        ' TODO: do we need to wait for the HB to be sent ?
        self.utils.log("Sending the last HB")
        self.cwsSessSendHb()

        self.utils.cleanupTimer(self.hbTimer)
        self.hbTimer = invalid
        self.utils.cleanupTimer(self.phtCheckTimer)
        self.phtCheckTimer = invalid
        self.lastPhtTimer = invalid
        self.psm.cleanup ()
        self.cws = invalid
        self.sessionId = invalid
        self.sessionTimer = invalid
        self.notificationTimer = invalid
        self.psm = invalid
        self.hb = invalid
        self.utils = invalid
        self.screen = invalid
    end function

    ' We use a per-session logger, as per the CWS logging spec
    self.log = function (msg) as void
        self = m
        if self.utils = invalid then
            print "ERROR: logging after cleanup: "+msg
            return
        end if
        if self.sessionId <> invalid then
            self.utils.log("sid="+stri(self.sessionId)+" "+msg)
        else
            self.utils.log(msg)
        end if
    end function

    self.updateMeasurements = function () as void
        self = m
        sessionTimeMs = self.cwsSessTimeSinceSessionStart()
        pm = self.psm.cwsPsmGetPlayerMeasurements(sessionTimeMs)
        for each st in pm
            self.hb[st] = pm[st]
        end for
        self.hb.clid = self.cws.clId
        self.hb.st = sessionTimeMs
        if self.cws.sendLogs then
            self.hb.lg = self.utils.getLogs ()
        else
            if self.hb.lg <> invalid then
                self.hb.delete("lg")
            end if
        end if
        self.hb.cts = self.utils.epochTimeSec()
   end function

    self.setCurrentStreamInfo = function (bitrateKbps as dynamic, cdnName as dynamic, resource as dynamic)
        self = m
        if bitrateKbps <> -1 then
            self.psm.bitrateKbps = bitrateKbps
        end if
        if cdnName <> invalid then
            self.psm.cdnName = cdnName
        end if
        if resource <> invalid then
            self.psm.resource = resource
        end if
    end function

    self.setCurrentStreamMetadata = function (metadata as object)
        self = m
        if metadata.duration <> invalid then
            self.psm.contentLength = strtoi(metadata.duration)
            if self.psm.contentLength = invalid then
                self.psm.contentLength = -1
            end if
        end if
        if metadata.framerate <> invalid then
            self.psm.encodedFramerate = strtoi(metadata.framerate)
            if self.psm.encodedFramerate = invalid then
                self.psm.encodedFramerate = -1
            end if
        end if

    end function

    self.cwsPhtCheck = function () as void
        self = m
        msSinceLastPhtOccurence = self.lastPhtTimer.TotalMilliseconds()
        ' The last PHT should have been seen less than a second ago.
        ' We allow a second, since we only have integer precision.
        ' If this is not the case, we must be buffering.
        if msSinceLastPhtOccurence > 1500 then
            if self.psm.curState = self.ps.playing then
                self.log("phtCheck: last PHT was seen "+stri(msSinceLastPhtOccurence)+" ms ago. Changing player state to buffering")
                self.cwsSessOnStateChange(self.ps.buffering, invalid)
            end if
        end if
    end function

    self.cwsSessSendHb = function () as object
        sess = m
        if sess = invalid or sess.cws = invalid then
            return invalid
        else if sess.cws.clId = invalid then
            sess.log("Suppress HB sending: no clientId")
            return invalid
        else if sess.cws.clId = "0" then
            sess.log("Sending HB with clientId=0")
        end if
        sess.updateMeasurements( )

        callback = function (sess as object, success as boolean, resp as string)
                      sess.cwsOnResponse(resp)
                   end function
        sess.utils.sendPostRequest(sess.utils.settings.gatewayUrl+sess.utils.settings.gatewayPath, sess.cwsSessGetHb(), callback, sess)
    end function

    self.cwsOnResponse = function (resp_txt as string) as void
        self = m
        if self.cws = invalid then
            print ("WARNING: Received response from WSG after the session was cleaned")
            return
        end if

        resp = self.utils.jsonDecode(resp_txt)

        if resp = invalid or resp.err <> "ok" then
            self.log("ERROR response from gateway: "+resp_txt)
            self.log("parsed into")
            return
        end if

        if resp.sid=invalid or resp.clid=invalid or resp.clid="" then
            self.log("Malformed http reply")
            return
        end if

        if self.sessionId <> int(resp.sid) then
            self.log("Got response for session: "+str(resp.sid)+" while in session: "+stri(self.sessionId))
            return
        end if

        if self.hb.seq - 1 <> resp.seq then
            self.log("Got old hb? "+stri(resp.seq)+" while last sent was "+stri(self.hb.seq-1))
            return
        end if
        if self.cws.clId = "0" and resp.clid <> invalid then
            self.utils.log("Received clientId from server "+resp.clid)
            self.cws.clId = resp.clid
            self.utils.writeLocalData("clientId", resp.clid)
        end if
        if resp.slg = invalid then
            self.cws.sendLogs = false
        else
            self.cws.sendLogs = resp.slg
        end if
        if resp.hbi <> invalid and self.cws.cfg.heartbeatIntervalMs <>  resp.hbi * 1000 then
            self.log("Received hbInterval from server "+stri(resp.hbi))
            self.cws.cfg.heartbeatIntervalMs = resp.hbi * 1000
            self.utils.updateTimerInterval(self.hbTimer, resp.hbi * 1000)
        end if
        if resp.gw <> invalid and self.cws.cfg.gatewayUrl <> resp.gw then
            self.log("Received gatewayUrlfrom server "+resp.gw)
            self.cws.cfg.gatewayUrl = resp.gw
        end if
    end function

    self.cwsSessGetHb = function () as string
        self = m
        'Return HB data for a session as a json string
        encStart = self.sessionTimer.TotalMilliseconds()
        json_data = self.utils.jsonEncode(self.hb)
        if self.utils.settings.printHb then
            ' Do not even think of using self.log here, because then we end up with exponential HBs if sendLogs is turned on
            print "CWS: JSON: "+json_data
        end if
        ' self.log("Json encoding took "+stri(self.sessionTimer.TotalMilliseconds() - encStart)+"ms")
        ' The following line helps debugging and is also used by Touchstone to better estimate clock skew
        ' We want to put this line as late as possible before sending the HB
        self.log("Send HB["+stri(self.hb.seq)+"]")
        'Start next HB
        self.hb.seq = self.hb.seq + 1
        self.hb.evs = []
        return json_data
    end function

    self.cwsSessTimeSinceSessionStart = function () as integer
        self = m
        return self.sessionTimer.TotalMilliseconds()
    end function

    self.cwsSessSendEvent = function (evtType as string, evtData as object) as void
        self = m
        evtData.t = evtType
        evtData.st = self.cwsSessTimeSinceSessionStart()
        evtData.seq = self.eventSeqNumber
        self.eventSeqNumber = self.eventSeqNumber + 1
        self.hb.evs.push(evtData)
    end function

    self.cwsSessOnStateChange = function (playerState as string, data as dynamic) as void
        self = m
        if self = invalid then
            self.log("Cannot change state for invalid session")
            return
        end if
        sessionTimeMs = self.cwsSessTimeSinceSessionStart()
        pm = self.psm.cwsPsmGetPlayerMeasurements(sessionTimeMs)

        evt = self.psm.cwsPsmOnStateChange(self.cwsSessTimeSinceSessionStart(), playerState, data)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function


    self.cwsSessOnBitrateChange = function (newBitrateKbps as integer) as void
        self = m
        if self = invalid then
            self.log("Cannot change bitrate for invalid session")
            return
        end if
        evt = self.psm.cwsPsmOnBitrateChange(self.cwsSessTimeSinceSessionStart(), newBitrateKbps)
        if evt <> invalid then
            self.cwsSessSendEvent(evt.t, evt)
        end if
    end function

    self.cwsSessOnResourceChange = function (newStreamUrl as string) as void
        self = m
        if newStreamUrl = self.psm.streamUrl then
            return
        end if

        self.psm.streamUrl = newStreamUrl
    end function

    ' PD-8962: Smooth Streaming support
    self.updateBitrateFromEventInfo = function (streamUrl as string, streamBitrate as integer) as void
        self = m
        if self.streamFormat = "ism" then
            ' Smooth Streaming URL
            if self.utils.ssFragmentTypeFromUrl(streamUrl) = "audio" then
                if self.audioBitrate <> streamBitrate then
                    self.audioBitrate = streamBitrate
                    self.log("updateBitrateFromEventInfo(): Smooth Streaming audio chunk, bitrate: " + stri(self.audioBitrate))
                end if
            else if self.utils.ssFragmentTypeFromUrl(streamUrl) = "video" then
                if self.videoBitrate <> streamBitrate then
                    self.videoBitrate = streamBitrate
                    self.log("updateBitrateFromEventInfo(): Smooth Streaming video chunk, bitrate: " + stri(self.videoBitrate))
                end if
            else
                self.log("updateBitrateFromEventInfo(): Smooth Streaming unknown chunk, bitrate: " + stri(streamBitrate))
                ' Choosing not to do anything with it, could take a guess based on bitrate
                ' < 200 for audio >= 200 for video or something
            end if
            if self.videoBitrate <> -1 and self.audioBitrate <> -1 then
                ' Only report bitrate after we know both audio and video bitrate
                if self.totalBitrate <> self.audioBitrate + self.videoBitrate then
                    self.totalBitrate = self.audioBitrate + self.videoBitrate
                    self.log("New bitrate ("+self.streamFormat+"): "+stri(self.totalBitrate))
                end if
            end if
        else if self.streamFormat = "hls" then
            if self.totalBitrate <> streamBitrate then
                self.totalBitrate = streamBitrate
                self.log("New bitrate ("+self.streamFormat+"): "+stri(self.totalBitrate))
            end if
        end if
    end function

    '
    ' Process a video event, return true if we processed it
    '
    self.cwsProcessVideoEvent = function (convivaEvent)
        'TODO: check that this event is for the screen we are monitoring
        self = m
        if convivaEvent.isScreenClosed() then               'real end of session
            self.log("videoEvent: isScreenClosed")
            self.cwsSessOnStateChange(self.ps.stopped, invalid)

        else if convivaEvent.isFullResult() or convivaEvent.isPartialResult() then 'this is essentially the end of session
            self.log("videoEvent: isFullResult or isPartialResult, message= "+convivaEvent.getmessage())
            self.cwsSessOnStateChange(self.ps.stopped, invalid)

        else if convivaEvent.isPaused() then           'user paused
            self.log("videoEvent: isPaused")
            self.cwsSessOnStateChange(self.ps.paused, invalid)
        else if convivaEvent.isResumed() then          'user resumed
            self.log("videoEvent: isResumed")
            self.cwsSessOnStateChange(self.ps.playing, invalid)
            self.lastPhtTimer.mark()
        else if convivaEvent.isStreamStarted() then    'bufferring started
            info = convivaEvent.GetInfo()
            self.log("videoEvent: isStreamStarted MeasuredBitrate="+stri(info.MeasuredBitrate)+" StreamBitrate="+stri(info.StreamBitrate)+" url="+info.url)
            self.cwsSessOnStateChange(self.ps.buffering, invalid)
            if self.streamFormat = invalid then
                self.streamFormat = self.utils.streamFormatFromUrl(info.url)
                self.log("streamFormat (guessed): " + self.streamFormat)
            else
                self.log("streamFormat (from player): " + self.streamFormat)
            end if
            if int(info.StreamBitrate) <> 0 then
                ' PD-8962: wrong initial bitrate value for ism/hls
                ' only take it into account for mp4
                if self.streamFormat = "mp4" then
                    self.totalBitrate = int(info.StreamBitrate / 1000)
                    self.log("New bitrate ("+self.streamFormat+"): "+stri(self.totalBitrate))
                end if
            end if
            self.cwsSessOnBitrateChange(self.totalBitrate)
            self.cwsSessOnResourceChange(info.url)
        else if convivaEvent.isStreamSegmentInfo() then    'new ism/hls segment
            info = convivaEvent.GetInfo()
            self.log("videoEvent: isStreamSegmentInfo StreamBandwidth="+stri(info.StreamBandwidth)+" Sequence="+stri(info.Sequence)+" SegUrl="+info.SegUrl)
            self.cwsSessOnStateChange(self.ps.playing, invalid)
            ' PD-8962: this event should take care of ism/hls bitrate
            self.updateBitrateFromEventInfo(info.SegUrl, int(info.StreamBandwidth))
            self.cwsSessOnBitrateChange(self.totalBitrate)
            ' PD-8962: don't change streamUrl to fragment urls for ism/hls
            ' self.cwsSessOnResourceChange(info.SegUrl)
        else if convivaEvent.isPlaybackPosition() then 'playing
            self.log("videoEvent: isPlaybackPosition pht="+stri(convivaEvent.GetIndex()))
            self.cwsSessOnStateChange(self.ps.playing, invalid)

            self.lastPhtTimer.mark()

            if self.notificationPeriod = 1 then
                'self.utils.log("RETURNING to caller, skip throttling")
                return false  'no throttling at all
            else if self.notificationTimer = invalid then
                self.notificationTimer = CreateObject("roTimespan")
                self.notificationTimer.mark()
                'self.utils.log("RETURNING to caller, 1st notification")
                return false
            else if self.notificationTimer.TotalSeconds() > (self.notificationPeriod-1) then
                'self.utils.log("RETURNING to caller, non-1st notification")
                self.notificationTimer.mark()
                return false
            else
                return true
            end if
        else if convivaEvent.isRequestFailed() then    'fatal error
            errorMsg = convivaEvent.GetMessage()
            self.log("videoEvent: isRequestFailed err="+errorMsg)
            if errorMsg <> invalid and errorMsg <> "" then
                errData = { ft: true,
                            err: convivaEvent.GetMessage() }
                self.cwsSessOnStateChange(self.ps.error, errData)
            end if
            return true
        else if convivaEvent.GetType() = 11 then    'EventStatusMessage
            msg = convivaEvent.GetMessage()
            action = self.utils.getEventStatusMessageType(msg)
            self.log("videoEvent: EventStatusMessage (#11) message="+msg+" convivaAction="+action)
            if action = "error" then
                errData = { ft: true,
                            err: convivaEvent.GetMessage() }
                self.cwsSessOnStateChange(self.ps.error, errData)
                self.log("videoEvent: reported error and switched to error state.")
            else if action = "buffering" then
                self.cwsSessOnStateChange(self.ps.buffering, invalid)
                self.log("videoEvent: inferred buffering state.")
            else if action = "playing" then
                self.cwsSessOnStateChange(self.ps.playing, invalid)
                self.log("videoEvent: inferred playing state.")
            else if action = "stopped" then
                self.cwsSessOnStateChange(self.ps.stopped, invalid)
                self.log("videoEvent: inferred stopped state.")
            else if action = "unknown" then ' we do not know this status message yet
                self.log("videoEvent: unknown status message, report these logs to Conviva development team.")
            end if
            return true
        ' else if convivaEvent.GetType() = 31 then    ' new event, Download segment info, may contain buffer information
        end if
        return false
    end function

    self.cwsSessSendHb() 'Send urgent HB
    return self
end function


'-------------------------
' PlayerStateManager class
'-------------------------
function cwsConvivaPlayerState(sess as object) as object
    self = {}
    self.session = sess
    self.utils = sess.utils

    ps = sess.ps
    self.totalBufferingEvents = 0
    self.joinTimeMs = -1
    self.contentLength = -1
    self.encodedFramerate = -1

    self.totalPlayingKbits = 0
    self.curState = self.session.ps.stopped
    self.cumulativeTimePerState = {}
    self.stateTimeDelta = 0 'time since start of current state
    self.stateLastTs = 0    'last time we updated the cumulative time of a state
    for each k in ps
        self.cumulativeTimePerState[ps[k]] = 0
    end for

    self.bitrateKbps = sess.contentInfo.defaultReportingBitrateKbps
    self.cdnName = sess.contentInfo.defaultReportingCdnName
    self.resource = sess.contentInfo.defaultReportingResource
    self.streamUrl = sess.contentInfo.streamUrl

    self.cleanup = function () as void
        self = m
        self.session = invalid
        self.utils = invalid
    end function

    self.cwsPsmUpdateStateCumulativeTime = function (sessionTimeMs as integer) as void
        self = m
        st = self.curState
        delta = sessionTimeMs - self.stateLastTs
        self.stateLastTs = sessionTimeMs
        self.cumulativeTimePerState[st] = self.cumulativeTimePerState[st] + delta
        self.stateTimeDelta = self.stateTimeDelta + delta

        if st = self.session.ps.playing and self.bitrateKbps > 0 then
            self.totalPlayingKbits = self.totalPlayingKbits + (delta/1000) * self.bitrateKbps 's * kbits/s = kbits
        end if
    end function

    self.cwsPsmHasJoined = function () as boolean
        self = m
        return self.joinTimeMs >= 0
    end function

    self.cwsPsmOnStateChange = function (sessionTimeMs as integer, newState as string, data as dynamic) as object
        self = m
        ps = self.session.ps
        if newState=invalid or (self.curState<>ps.error and self.curState=newState) or (self.curState=ps.error and newState=ps.stopped) then
            return invalid
        end if
        ct = self.cumulativeTimePerState
        hasJoined = self.cwsPsmHasjoined()
        evt = invalid
        self.cwsPsmUpdateStateCumulativeTime(sessionTimeMs)
        if not hasJoined and newState=ps.playing then
            ' we have a join
            self.joinTimeMs = sessionTimeMs
            ct[ps.buffering] = 0
        else if newState=ps.error then
            if data=invalid then
                data = { ft: false,
                         err: "ERROR_STATE"}
            end if
            if not (type(data.err)="String" or type(data.err)="roString") then
                self.utils.log("Wrong error message type.")
            end if
            if not (type(data.ft)="Boolean" or type(data.ft)="roBoolean") then
                self.utils.log("Wrong ft type.")
            end if
            evt = {
                t: "CwsErrorEvent",
                ft: data.ft,
                err: data.err,
            }
            if not hasJoined and data.ft then
                self.joinTimeMs = -2 'error while joining
            end if
        else if hasJoined then
            ' The playerStateChangeEvent is not supported for now.
            'evt = {
            '    type: "CwsPlayerStateChangeEvent",
            '    prevState: strtoi(self.curState),
            '    timeInStateMs: ct[self.curState],
            '    newState: strtoi(newState),
            '}
            if newState=ps.buffering then
                self.totalBufferingEvents = self.totalBufferingEvents + 1
            end if
        end if
        self.session.cws.utils.log("STATE CHANGE FROM "+self.curState+" to "+newState)
        self.curState = newState
        self.stateTimeDelta = 0
        if evt <> invalid then
            evt.st = sessionTimeMs
        end if
        return evt
    end function

    self.cwsPsmOnBitrateChange = function (sessionTimeMs as integer, newBitrateKbps as integer) as object
        self = m
        if self.bitrateKbps = newBitrateKbps then
            return invalid
        end if
        self.cwsPsmUpdateStateCumulativeTime(sessionTimeMs)
        brc = {
            t: "CwsBitrateChangeEvent",
            nbr: newBitrateKbps,
        }
        if self.bitrateKbps <> -1 then
            brc.pbr = self.bitrateKbps
        end if
        self.bitrateKbps = newBitrateKbps
        return brc
    end function

    self.cwsPsmGetPlayerMeasurements = function (sessionTimeMs as integer) as object
        self = m
        self.cwsPsmUpdateStateCumulativeTime(sessionTimeMs)
        ps = self.session.ps
        ct = self.cumulativeTimePerState
        pt = ct[ps.playing]
        if pt > 0 then
            bt = ct[ps.buffering]
            averageBitrateKbps = int(self.totalPlayingKbits / (pt / 1000) ) 'kbits/s
        else
            bt = 0   'ignore initial buffering
            averageBitrateKbps = 0
        end if
        data = {
            tbe: self.totalBufferingEvents,
            jt: self.joinTimeMs,
            rs: self.resource,
            url: self.streamUrl,
            cdn: self.cdnName,
            abr: averageBitrateKbps,
            ps: strtoi(self.curState),
            tpt: pt,
            tbt: bt,
            tpst: ct[ps.paused],
            tst: ct[ps.stopped]
        }
        if self.bitrateKbps <> -1 then
            data.cbr =  self.bitrateKbps
        end if
        if self.encodedFramerate <> -1 then
            data.efps = self.encodedFramerate
        end if
        if self.contentLength <> -1 then
            data.cl = self.contentLength
        end if
        return data
    end function

    return self
end function

' Copyright: Conviva Inc. 2011-2012
' Conviva LivePass Brightscript Client library for Roku devices
' LivePass Version: 2.78.0.16704
' authors: Alex Roitman <shura@conviva.com>
'          George Necula <necula@conviva.com>
'

''''
'''' Utilities
''''
' A series of methods used to access the platform services
' This function will construct a singleton object with the platform utilities.
' For each call to ConvivaUtils() there should be a call to utils.cleanup ()
function cwsConvivaUtils()  as object
    ' We only want a single Utils object around
    globalAA = GetGlobalAA()
    self = globalAA.cwsConvivaUtils
    if self <> invalid then
        self.refcount = 1 + self.refcount
        return self
    end if
    self  = { }
    self.refcount = 1     ' Since the utilities may be shared across modules, we keep a reference count
                          ' to know when we need to really clean up
    globalAA.cwsConvivaUtils = self
    self.regexes = invalid
    self.settings = cwsConvivaSettings ()
    self.httpPort = invalid ' the PORT on which we will be listening for the HTTP responses
    self.logBuffer = [ ]   ' We keep here a list of the last few log entries
    self.logBufferMaxSize = 32

    self.availableUtos = [] ' A list of available UTO objects for sending POSTs
    self.pendingRequests = { } ' A map from SourceIdentity an object { uto, callback }

    self.pendingTimers = { } ' A map of timers indexsed by their id : { timer (roTimespan), timerIntervalMs }
    self.nextTimerId   = 0

    self.start = function ()
        ' Start the
        self = m
        self.regexes = self.cwsRegexes ()
        self.httpPort = CreateObject("roMessagePort")
        for ix = 1 to self.settings.maxUtos
            uto = CreateObject("roUrlTransfer")
            uto.SetCertificatesFile("common:/certs/ca-bundle.crt")
            uto.SetPort(self.httpPort)
            ' By default roku adds a Expect: 100-continue header. This does
            ' not work properly with the Touchstone HTTPS redirectors, and it
            ' is only an optimization, so we turn it off here.
            uto.AddHeader("Expect", "")
            self.availableUtos.push(uto)
        end for
    end function

    self.cleanup = function () as void
        self = m
        self.refcount = self.refcount - 1
        if self.refcount > 0 then
            self.log("ConvivaUtils not yet cleaning. Refcount now "+stri(self.refcount))
            return
        end if
        if self.refcount < 0 then
            print "ERROR: cleaning ConvivaUtils too many times"
            return
        end if
        self.log("Cleaning up the utilities")
        for each tid in self.pendingTimers
            self.cleanupTimer(self.pendingTimers[tid])
        end for
        self.pendingTimers.clear ()
        self.availableUtos.clear()

        self.logBuffer = invalid
        self.httpPort = invalid

        GetGlobalAA().delete("cwsConvivaUtils")
    end function

    ' Time since Epoch
    ' We do not get it in ms, because that would require a float and Roku seems
    ' to use single-precision for floats
    ' We try to force it as a double
    self.epochTimeSec = function ()
        dt = CreateObject("roDateTime")
        return 0# + dt.asSeconds() + (dt.getMilliseconds () / 1000.0#)
    end function

    self.randInt = function () as integer
        return  int(2147483647*rnd(0))
    end function

     ' Log a string message
     self.log = function (msg as string) as void
            self = m
            if self.logBuffer <> invalid then
                dt = CreateObject("roDateTime")
                ' Poor's man printing of floating points
                msec = dt.getMilliseconds ()
                msecStr = stri(msec).trim()
                if msec < 10:
                    msecStr = "00" + msecStr
                else if msec < 100:
                    msecStr = "0" + msecStr
                end if
                msg = "[" + stri(dt.asSeconds()) + "." + msecStr + "] " + msg
                self.logBuffer.push(msg)
                if self.logBuffer.Count() > self.logBufferMaxSize then
                    self.logBuffer.Shift()
                end if
            else
                print "WARNING: called log after utils was cleaned"
            end if
            ' The enableLogging flag controls ONLY the printing to the console
            if self.settings.enableLogging then
                print "CWS: "+msg
            end if
      end function

      ' Log an error message
      self.err = function (msg as string) as void
            m.log("ERROR: "+msg)
      end function

      ' Get and consume the log buffer
      self.getLogs = function ()
        self = m
        res = self.logBuffer
        self.logBuffer = [ ]
        return res
      end function

      ' Read local data
      self.readLocalData = function (key as string) as string
          sec = CreateObject("roRegistrySection", "Conviva")
          if sec.exists(key) then
              return sec.read(key)
          else
              return ""
          end If
       end function

       ' Write local data
       self.writeLocalData = function (key as string, value as string)
          sec = CreateObject("roRegistrySection", "Conviva")
          sec.write(key, value)
          sec.flush()
       end function

       ' Delete local data
       self.deleteLocalData = function ( )
           sec = CreateObject("roRegistrySection", "Conviva")
           keyList = sec.GetKeyList ()
           For Each key In keyList
               sec.Delete(key)
           End For
           sec.flush ()
       end Function

       ' Encode JSON
       self.jsonEncode = Function (what As object) As object
          self = m
          Return self.cwsJsonEncodeDict(what)
       End Function

       ' Decode JSON
       self.jsonDecode = Function (what As String) As object
          self = m
          Return self.cwsJsonParser(what)
       End Function

       ' Send a POST request
       self.sendPostRequest = function (url As String, request as String, callback As Function, callbackObj as dynamic) as object
           self = m

           ' See if we have an available UTO to use
           uto = self.availableUtos.pop()
           if uto = invalid
               self.err("Cannot send POST, out of UTO objects")
               return invalid
           end if

           ' Send the actual post request
           uto.SetUrl(url)
           if uto.AsyncPostFromString(request) Then
               reqId = uto.GetIdentity ()
               self.pendingRequests[stri(reqId)] = {
                   callback : callback,
                   callbackObj : callbackObj,
                   uto: uto
               }
               self.log("Posted request #"+stri(reqId)+" to "+url)
               l = 0
               for each item in self.pendingRequests
                   l = l + 1
               end for
               self.log("Pending requests size is"+stri(l))
           else
               self.err("POST Request failed")
               self.availableUtos.push(uto)
               return invalid
           end if
       end Function

       ' Process a urlEvent and return true if we recognized it
       self.processUrlEvent = Function (convivaEvent As object) As Boolean
           self = m
           sourceId = convivaEvent.GetSourceIdentity ()
           reqData = self.pendingRequests[stri(sourceId)]
           If reqData = invalid Then
               ' We do not recognize it
               self.err("Got unrecognized response")
               Return False
           End If
           self.pendingRequests.delete(stri(sourceId))
           self.availableUtos.push(reqData.uto)
           respData = ""
           respCode = convivaEvent.GetResponseCode()
           If respCode = 200 Then
               reqData.callback(reqData.callbackObj, True, convivaEvent.GetString())
           Else
               reqData.callback(reqData.callbackObj, False, convivaEvent.GetFailureReason())
           End If
      End Function

      ' Timers
      ' Too many timers will degrade performance of the main loop
      self.createTimer = Function (callback As Function, callbackObj, intervalMs As Integer, actionName As String)
          self = m
          timerData = {
              timer : CreateObject("roTimespan"),  ' Will be marked when we fire
              intervalMs : intervalMs,
              callback : callback,
              callbackObj : callbackObj,
              actionName : actionName,
              timerId : stri(self.nextTimerId),
              fireOnce : False,
              }
           timerData.timer.Mark ()
           self.pendingTimers[timerData.timerId] = timerData
           self.nextTimerId = 1 + self.nextTimerId
           Return timerData
      End Function

      ' Schedule an action after a certain number of milliseconds (one-fire timer)
      self.scheduleAction = Function(callback As Function, callbackObj as dynamic, intervalMs As Integer, actionName As String)
           self = m
           timerData = self.createTimer (callback, callbackObj, intervalMs, actionName)
           timerData.fireOnce = True
           return timerData
      End Function

      self.cleanupTimer = Function (timerData As dynamic)
          m.pendingTimers.delete(timerData.timerId)
          timerData.clear ()
      End Function

      self.updateTimerInterval = function (timerData as object, newIntervalMs as integer)
         timerData.intervalMs = newIntervalMs
      end function

      ' Find how much time until the next registered timer event
      ' While doing this, process the timer events that are due
      ' Return invalid if there is no timer
      self.timeUntilTimerEvent = Function ()
          self = m
          res  = invalid
          For Each tid in self.pendingTimers
              convivaTimer = self.pendingTimers[tid]
              timeToNextFiring = convivaTimer.intervalMs - convivaTimer.timer.TotalMilliseconds ()
              If timeToNextFiring <= 0 Then
                  ' Fire the action
                  convivaTimer.callback (convivaTimer.callbackObj)
                  If convivaTimer.fireOnce Then
                      ' TODO: can we change the array while iterating over it ?
                      self.pendingTimers.delete(tid)
                      timeToNextFiring = invalid
                  Else
                      convivaTimer.timer.Mark ()
                      timeToNextFiring = convivaTimer.intervalMs
                  End If
              End If
              if timeToNextFiring <> invalid then
                  If res = invalid then
                      res = timeToNextFiring
                  else if timeToNextFiring < res Then
                      res = timeToNextFiring
                  End If
              end if
          End For
          Return res
      End Function

      self.set = function ()
      end function

    ' A wrapper around the system's wait that will process our timers, HTTP requests, and videoEvents
    ' If it gets an event that is not private to Conviva, it will return it
    ' ConvivaObject should be the reference to the object returned by ConvivaLivePassInit
    self.wait = function (timeout as integer, port as object, customWait as dynamic, ConvivaObject as object) as dynamic
        self = m

        if timeout = 0 then
            timeoutTimer = invalid
        else
            timeoutTimer = CreateObject("roTimespan")
            timeoutTimer.mark()
        end if

        ' Run the event loop, return from the loop with an event that we have not processed
        while True
            convivaEvent = invalid
            ' Run the ready timers, and get the time to the next timer
            timeToNextTimer = self.timeUntilTimerEvent()

            ' Perhaps we are done
            if timeout > 0 Then
                timeToExternalTimeout = timeout - timeoutTimer.TotalMilliseconds()
                If timeToExternalTimeout <= 0 Then
                    ' We reached the external timeout
                    Return invalid

                Else If timeToNextTimer = invalid or timeToExternalTimeout < timeToNextTimer Then
                    realTimeout = timeToExternalTimeout
                Else
                    realTimeout = timeToNextTimer
                End If
            Else if timeToNextTimer = invalid then
                ' Even if we have no timers, or external constraints, do not block on wait for too long
                ' We need this to ensure that we can periodically poll our private ports
                realTimeout = 100
            else
                realTimeout = timeToNextTimer
            End If

            ' Sanitize the realTimeout: range 0-100ms:
            ' We don't want to block for more than 100 ms
            if realTimeout > 100 then
                realTimeout = 100
            else if realTimeout <= 0 then
                ' This happened before because timeUntilTimerEvent returned negative value
                realTimeout = 1
            end if

            ' Wait briefly for messages on our httpPort
            httpEvent = wait(1, self.httpPort)
            if httpEvent <> invalid then
                if type(httpEvent) = "roUrlEvent" then            'Process network response
                    if not self.processUrlEvent(httpEvent) Then
                        ' This should never happen, because httpPort is private
                        Return httpEvent
                    End if
                end if
            end if

            'Call either real wait or custom wait function
            if customWait = invalid then
                convivaEvent = wait(realTimeout, port)
            else
                convivaEvent = customWait(realTimeout, port)
            end if

            if convivaEvent<>invalid then   'Process player events
                if type(convivaEvent) = "roVideoScreenEvent" or type(convivaEvent) = "roVideoPlayerEvent" Then
                    if ConvivaObject <> invalid and ConvivaObject.session <> invalid then
                        ConvivaObject.session.cwsProcessVideoEvent (convivaEvent)
                        ' We would like to use the code below instead,
                        ' but message ports can't be comared on Roku!
                        'if ConvivaObject.session.screen.getMessagePort() = port then
                        '    ConvivaObject.session.cwsProcessVideoEvent (convivaEvent)
                        'else
                        '    self.log("Got video event for the un-monitored screen")
                        'end if
                    else
                        self.log("Got "+type(convivaEvent)+" event type = "+str(convivaEvent.GetType()))
                    end if
                    ' We need to return the event even if we processed it
                    return convivaEvent

                else if type(convivaEvent) = "roUrlEvent" then
                    return convivaEvent

                else
                    self.log("GOT unexpected event "+type(convivaEvent))
                    'print("msg: "+convivaEvent.getMessage()+" index: "+stri(convivaEvent.getIndex())+" data: "+stri(convivaEvent.getData()))
                    'print("Returning to caller")
                    Return convivaEvent
                end if
            end if
        end while

        'Return the event to the caller of cwsWait
        return convivaEvent
    end function

    '===============================
    ' Miscellaneous utility functions
    '================================
    self.cwsRegexes = function () as object
        ret = {}
        q = chr(34) 'quote
        b = chr(92) 'backslash

        'Regular expression needed for json string encoding
        ret.quote = CreateObject("roRegex", q, "i")
        ret.bslash = CreateObject("roRegex", String(2,b), "i")
        ret.bspace = CreateObject("roRegex", chr(8), "i")
        ret.tab = CreateObject("roRegex", chr(9), "i")
        ret.nline = CreateObject("roRegex", chr(10), "i")
        ret.ffeed = CreateObject("roRegex", chr(12), "i")
        ret.cret = CreateObject("roRegex", chr(13), "i")
        ret.fslash = CreateObject("roRegex", chr(47), "i")

        'Regular expression needed for parsing
        ret.cwsOpenBrace = CreateObject( "roRegex", "^\s*\{", "i" )
        ret.cwsOpenBracket = CreateObject( "roRegex", "^\s*\[", "i" )
        ret.cwsCloseBrace = CreateObject( "roRegex", "^\s*\},?", "i" )
        ret.cwsCloseBracket = CreateObject( "roRegex", "^\s*\],?", "i" )

        ret.cwsKey = CreateObject( "roRegex", "^\s*" + q + "(\w+)" + q + "\s*\:", "i" )
        ret.cwsString = CreateObject( "roRegex", "^\s*" + q + "([^" + q + "]*)" + q + "\s*,?", "i" )
        ret.cwsNumber = CreateObject( "roRegex", "^\s*(\-?\d+(\.\d+)?)\s*,?", "i" )
        ret.cwsTrue = CreateObject( "roRegex", "^\s*true\s*,?", "i" )
        ret.cwsFalse = CreateObject( "roRegex", "^\s*false\s*,?", "i" )
        ret.cwsNull = CreateObject( "roRegex", "^\s*null\s*,?", "i" )

        'This is needed to split the scheme://server part of the URL
        ret.resource = CreateObject("roRegex", "(\w+://[\w\d:#@%;$()~_\+\-=\.]+)/.*", "i")

        ' PD-8962: Smooth Streaming support
        ret.ss = CreateObject("roRegex", "\.isml?\/manifest", "i")
        ret.ssAudio = CreateObject("roRegex", "\/Fragments\(audio", "i")
        ret.ssVideo = CreateObject("roRegex", "\/Fragments\(video", "i")
        ret.hls = CreateObject("roRegex", "\.m3u8", "i")

        ' PD-10716: safer handling of roVideoEvent #11, "EventStatusMessage"
        ret.videoTrackUnplayable = CreateObject("roRegex", "^(?=.*\bvideo\b)(?=.*\btrack\b)(?=.*\bunplayable\b)", "i")

        return ret
    end function

    ' PD-8962: Smooth Streaming support
    self.ssFragmentTypeFromUrl = function (streamUrl as string)
        self = m
        if self.regexes.ssAudio.IsMatch(streamUrl) then
            return "audio"
        else if self.regexes.ssVideo.IsMatch(streamUrl) then
            return "video"
        else
            return "unknown"
        end if
    end function

    ' PD-8962: Smooth Streaming support
    self.streamFormatFromUrl = function (streamUrl as string) as string
        self = m
        if self.regexes.ss.IsMatch(streamUrl) then
            return "ism"
        else if self.regexes.hls.IsMatch(streamUrl) then
            return "hls"
        else
            return "mp4"
        end if
    end function

    ' PD-10716: safer handling of roVideoEvent #11, "EventStatusMessage"
    self.getEventStatusMessageType = function (message as string) as string
        self = m
        if self.regexes.videoTrackUnplayable.IsMatch(message) or message = "Content contains no playable tracks." then
            return "error"
        else if message = "Unspecified or invalid track path/url." or message = "ConnectionContext failure" then
            return "error"
        else if message = "startup progress" then
            return "buffering"
        else if message = "start of play" then
            return "playing"
        else if message = "playback stopped" or message = "end of stream" or message = "end of playlist" then
            return "stopped"
        else
            return "unknown"
        end if
    end function

    '================================================
    ' Utility functions for encoding and parsing JSON
    '================================================
    self.cwsJsonEncodeDict = function (dict) as string
        self = m
        ret = box("{")
        notfirst = false
        comma = ""
        q = chr(34)

        for each key in dict
            val = dict[key]
            typestr = type(val)
            if typestr="roInvalid" then
                valstr = "null"
            else if typestr="roBoolean" then
                if val then
                    valstr = "true"
                else
                    valstr = "false"
                end if
            else if typestr="roString" or typestr="String" then
                valstr = self.cwsJsonEncodeString(val)
            else if typestr="roInteger" then
                valstr = stri(val)
            else if typestr="roFloat" or typestr="Double" then
                valstr = self.cwsJsonEncodeDouble(1# * val)
            else if typestr="roArray" then
                valstr = self.cwsJsonEncodeArray(val)
            else
                valstr = self.cwsJsonEncodeDict(val)
            end if
            if notfirst then
                comma = ", "
            else
                notfirst = true
            end if
            ret.appendstring(comma,len(comma))
            ret.appendstring(q,1)
            ret.appendstring(key,len(key))
            ret.appendstring(q,1)
            ret.appendstring(": ", 2)
            ret.appendstring(valstr,len(valstr))
        end for
        return ret + "}"
    end function

    ' We write our own printer for floats, because the built-in "val" prints
    ' something like 1.2345e9, which has too little precision
    self.cwsJsonEncodeDouble = function (fval as Double) as string
        self = m
        ' print "Encoding "+str(fval)
        sign = ""
        if fval < 0 then
           sign = "-"
           fval = - fval
        end if
        ' I tried to convert to Int, but that one seems to use float, so it overflows in strange ways
        ' If we divide by 10K then it seems we can keep the precision up to 3 decimals and work with smaller numbers
        factor = 10000.0#
        fvalHi = Int(fval / factor)
        fvalLo = fval - factor * fvalHi
        ' I have no idea why but sometimes fvalLo as computed above can be negative !
        ' This must be because the Int(... / ...) rounds up ?
        while fvalLo < 0
           fvalHi = fvalHi - 1
           fvalLo = fvalLo + factor
        end while
        fvalLoInt = Int(fvalLo)
        fvalLoFrac = Int(1000 * (fvalLo - fvalLoInt))
        ' Now fval = factor * fvalHi + fvalLoInt + fvalLoFrac / 1000
        ' print "fvalHi=" + stri(fvalHi) + " fvalLo="+str(fvalLo)+" fvalLoInt="+stri(fvalLoInt)+" fvalLoFrac="+stri(fvalLoFrac)
        ' stri will add a blank prefix for the sign
        if fvalHi > 0 then
           fvalHiStr = self.cwsJsonEncodeInt(fvalHi)
        else
           fvalHiStr = ""
        end if
    fvalLoIntStr = self.cwsJsonEncodeInt(fvalLoInt)
    if fvalHi > 0 then
           fvalLoIntStr = String(4 - Len(fvalLoIntStr), "0") + fvalLoIntStr
        end if
        ' print "fvalHiStr="+fvalHiStr+" fvalLoIntStr="+fvalLoIntStr
        fvalLoFracStr = self.cwsJsonEncodeInt(fvalLoFrac)
        if fvalLoFrac > 0 then
           fvalLoFracStr = String(3 - Len(fvalLoFracStr), "0") + fvalLoFracStr
        end if
        result = sign + fvalHiStr + fvalLoIntStr + "." + fvalLoFracStr
        ' print "Result="+result
        return result
    end function

    ' Encode an integer stripping the leading space
    self.cwsJsonEncodeInt = function (ival) as string
        ivalStr = stri(ival)
        if ival >= 0 then
           return Right(ivalStr, Len(ivalStr) - 1)
        else
           return ivalStr
        end if
    end function

    self.cwsJsonEncodeArray = function (array) as string
        self = m
        ret = box("[")
        notfirst = false
        comma = ""

        for each val in array
            typestr = type(val)
            if typestr="roInvalid" then
                valstr = "null"
            else if typestr="roBoolean" then
                if val then
                    valstr = "true"
                else
                    valstr = "false"
                end if
            else if typestr="roString" or typestr="String" then
                valstr = self.cwsJsonEncodeString(val)
            else if typestr="roInteger" then
                valstr = stri(val)
            else if typestr="roFloat" then
                valstr = str(val)
            else if typestr="roArray" then
                valstr = self.cwsJsonEncodeArray(val)
            else
                valstr = self.cwsJsonEncodeDict(val)
            end if
            if notfirst then
                comma = ", "
            else
                notfirst = true
            end if
            ret.appendstring(comma,len(comma))
            ret.appendstring(valstr,len(valstr))
        end for
        return ret + "]"
    end function

    self.cwsJsonEncodeString = function (line) as string
        regexes = m.regexes
        q = chr(34) 'quote
        b = chr(92) 'backslash
        b2 = b+b
        ret = regexes.bslash.ReplaceAll(line, String(4,b))
        ret = regexes.quote.ReplaceAll(ret, b2+q)
        ret = regexes.bspace.ReplaceAll(ret, b2+"b")
        ret = regexes.tab.ReplaceAll(ret, b2+"t")
        ret = regexes.nline.ReplaceAll(ret, b2+"n")
        ret = regexes.ffeed.ReplaceAll(ret, b2+"f")
        ret = regexes.cret.ReplaceAll(ret, b2+"r")
        ret = regexes.fslash.ReplaceAll(ret, b2+"/")
        return q + ret + q
    end function


    '=================================================================
    ' Parse JSON string into a Brightscript object.
    '
    ' This parser makes some simplifying assumptions about the input:
    '
    ' * The dictionaries have keys that *contain only* alphanumeric
    '   characters plus the underscore.  No spaces, apostrophes,
    '   backslashes, hash marks, dollars, percent, and other funny stuff.
    '   If the key contains anything beyond alphanum and underscore,
    '   the parser returns invalid.
    '
    ' * The string values *do not contain* special JSON chars that
    '   need to be escaped (slashes, quotes, apostrophes, backspaces, etc).
    '   If they do, we will include them in the output, meaning the \n will
    '   show as literal \n, and not the new line.
    '   In particular, \" will be literal backslash followed by the quote,
    '   so the string will end there, and the rest will be invalid and we
    '   return invalid.'
    '
    ' * The input *must* be valid JSON. Otherwise we will return invalid.
    '=================================================================
    self.cwsJsonParser = function (jsonString as string) as dynamic
        self = m
        value_and_rest = self.cwsGetValue(jsonString)
        if value_and_rest = invalid then
            return invalid
        end if
        return value_and_rest.value
    end function

    '----------------------------------------------------------
    ' Return key, value and rest of string packed into the dict.
    ' If matlching the key or the value did not work, return invalid.
    '----------------------------------------------------------
    self.cwsGetKeyValue = function (rest as string) as dynamic
        self = m
        regexes = self.regexes
        result = {}

        if not regexes.cwsKey.IsMatch(rest) then
            return invalid
        end if

        result.key = regexes.cwsKey.Match(rest)[1]
        rest = regexes.cwsKey.Replace(rest, "")

        value_and_rest = self.cwsGetValue(rest)
        if value_and_rest = invalid then
            return invalid
        end if
        result.value = value_and_rest.value
        result.rest = value_and_rest.rest

        return result
    end function

    '----------------------------------------------------------
    ' Return the value and rest of string packed into the dict.
    ' If we could not match the value, return invalid.
    '----------------------------------------------------------
    self.cwsGetValue = function (rest as string) as dynamic
        self = m
        regexes = self.regexes
        result = {}

        'The next token determines the value type
        if regexes.cwsString.IsMatch(rest) then            'string
            result.value = regexes.cwsString.Match(rest)[1]
            result.rest = regexes.cwsString.Replace(rest, "")
        else if regexes.cwsNumber.IsMatch(rest) then      'number
            result.value = val(regexes.cwsNumber.Match(rest)[1])
            result.rest = regexes.cwsNumber.Replace(rest, "")
        else if regexes.cwsOpenBracket.IsMatch(rest) then 'list
            value = []
            rest = regexes.cwsOpenBracket.Replace(rest, "")
            while true
                if regexes.cwsCloseBracket.IsMatch(rest) then
                    rest = regexes.cwsCloseBracket.Replace(rest, "")
                    exit while
                end if
                value_and_rest = self.cwsGetValue(rest)
                if value_and_rest = invalid then
                    return invalid
                end if
                value.Push(value_and_rest.value)
                rest = value_and_rest.rest
            end while
            result.value = value
            result.rest = rest
        else if regexes.cwsOpenBrace.IsMatch(rest) then    'dict
            value = {}
            rest = regexes.cwsOpenBrace.Replace(rest, "")
            while true
                if regexes.cwsCloseBrace.IsMatch(rest) then
                    rest = regexes.cwsCloseBrace.Replace(rest, "")
                    exit while
                end if
                key_value_and_rest = self.cwsGetKeyValue(rest)
                if key_value_and_rest = invalid then
                    return invalid
                end if
                value.AddReplace(key_value_and_rest.key, key_value_and_rest.value)
                rest = key_value_and_rest.rest
            end while
            result.rest = rest
            result.value = value
        else if regexes.cwsTrue.IsMatch(rest) then      'true
            result.value = true
            result.rest = regexes.cwsTrue.Replace(rest, "")
        else if regexes.cwsFalse.IsMatch(rest) then     'false
            result.value = false
            result.rest = regexes.cwsFalse.Replace(rest, "")
        else if regexes.cwsNull.IsMatch(rest) then      'null
            result.value = invalid
            result.rest = regexes.cwsNull.Replace(rest, "")
        else
            return invalid
        end if

        return result
    end function

    self.start ()
    return self
End Function

'--------------
' Configuration
'--------------
function cwsConvivaSettings() as object
    cfg = {}
    ' The next line is changed by set_versions
    cfg.version = "2.78.0.16704"

    cfg.enableLogging = true                       'change to false to disable debugging output
    cfg.defaultHeartbeatInvervalMs = 20000         ' 20 sec HB interval
    cfg.heartbeatIntervalMs = cfg.defaultHeartbeatInvervalMs
    cfg.maxUtos = 5  ' How large is the pool of UTO objects we re-use for POSTs

    cfg.maxEventsPerHeartbeat = 10
    cfg.apiKey = ""

    cfg.defaultGatewayUrl = "https://cws.conviva.com"
    cfg.gatewayUrl        = cfg.defaultGatewayUrl
    cfg.gatewayPath     = "/0/wsg" 'Gateway URL
    cfg.protocolVersion = "1.5"

    cfg.printHb = true

    cfg.device = "roku"
    cfg.deviceType = "Settop"
    cfg.os = "ROKU"
    cfg.platform = "Roku"

    d = CreateObject("roDeviceInfo")
    cfg.deviceVersion = d.GetModel()
    cfg.osVersion = d.GetVersion()
    cfg.platformVersion = d.GetVersion()

    return cfg
end function
