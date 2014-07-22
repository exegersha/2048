'' URLRequest.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function URLRequest(url="" as String) as Object
    
    'print "new URLRequest"
    this = {}
    
    ' PROPERTIES
    this.url = url
    this.method = "GET"
    this.requestHeaders = {}
    this.data = ""
    this.secure = false
    this.timeout = 20000 ' 20 Seconds
    
    ' METHODS
    this.addRequestHeader = function( name as String, value as String )
       m.requestHeaders.AddReplace(name, value)   
    end function
    
    return this
    
end function