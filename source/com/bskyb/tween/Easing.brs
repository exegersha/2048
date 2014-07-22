'' Easing.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function Linear (begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic) as Dynamic
    return change*frame/duration + begin
end function

function EaseInQuad(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    normalT = frame/duration
    return change*normalT*normalT + begin
end function

function EaseOutQuad(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    normalT = frame/duration
    return -change*normalT*(normalT-2) + begin
end function

function EaseInOutQuad(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    normalTOver2 = frame/(duration/2)
    if(normalTOver2 < 1) return (change/2)*normalTOver2*normalTOver2 + begin
    normalTOver2 = normalTOver2 - 1
    return -change/2 * (normalTOver2 * (normalTOver2-2) - 1) + begin
end function

function EaseInCubic(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    normalT = frame/duration
    return change * MathPow(normalT, 3) + begin
end function

function EaseOutCubic(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    normalT = frame/duration - 1
    return change * ((normalT*normalT*normalT) + 1) + begin
end function

function EaseInOutCubic(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    normalTOver2 = frame/(duration/2)
    if(normalTOver2 < 1) return (change/2) * (normalTOver2*normalTOver2*normalTOver2) + begin
    normalTOver2 = normalTOver2 - 2
    return (change/2) * ( (normalTOver2*normalTOver2*normalTOver2) + 2) + begin'(MathPow(normalTOver2, 3) + 2) + begin
end function

function EaseOutExpo(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    if(frame = duration) return begin + change
    normalT = frame/duration
    exponent = normalT * -10
    return change * (-(2^exponent)+1) + begin 
end function

'this.easeInExpo = funxtion(tP as Object)
'    if(frame = 0) return begin
'    return change * MathPow(2, 10*(frame/duration - 1)) + begin
'end funxtion
   
    'this.easeInBounce = funxtion(tP as Object)
'end funxtion

function EaseOutBounce(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    normalT = frame/duration
    if(normalT < 1/2.75)
        return change*(7.5625*normalT*normalT) + begin
    else if(normalT < 2/2.75)
        normalT = normalT-(1.5/2.75)
        return change*(7.5625*normalT*normalT + 0.75) + begin
    else if(normalT < 2.5/2.75)
        normalT = normalT-(2.25/2.75)
        return change*(7.5625*normalT*normalT + 0.9375) + begin
    else
        normalT = normalT-(2.625/2.75)
        return change*(7.5625*normalT*normalT + 0.984375) + begin
    end if
end function

function EaseNone(begin as Dynamic, change as Dynamic, frame as Dynamic, duration as Dynamic)
    return invalid
end function