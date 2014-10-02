'' StringUtils.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function StringReplace(basestr as Dynamic, oldsub as String, newsub as String) as String

    if (basestr = invalid) return ""

    newstr = ""
    i = 1

    while i <= Len(basestr)

        x = Instr(i, basestr, oldsub)

        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        endif

        if x > i then
            newstr = newstr + Mid(basestr, i, x-i)
            i = x
        endif

        newstr = newstr + newsub
        i = i + Len(oldsub)

    end while

    return newstr

end function

' Trucates a string based on max characters
function StringTruncate(baseStr as String, charLimit as Integer, truncateText="" as String, endOnWord=false as Boolean) as String
    total = Len(baseStr)
    index = 0
    lastWordIndex = 0
    returnString = baseStr

    ' Don't bother, it's safe
    if (total <= charLimit) return returnString

    while index < total
        curChar = Mid(baseStr, index, 1)

        ' Save last full word char index
        if (curChar = " ")
            lastWordIndex = index - 1
        end if

        ' Max characters reached
        if (index > charLimit)
            if(endOnWord)
                returnString = Mid(baseStr, 0, lastWordIndex) + truncateText
            else
                returnString = Mid(baseStr, 0, index - 1) + truncateText
            end if
            exit while
        end if

        index = index + 1
    end while

    return returnString
end function

' Truncates a string to specified width
function StringTruncateFromWidth(baseStr as String, font as Object, width as Integer, endOnWord=false as Boolean, truncateText="" as String) as String
    retString = ""
    textWidth = 0
    index = 0
    lastBlankIndex = 0

    ' check if baseStr is already shorter than width, if so just return it
    textWidth = font.GetOneLineWidth(baseStr, 9999)
    truncateTextWidth = font.GetOneLineWidth(truncateText, 9999)

    if(textWidth < width) return baseStr

    while true

        retString = Mid(baseStr, 0, index)
        curLetter = Mid(baseStr, index, 1)

        if(curLetter = " ") or (curLetter = "-")
            lastBlankIndex = index-1
        end if

        textWidth = font.GetOneLineWidth(retString, 9999)

        if(textWidth + truncateTextWidth >= width)
            if(endOnWord)
                retString = Mid(baseStr, 0, lastBlankIndex)
            else
                retString = Mid(baseStr, 0, index-1)
            end if
            exit while
        end if

        index = index + 1
    end while
    return retString + truncateText
end function

' Converts a string into password string eg. *****
function StringToPassword(baseStr as String) as String
    index = 0
    output = ""
    while (index < Len(baseStr))
        output = output + "*"
        index = index + 1
    end while
    return output
end function

' Removes empty white space from the beginning of a string
function StringTrim(baseStr as String) as String
    while Mid(baseStr, 0, 1) = " "
        baseStr = baseStr.Right(Len(baseStr)-1)
    end while
    return baseStr
end function

' Returns true if 'match' can be found inside 'baseStr'
function StringContains(baseStr as String, match as String) as Boolean
    if (not baseStr.instr(match) = -1) return true
    return false
end function

' Returns a base64 encoded string
function StringBase64(baseStr as String) as String
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(baseStr)
    return ba.ToBase64String()
end function

' Returns a boolean as a string
function StringFromBoolean (value as Boolean) as String
    if (value)
        boolStr = "true"
    else
        boolStr = "false"
    end if

    return boolStr
end function

' Converts a number to a string without adding a space at the beginning
function StringFromNumber(value as Dynamic) as String
    output = Str(value)
    return StringTrim(output)
end function

' Converts an integer number to a string without adding a space at the beginning
function StringFromInt(value as Integer) as String
    return StringFromNumber(value)
end function

' Converts a float number to a string without adding a space at the beginning
function StringFromFloat(value as float) as String
    return StringFromNumber(value)
end function

' Removes all HTML tags from a string
function StringRemoveHTMLTags(baseStr as String) as String
    r = createObject("roRegex", "<[^<]+?>", "i")
    return r.replaceAll(baseStr, "")
end function

function StringEscape(baseStr as String) as String
    urlTransfer = CreateObject("roUrlTransfer")
    return urlTransfer.escape(baseStr)
end function

function StringGetFileExtension(baseStr as String) as String
    regEx = createObject("roRegex", "[^\.^\s^\W]+$", "")
    return regEx.match(baseStr)[0]
end function

function StringFirstCharToUpperCase(convertStr as String) as String
    if (convertStr.len() > 1)
        convertedStr = ""
        firstChar = convertStr.left(1)
        restChars = convertStr.mid(1)
        convertedStr = uCase(firstChar) + restChars

        return convertedStr
    else
        return convertStr
    end if
end function

' prefixes single digit numbers with a zero and outputs as string, if > 10 just returns as string -- '@TODO: review this function
function PrefixZeroToString(value as Integer, prefixLength = 1 as Integer) as String

    retVal = value.toStr()

    while(value < 10 * prefixLength)
        retVal = "0" + value.toStr()
        value = value * 10
    end while
    print "***** retVal=";retVal
    return retVal
end function

