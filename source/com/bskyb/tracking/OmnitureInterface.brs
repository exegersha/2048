'' OmnitureInterface.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function OmnitureInterface(baseUrl as String) as Object
    
    if (m.omnitureInterface = invalid)
        
        this = {}
        
        ' STATIC PROPERTIES
        this.TOSTRING = "<OmnitureInterface>"
        
        ' PROPERTIES
        this.baseUrl = baseUrl
        
        ' PARAMS
        this.account = invalid
        this.referrer = invalid
        this.visitorId = invalid
        
        ' Omniture is case sensative so we replace lowercase strings from BrightScript to the correct string
        this.caseMap = {
            pagename: "pageName"
            pageurl: "pageURL"
            scxmlver: "scXmlVer"
            useragent: "userAgent"
        }
        
        ' These are added to every request
        this.persistentParams = {
            resolution: "1280x720"
            scxmlver: "1.0"
            useragent: "1.0"
        }
        
        ' METHODS
        this.track = function(params as Object)
            ' Create request            
            request = URLRequest()
            request.addRequestHeader("Content-Type", "application/x-www-form-urlencoded")
            request.url = m.baseUrl + "/" + m.account + "/6"
            request.method = "POST"
            
            ' Create XML dtata
            xml = "<?xml version=" + Chr(34) + "1.0" + Chr(34) + " encoding=" + Chr(34) + "UTF-8" + Chr(34) + "?><request>"
            xml = xml + "<ipAddress>" + DeviceIP() + "</ipAddress>"
            xml = xml + "<reportSuiteID>" + m.account + "</reportSuiteID>"
            'xml = xml + "<timestamp>16/0/2013 14:35:50 3 0</timestamp>"
            xml = xml + "<visitorID>" + m.visitorId + "</visitorID>"
            
            ' Add persistant properties to query string
            for each p in m.persistentParams
                ' Case sensitive URL, need to swap
                if (m.caseMap.doesExist(p)) p = m.caseMap.lookup(p)
                ' If value is blank, ignore it
                if not (m.persistentParams.lookup(p) = "") xml = xml + "<" + p + ">" + m.persistentParams.lookup(p) + "</" + p + ">"
            end for
            
            ' Add properties to query string
            for each p in params
                ' Case sensitive URL, need to swap
                if (m.caseMap.doesExist(p)) p = m.caseMap.lookup(p)
                ' If value is blank, ignore it
                if not (params.lookup(p) = "") xml = xml + "<" + p + ">" + params.lookup(p) + "</" + p + ">"
            end for
            
            xml = xml + "</request>"
            
            ' Replace any "evar" values to "eVar"
            xml = StringReplace(xml, "evar", "eVar")
            
            ' Add XML data to request object
            request.data = xml
            
            'print request.data
            
            ' Send request BigFatPipe
            BigFatPipe().load(request, m, "onTrackSuccess", "onTrackFailed")                        
        end function
        
        this.onTrackSuccess = function(dataObj as Object) as Void
            print m.TOSTRING; " onTrackSuccess"
            'print dataObj
        end function
        
        this.onTrackFailed = function(dataObj as Object) as Void
            ' Ignore this, can't really do anything about it
            print m.TOSTRING; " onTrackFailed"
            'print dataObj
        end function
        
        m.omnitureInterface = this
        
    end if
    
    return m.omnitureInterface
    
end function