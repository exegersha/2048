'' DateUtils.brs


function getCurrentDateTime() as Object
    currentTime = CreateObject("roDateTime")
    currentTime.mark()
    currentTime.toLocalTime()
    
    return currentTime
end function

function getDateTimeFromSeconds(seconds as Integer) as Object
    theTime = CreateObject("roDateTime")
    theTime.fromSeconds(seconds)
    theTime.toLocalTime()
    
    return theTime
end function

function TimeToLocalStringNoOffset (seconds as Integer, format="12h" as String)
    theTime = CreateObject("roDateTime")
    theTime.fromSeconds(seconds)

    return TimeToString(theTime, format)
end function

' converts a time from epoch time to string in local time, either 24 or 12h format
function TimeToLocalString(eTime as Integer, format="12h" as String) as String
    if(eTime < 0) return ""

    return TimeToString(getDateTimeFromSeconds(eTime), format)
end function

' converts a time from dateTime object, either 24 or 12h format
function TimeToString(dtObject as Object, format="12h" as String) as String
    if(dtObject = invalid) return ""

    hours = dtObject.getHours()
    minutes = PrefixZeroToString(dtObject.getMinutes())
    suffix = "am"
    tts = ""
    
    if (format = "24h")
        tts = hours.toStr() + ":" + minutes

    else

        if (hours = 0)
            hours = 12

        else if (hours >= 12)
            suffix = "pm"
            hours = hours - 12

            if (hours = 0)
                hours = 12
            end if
        end if

        tts = hours.toStr() + ":" + minutes + suffix
    end if

    return tts
end function

function MonthNumberToString(month as Integer) as String
    if (month = 1)
        return "January"
    else if (month = 2)
        return "February"
    else if (month = 3)
        return "March"
    else if (month = 4)
        return "April"
    else if (month = 5)
        return "May"
    else if (month = 6)
        return "June"
    else if (month = 7)
        return "July"
    else if (month = 8)
        return "August"
    else if (month = 9)
        return "September"
    else if (month = 10)
        return "October"
    else if (month = 11)
        return "November"
    else
        return "December"
    end if  
end function

function parseSecondsToHumanReadable (seconds)
    readable = ""

    minutes = MathRound(seconds / 60)
    hours = MathRound(minutes / 60)

    if (hours > 0)
        readable = StringFromInt(hours) + "h"
    end if

    minutes = minutes MOD 60
    if (minutes > 0)
        min = StringFromInt(minutes)
        if (hours > 0)
            readable = readable + " " + min + "m"
        else
            readable = readable + min + " mins"
        end if
    end if
    
    return readable
end function

function formatTime(time=0 as Integer) as String
    timeString = ""

    if(time > 0)
        ' calculate hours
        hours = Int(time / 3600) ' 3600 s in an hour
                    
        ' calculate minutes
        minutes = Int((time - (hours*3600))/60)
        minutesStr =  minutes.toStr()
        if(minutes < 10) minutesStr = "0" + minutesStr
        
        ' remaining seconds
        seconds = Int(time - (hours*3600) - (minutes*60))
        secondsStr = seconds.toStr()
        if(seconds < 10) secondsStr = "0" + secondsStr
        
        if(hours >= 1)
            timeString = hours.toStr() + ":" + minutesStr + ":" + secondsStr
        else
            timeString = minutesStr + ":" + secondsStr
        end if
        
    end if

    return timeString
end function

' Function to return an ISO80601 date as seconds,
'   including applying timezone offset from current UTC
' Return values:
'   => an integer representing the date as seconds since UNIX epoch
function getDateTimeSecondsFromISOWithTZ(dateWithTz="" as String) as Integer
    if (dateWithTz = "") return ""
    ' Brightscript fromISO8601String doesn't understand date time formats
    '   with the timezone so we need to remove it from the date string
    ' Adityionally, we'll do the timezone adjustment here as well

    seconds = 0
    
    r = CreateObject("roRegex", "(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+)([+-][0-2]\d:[0-5]\d|Z)", "")
    s = r.Match(dateWithTz)

    if(s[1] <> invalid)
        tempDate = CreateObject("roDateTime")
        tempDate.fromISO8601String(s[1])
        seconds = tempDate.AsSeconds()

        if(s[2] <> invalid AND s[2] <> "Z")
            t = CreateObject("roRegex", "([+-])([0-2]\d):([0-5]\d)", "")
            u = t.Match(s[2])

            if(u[1] <> invalid AND u[2] <> invalid AND u[3] <> invalid)
                offset = u[2].toInt()*3600 + u[3].toInt()*60

                if(u[1] = "-")
                    seconds = seconds + offset
                else
                    seconds = seconds - offset
                end if
            end if
        end if
    end if

    return seconds
end function