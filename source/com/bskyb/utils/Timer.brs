'' Timer.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function Timer(id="" as String, delay=1000 as Integer, repeatCount=0 as Integer) as Object

    this = EventDispatcher(id)

    ' STATIC PROPERTIES
    this.TOSTRING = "<Timer>"

    ' PROPERTIES
    this.currentCount = 0
    this.delay = delay
    this.running = false
    this.timeSpan = createObject("roTimespan")

    ' DA FUQ!?
    this.repeatCount = repeatCount - 1

    ' METHODS
    this.start = function()
        if (not m.running)
            TimerManager().add(m)
            m.running = true
            m.timeSpan.mark()
        end if
    end function

    this.stop = function()
        if (m.running)
            TimerManager().remove(m)
            m.running = false
        end if
    end function

    this.reset = function()
        m.stop()
        m.currentCount = 0
    end function

    this.update = function() as Void
        if (not m.running) return

        if (m.timeSpan.totalMilliseconds() > m.delay)
            m.timeSpan.mark()
            ' If -1, repeat foreverrrrrrrrrrrrrr
            if (m.repeatCount = -1)
                m.currentCount = m.currentCount + 1
                m.dispatchEvent(Event({
                    eventType: "onTimer",
                    target: m
                }))
            else if (m.currentCount < m.repeatCount)
                m.currentCount = m.currentCount + 1
                m.dispatchEvent(Event({
                    eventType: "onTimer",
                    target: m
                }))
            else if (m.currentCount = m.repeatCount)
                m.stop()
                m.dispatchEvent(Event({
                    eventType: "onTimerComplete",
                    target: m
                }))
            end if
        end if
    end function

    return this

end function