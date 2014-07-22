'' Event.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function Event (properties = {} as Object) as Object

    if (properties.eventType = invalid OR properties.target = invalid)
        print "Error creating event. Event must have both 'eventType' and 'target' specified."
        print "Event.eventType = " + properties.eventType
        print "Event.target = "; properties.target
        stop
    end if

    this = {
        TOSTRING: "<Event>",
        eventType: properties.eventType,
        target: properties.target,
        payload: {}
    }

    for each property in properties
        this.AddReplace(property, properties[property])
    end for

    return this

end function