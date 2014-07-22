'' GeneralUtils.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function BoolToStr(bool as Boolean) as String
    if(bool = true)
        return "true"
    else if (bool = false)
        return "false"
    end if
    return invalid
end function

' returns manifest entries as an associative array
function GetManifestItems() as Object
   result = {}

      raw = ReadASCIIFile("pkg:/manifest")
      lines = raw.Tokenize(Chr(10))
      for each line in lines
        bits = line.Tokenize("=")
        if bits.Count() > 1
          result.AddReplace(bits[0].trim(), bits[1].trim())
        end if
      next

  return result
end function

' Builds the version number from version found in manifest
function GetAppVersion() as Object

    if (m.AppVersion = invalid)
        manifest = GetManifestItems()

        appVersion = {
            VERSION_NUMBER: {
                SHORT: "",
                MEDIUM: "",
                EXTENDED: ""
            },

            RELEASE_BUILD: false
        }

        major = manifest.major_version.toInt().toStr()
        minor = manifest.minor_version.toInt().toStr()

        build_version = manifest.build_version.toInt().toStr()
        build_time = manifest.time_version

        if (manifest.release <> invalid)
            release = manifest.release.toInt()
        else
            release = invalid
        end if

        if (major = invalid)
            major = "0"
        end if

        if (minor <> invalid)
            minor = "." + minor
        else
            minor = ""
        end if

        if (build_version <> invalid)
            build_version = "."+build_version
        else
            build_version = ""
        end if

        if (build_time <> invalid)
            build_time = "."+build_time
        else
            build_time = ""
        end if

        if (release = invalid OR release = 0)
            releaseBuild = false
        else
            releaseBuild = true
        end if

        appVersion.VERSION_NUMBER.SHORT     = major + minor
        appVersion.VERSION_NUMBER.MEDIUM    = major + minor + build_version
        appVersion.VERSION_NUMBER.EXTENDED  = major + minor + build_version + build_time
        appVersion.RELEASE_BUILD = releaseBuild
        m.appVersion = appVersion
    end if

    return m.AppVersion
end function

' Merges and overrides the 'overrides' object into source
function MergeObjects(source={} as Object, overrides={} as Object) as Object
    merged = {}

    for each property in source
        merged.AddReplace(property, source[property])
    end for

    for each property in overrides
        prop = overrides[property]

        if (type(prop) = "roAssociativeArray") AND (merged.DoesExist(property))
            prop = MergeObjects(merged[property], prop)
        end if

        merged.AddReplace(property, prop)
    end for

    return merged
end function

' Creates a full clone of the source object
function Clone(source={} as Object) as Object
    return MergeObjects(source, {})
end function

' Returns the keys of an associative array
function GetKeys(source={} as Object) as Object
    keys = []

    for each key in source
        keys.push(key)
    end for

    return keys
end function

' Serializes data in a json object
function toJSON(it, TTL=40)
    if (TTL > 0)
        typ = type(it)

        if (typ = "String" or typ = "roString")
            'escape " and \. NB: cannot deal with \ *after* others are escaped
            res = createObject("roRegex", "([\x22\\])", "").replaceAll(it, "\\\1")

            'control chars; likely no need but rfc4627 calls for it
            re = createObject("roRegEx", "[\x00-\x1f]", "")
            bArr = invalid

            while (true)
                ch = re.match(res)[0]
                if (ch = invalid)
                    exit while
                end if

                if (ch = chr(10))
                    toRE = "\\n"
                elseif (ch = chr(13))
                    toRE = "\\r"
                else
                    if bArr = invalid then bArr = createObject("roByteArray")
                    bArr.fromAsciiString(ch)
                    toRE = "\\u00" + bArr.toHexString()
                end if

                res = createObject("roRegEx", ch, "").replaceAll(res, toRE)
            end while

            return chr(34) + res + chr(34)

        elseif (typ = "roArray" or typ = "roList")
            res = ""

            for each item in it
                res = res + toJSON(item, TTL-1) + ","
            end for

            'drop the last comma
            return "[" + left(res, len(res)-1) + "]"

        elseif (typ = "roAssociativeArray")
            res = ""

            for each key in it
                res = res + toJSON(key, 1) + ":" + toJSON(it[key], TTL-1) + ","
            end for

            'drop the last comma
            return "{" + left(res, len(res)-1) + "}"

        elseif (typ = "Integer" or typ = "roInt" or typ = "roInteger")
            'yes, Virginia, there is roInteger: ?type([0][0])
            return it.toStr()

        elseif (typ = "Float" or typ = "Double" or typ = "roFloat" or typ = "roDouble")
            'str() is our first, last and only hope
            return str(it).trim()

        elseif (typ = "Boolean" or typ = "roBoolean")
            if (it)
                return "true"
            else
                return "false"
            end if

        elseif (typ = "Invalid" or typ = "roInvalid")
            return "null"

        else
            ' "Function", "<uninitialized>", "if"-interfaces, other "ro"-objects
            print "toJSON: unsupported type"; type(it), it
            STOP
        end if

    else 'TTL<=0, time-to-live counter expired
        print "toJSON: too many nested structures (likely a cycle)"; it
        STOP
    end if

end function
