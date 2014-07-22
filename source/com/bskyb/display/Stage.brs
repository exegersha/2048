' The main GUI component and the engine, this is where the framework kicks off.
' This is where the main loop lives, and here is also where the native components "roScreen",
' "roMessagePort" and "roTimespan" gets created.
' @name Stage
' @inherits DisplayObjectContainer
' @return {Object} stageInstance, the Stage as a SINGLETON
function Stage () as Object

    if (m.stageInstance = invalid)

        this = DisplayObjectContainer("stage")

        ' STATIC PROPERTIES
        this.TOSTRING = "<Stage>"
        this.FIRST_KEY_REPEAT_TIME = 500
        this.SUBSEQUENT_KEY_REPEAT_TIME = 150

        ' PROPERTIES
        this.appRunning = true
        this.focusedComponent = this
        this.msgPort = CreateObject("roMessagePort")
        ' Copy a reference of the message port to disable/restore it in the main loop
        this.bkpMsgPort = this.msgPort
        this.screen = CreateObject("roScreen", true, 1280, 720)
        this.screen.setAlphaEnable(true)
        this.screen.SetMessagePort(this.msgPort)
        this.screenColour = &hEDEDEDFF ' Safe white

        this.mainContainer = DisplayObjectContainer("mainContainer")
        this.mainContainer.setScreen(this.screen)
        this.addChild(this.mainContainer)

        this.overlayContainer = DisplayObjectContainer("overlayContainer")
        this.overlayContainer.setScreen(this.screen)
        this.addChild(this.overlayContainer)

        this.keyComboManager = KeyComboManager()
        this.timerManager = TimerManager()
        this.tweenManager = TweenManager()

        this.assetService = AssetService()
        this.assetService.init(this.msgPort)

        this.bigFatPipe = BigFatPipe()
        this.bigFatPipe.init(this.msgPort, 20) ' set how many concurrent connections

        this.videoPlayer = VideoPlayer()
        this.videoPlayer.player.setMessagePort(this.msgPort)
        this.isConvivaEnabled = false

        this.timeSpan = createObject("roTimespan")
        this.keyPressed = invalid
        this.keyRepeatTimer = Timer("keyRepeat", this.FIRST_KEY_REPEAT_TIME)
        this.keyRepeatTimer.addEventListener({
            eventType: "onTimer",
            handler: "onKeyRepeatHandler",
            context: this
        })

        this.autoShutdownTimer = invalid
        this.autoShutDownInterval = 14400000 ' 4 Hours. Default. Will be set from the config.

        ' Adding any children to "Stage" directly will proxy to the
        ' mainContainer instead, hence children will be added to the mainContainer.
        ' @Override
        ' @See DisplayObjectContainer
        ' @param {Object} child to add
        this.addChild = function (child as Object) as Void
            m.mainContainer.addChild(child)
        end function

        ' Removing any child from "Stage" will proxy to remove from
        ' the mainContainer instead, hence children will be removed from the mainContainer.
        ' @Override
        ' @See DisplayObjectContainer
        ' @param {Object} child to remove
        this.removeChild = function (child as Object) as Void
            m.mainContainer.removeChild(child)
        end function

        ' Sets focus to specified component
        ' @param {Object} component, object to give focus to.
        this.setFocus = function (component as Object) as Void
            if (component <> invalid)
                m.removeFocus()

                m.focusedComponent = component
                m.focusedComponent.onFocusIn(Event({
                    eventType: "onFocusIn",
                    target: m
                }))

                m.stopKeyRepeatTimer()
            end if
        end function

        ' Removes focus from the focusedComponented component and dispatches event.
        this.removeFocus = function () as Void
            if (m.focusedComponent <> invalid)
                m.focusedComponent.onFocusOut(Event({
                    eventType: "onFocusOut",
                    target: m
                }))
            end if

            m.focusedComponent = invalid
        end function

        ' Gets the currently focused component
        ' @return {Object} currently focused component or "invalid" if no component has focus.
        this.getFocus = function () as Dynamic
            return m.focusedComponent
        end function

        ' This re-renders the screen and refreshes all components.
        this.reRender = function () as Void
            m.screen.clear(m.screenColour)
            m.render()
            m.screen.swapBuffers()
        end function

        ' Returns time since start of application in ms.
        ' @return {Integer} time in milliseconds since app start.
        this.getTimeSinceAppStart = function () as Integer
            return m.timeSpan.totalMilliseconds()
        end function

        ' Handler for the onKeyRepeat event.
        ' @param {Object} eventObj, event object.
        this.onKeyRepeatHandler = function (eventObj as Object) as Void
            m.keyRepeatTimer.delay = m.SUBSEQUENT_KEY_REPEAT_TIME ' After first key repeat, repeat key needs to occur at a much quicker rate
            m.focusedComponent.onKeyDown(m.keyPressed)
        end function

        ' Stops the key repeat timer.
        this.stopKeyRepeatTimer = function () as Void
            m.keyRepeatTimer.delay = m.FIRST_KEY_REPEAT_TIME ' Set back key repeat to half second
            m.keyRepeatTimer.stop()
        end function

        ' Enables conviva logging
        this.enableConviva = function () as Void
            m.isConvivaEnabled = true
        end function

        ' Disables conviva logging
        this.disableConviva = function () as Void
            m.isConvivaEnabled = false
        end function

        ' Starts the main loop. This is where all incomming messages gets processed.
        this.start = function () as Void

            m.restartAutoShutDownTimer()

            while (m.appRunning)
                msg = invalid

                ' [Hack] - Restors the message port so we continue to listen to/queue up any message.
                m.restoreMsgPort()

                if (m.isConvivaEnabled)
                    msg = ConvivaWait(1, m.msgPort, invalid)
                else
                    msg = m.msgPort.GetMessage() ' Get a message, if available
                end if

                if (msg <> invalid)
                    ' [Hack] - Disables the message port so no message/input gets received and processed.
                    ' Works as an aid primaraly for key throttling/button bashing, while processing messages.
                    m.disableMsgPort()

                    msgType = type(msg)

                    if (msgType = "roUniversalControlEvent")
                        m.keyPressed = msg.getInt()

                        if (m.focusedComponent <> invalid)
                            if( m.keyPressed < 100) ' KEY DOWN MSG
                                m.keyComboManager.processKey(m.keyPressed)
                                m.focusedComponent.onKeyDown(m.keyPressed)
                                m.keyRepeatTimer.start()
                                m.restartAutoShutDownTimer()

                            else ' KEY UP MSG
                                m.focusedComponent.onKeyUp(m.keyPressed)
                                m.stopKeyRepeatTimer()
                            end if

                        else
                            print m.TOSTRING; " LOST FOCUS"
                        end if

                    else if (msgType = "roUrlEvent")
                        ' Process all url event messages
                        m.bigFatPipe.processMessage(msg)

                    else if (msgType = "roTextureRequestEvent")
                        ' Process all texture event messages
                        m.assetService.processMessage(msg)

                    else if (msgType = "roVideoPlayerEvent")
                        ' Process all video player messages
                        m.videoPlayer.processMessage(msg)

                    else if (msgType = "roSocketEvent")
                        ' Process all socket messages
                        print "socket event"

                    else
                        print "UNHANDLED MESSAGE: "; type(msg)
                    end if
                end if

                m.timerManager.update()
                m.tweenManager.update()

                ' Render screen on every "tick".
                m.reRender()
            end while
        end function

        ' Disables the message port so that no messages gets processed.
        this.disableMsgPort = function () as Void
            m.msgPort = invalid
        end function

        ' Restores the message port to the default one.
        this.restoreMsgPort = function () as Void
            m.msgPort = m.bkpMsgPort
        end function

        ' THIS COULD PROBABLY GO!!! NEVER USED
        ' this.flushMessageBuffer = function () as Void
        '     msg = invalid

        '      while (msg = invalid)
        '         msg = invalid
        '         msg = wait(1, m.msgPort)
        '      end while
        ' end function

        ' Restarts the auto shut down timer.
        this.restartAutoShutDownTimer = function () as Void
            if (m.autoShutDownTimer <> invalid) AND (m.autoShutDownTimer.delay <> m.autoShutDownInterval)
                m.autoShutdownTimer.stop()
                m.autoShutdownTimer = invalid
            end if

            if (m.autoShutDownTimer = invalid)
                m.autoShutDownTimer = Timer("AutoShutdownTimer", m.autoShutDownInterval, 1)
                m.autoShutDownTimer.addEventListener({
                    eventType: "onTimerComplete",
                    handler: "onAutoShutDownTimerCompleteHandler",
                    context: m
                })
            end if

            m.autoShutdownTimer.reset()
            m.autoShutdownTimer.start()
        end function

        ' Override if something needs to be done when the auto shutdown timer fires.
        ' Handler for the onAutoShutDownTimerComplete event.
        ' @param {Object} eventObj, event object.
        this.onAutoShutDownTimerCompleteHandler = function (eventObj as Object) as Void
        end function

        ' Closes the app by firing off an event and then
        ' terminating the main loop.
        this.closeApp = function () as Void
            m.dispatchEvent(Event({
                eventType: "onAppClose",
                target: m
            }))
            m.appRunning = false

            print "--------- App TERMINATED -------------"
        end function

        m.stageInstance = this

    end if

    return m.stageInstance

end function
