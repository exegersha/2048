'' LaunchParameters.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function LaunchParameters(params=invalid as Object) as Object
    
    if (m.launchParameters = invalid)
        m.launchParameters = params
    end if
    
    return m.launchParameters
    
end function