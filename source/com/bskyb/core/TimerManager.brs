'' TimeManager.brs


function TimerManager() as Object
    
    if(m.timerManagerInstance = invalid)
        
        this = EventDispatcher()
        
        ' PROPERTIES
        this.timers = []
        
        ' METHODS        
        this.add = function(timerObj as Object)
            m.timers.push(timerObj)
        end function
        
        this.remove = function(timerObj as Object) as Boolean
            index = 0
            for each t in m.timers
                if(t.id = timerObj.id)
                    m.timers.delete(index)
                    return true
                end if
                index = index + 1
            end for
            return false
        end function
        
        this.update = function()
            for each t in m.timers
                t.update()
            end for            
        end function
        
        m.timerManagerInstance = this
    
    end if
    
    return m.timerManagerInstance
    
end function