'' MathUtils.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function MathCeil(v as Float) as Integer
    if (int(v) = v) return v
    return int(v) + 1
end function

function MathFloor(v as Float) as Integer
    return int(v)
end function

function MathRound(v as Float) as Integer
    if((v - int(v)) > 0.5)
        return int(v) + 1
    else
        return int(v)
    end if
end function

function Max(a=0 as dynamic, b=0 as dynamic) as Dynamic
    res = a
    if(b > a) res = b
    return res
end function
