'' LaunchParameters.brs


function LaunchParameters(params=invalid as Object) as Object
    
    if (m.launchParameters = invalid)
        m.launchParameters = params
    end if
    
    return m.launchParameters
    
end function