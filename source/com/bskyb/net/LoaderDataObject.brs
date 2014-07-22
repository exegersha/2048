'' LoaderDataObjects.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function LoaderDataObject( refUrl as String, response as String, httpStatusCode as Integer, responseHeaders=invalid as Object ) as Object
    
    this = {}
    
    ' STATIC PROPERTIES
    this.TOSTRING = "<LoaderDataObject>"
    
    ' PROPERTIES
    this.refUrl = refUrl
    this.response = response
    this.httpStatusCode = httpStatusCode
    this.responseHeaders = responseHeaders
    
    return this
    
end function