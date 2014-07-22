'' DeviceUtils.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function DeviceInit()
    if(m.deviceInfo = invalid) m.deviceInfo = createObject("roDeviceInfo")
end function

function DeviceIsHD() as Boolean
    DeviceInit()
    if(m.deviceInfo.GetDisplayType() = "HDTV") return true
    return false
end function

function DeviceIP() as String
    ipAddresses = m.deviceInfo.GetIPAddrs()
    for each key in ipAddresses
        ipAddress = ipAddresses[key]
        if (ipAddress <> invalid) and (ipAddress.Len() > 0)
            return ipAddress
        end if
    end for
    return ""
end function

' Returns unique device serial number
function DeviceGetUniqueID() as String
    DeviceInit()
    return m.deviceInfo.GetDeviceUniqueId()
end function

' Returns roku firmware version (e.g. 5.0 build 2322)
function DeviceGetFirmwareVersion() as String
    DeviceInit()
    return m.deviceInfo.GetVersion()
end function

' Returns roku model (e.g. 3100X)
function DeviceGetModel() as String
    DeviceInit()
    return m.deviceInfo.GetModel()
end function

function DeviceGetDisplayMode() as String
    DeviceInit()
    return m.deviceInfo.GetDisplayMode()
end function

' Returns a value from the registry
function RegRead(key as String, section="Default" as String) as Dynamic
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    return invalid
end function

' Writes a value to the registry
function RegWrite(key as String, val as String, section="Default" as String)
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
end function

' Deletes a value from the registry
function RegDelete(key as String, section="Default" as String)
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
end function

' Retrieve the list of keys saved in the registry under the specified section
function RegKeyList(section="Default" as String) as Object
    sec = CreateObject("roRegistrySection", section)
    return sec.GetKeyList()
end function

' Check if key exists in registry under the specified section
function RegKeyExists(key as String, section="Default" as String) as Boolean
    sec = CreateObject("roRegistrySection", section)
    return sec.Exists(key)
end function