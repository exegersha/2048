'' InstanceCount.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

' Singleton instance of InstanceCount
function InstanceCount() as Object
    
    if(m.instanceCounter = invalid)
        
        'print "new InstanceCount"
        this = {}
        
        ' STATIC PROPERTIES
        this.TOSTRING = "<InstanceCount>"
        
        ' PROPERTIES
        this.count = 0
        
        ' METHODS
        this.getNext = function() as Integer            
            m.count = m.count + 1
            return m.count            
        end function
        
        m.instanceCounter = this
        
    end if
    
    return m.instanceCounter
    
end function