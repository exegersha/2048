'' VideoPlayer.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function VideoPlayer(id="" as String) as Object

    if(m.videoPlayerInstance = invalid)

        this = DisplayObject(id)

        ' STATIC PROPERTIES
        this.TOSTRING = "<VideoPlayer>"
        this.MSG_EVENT_BUFFERING = "startup progress"
        this.MSG_EVENT_STARTING = "start of play"
        this.MSG_EVENT_ENDOFSTREAM = "end of stream"

        'TODO: error string - need to investigate
        this.MSG_EVENT_VIDEOFAIL = "The requested operation is not implemented."

        this.DEFAULT_SEEK_SPEED = 60 ' 1 minute

        ' PROPERTIES
        this.player = invalid
        this.progress = 0  ' loading progress
        this.playbackPosition = 0
        this.curentAudioStreamBandwidth = 0
        this.curentVideoStreamBandwidth = 0

        ' METHODS
        this.init = function(w as Integer, h as Integer, x=0 as Integer, y=0 as Integer)
            'm.setXY(x, y)
            m.width = w
            m.height = h
            targetRect = { x: x, y: y, w: w, h: h }
            m.player.SetDestinationRect(targetrect)
            m.player.SetMaxVideoDecodeResolution(1280, 720)
        end function

        this.getPlaybackDuration = function() as integer
            return m.player.getPlaybackDuration()
        end function

        this.dispose = function()
            m.player = invalid
        end function

        this.reset = function()
            m.player.clearContent()
            m.player.stop()
        end function

        ' Currently play function is only set up to play HLS smooth streams. This should be extended to be more generic.
        this.play = function(stream as String, drm="" as String, maxBandwidth=-1 as Integer, streamFormat="ism" as String)
            'print ">>>>PLAY>>>>" stream
            bitrates  = [0]          ' 0 = no dots, adaptive bitrate
            'bitrates  = [348]    ' <500 Kbps = 1 dot
            'bitrates  = [664]    ' <800 Kbps = 2 dots
            'bitrates  = [996]    ' <1.1Mbps  = 3 dots
            'bitrates  = [2048]    ' >=1.1Mbps = 4 dots

            qualities = ["HD"]

            videoclip = CreateObject("roAssociativeArray")
            videoclip.StreamBitrates = bitrates
            videoclip.StreamUrls = stream
            'videoclip.StreamUrls = "http://xb-nowtv.vod.sky.com/skyplayer/SMPCMOVIES/43cc146509b57310VgnVCM1000000b43150a____/M_KungFuPanda2_2011_03160860_720p-ARCHIVE_720ss.ism/Manifest"
            videoclip.StreamQualities = qualities
            videoclip.StreamFormat = streamformat
            ' License acquisition server details
            videoclip.encodingType =  "PlayReadyLicenseAcquisitionUrl"
            videoclip.encodingKey = drm
            if(maxBandwidth <> -1) videoclip.MaxBandwidth = maxBandwidth
            'videoclip.encodingKey = "https://services.nowtv.com/video/licence?sessionId=CB478240EF21EF9A07E158442AC4138E.PD041SP1A1&licenceAcquisitionUrl=aHR0cDovL3NteGIuc2t5LmNvbS92b2Qvdmlld2xlc3Mvc2ltcGxlUHJvZ3Jlc3NpdmVMaWNlbmNlLmRvP3R5cGU9cGxheXJlYWR5JmFzc2V0SWQ9NDNjYzE0NjUwOWI1NzMxMFZnblZDTTEwMDAwMDBiNDMxNTBhX19fXyZ2aWRlb0lkPWM3NTQyYjU1MzhiYzMzMTBWZ25WQ00xMDAwMDAwYjQzMTUwYV9fX18"

            m.player.clearContent()
            m.player.addContent(videoclip)
            m.player.SetCGMS(3)
            m.player.play()

        end function

        this.pause = function()
            m.player.pause()
        end function

        this.resume = function()
            m.player.resume()
        end function

        this.stop = function()
            m.player.stop()
        end function

        this.rewind = function(speed=-m.DEFAULT_SEEK_SPEED as Integer)
            m.playbackPosition = m.playbackPosition + speed
            m.player.seek(m.playbackPosition * 1000)
        end function

        this.fastForward = function(speed=m.DEFAULT_SEEK_SPEED as Integer)
            m.playbackPosition = m.playbackPosition + speed
            m.player.seek(m.playbackPosition * 1000)
        end function

        this.seek = function(seekPos as Integer)
            m.playbackPosition = seekPos
            m.player.seek(m.playbackPosition * 1000)
        end function

        this.processMessage = function( msg as Object )
            'print msg.GetType(); ","; msg.GetIndex(); ": "; msg.GetMessage()
            if(msg.isStatusMessage())
                msgContents = msg.getMessage()
                if(msgContents = m.MSG_EVENT_BUFFERING)
                    'print "loading"
                    m.dispatchEvent(Event({
                        eventType: "onVideoBuffering",
                        target: m
                    }))
                else if(msgContents = m.MSG_EVENT_STARTING)
                    'print "FINISHED"
                    m.dispatchEvent(Event({
                        eventType: "onVideoLoaded",
                        target: m
                    }))
                else if(msgContents = m.MSG_EVENT_ENDOFSTREAM)
                    m.dispatchEvent(Event({
                        eventType: "onVideoCompleted",
                        target: m
                    }))
                else if(msgContents = m.MSG_EVENT_VIDEOFAIL)
                    ' TRY AGAIN
                    m.player.stop()
                    m.player.play()
                end if
            else if (msg.isPlayBackPosition())
                m.playbackPosition = msg.GetIndex()
                m.dispatchEvent(Event({
                    eventType: "onVideoPlayback",
                    target: m
                }))
            else if (msg.isPaused())
                print "VIDEOPLAYER:MSG PAUSED"
            else if (msg.isResumed())
                print "VIDEOPLAYER:MSG RESUMED"
            else if (msg.isStreamSegmentInfo())
                info = msg.GetInfo()

                if (StringContains(info.SegUrl, "audio"))
                    m.curentAudioStreamBandwidth = info.StreamBandwidth
                else if (StringContains(info.SegUrl, "video"))
                    m.curentVideoStreamBandwidth = info.StreamBandwidth
                end if

                m.dispatchEvent(Event({
                    eventType: "onVideoSegmentInfoReceived",
                    target: m
                }))
            else
                ' print "!!! ERROR: Unknown video status message."
                ' print msg
            end if
        end function

        ' CONSTRUCTOR CODE

        this.player = createObject("roVideoPlayer")
        this.player.SetPositionNotificationPeriod(1)
        this.player.SetCGMS(3)
        this.player.SetCertificatesFile("common:/certs/ca-bundle.crt")

        m.videoPlayerInstance = this

    end if

    return m.videoPlayerInstance

end function