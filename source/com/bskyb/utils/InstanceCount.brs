'' InstanceCount.brs


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