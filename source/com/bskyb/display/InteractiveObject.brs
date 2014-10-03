'' InteractiveObject.brs


function InteractiveObject(id="" as String) as Object
    
    'print "new InteractiveObject"
    this = DisplayObject(id)
    
    ' STATIC PROPERTIES
    this.TOSTRING = "<InteractiveObject>"
    
    ' METHODS    
    this.onFocusIn = function(eventObj as Object)
    end function
    
    this.onFocusOut = function(eventObj as Object)
    end function  
    
    this.onKeyDown = function(keyCode as Integer)
        if(keyCode = 0) 'BUTTON_BACK_PRESSED
            m.onBackPressed()     
        else if(keyCode = 2) 'BUTTON_UP_PRESSED 
            m.onUpPressed()               
        else if(keyCode = 3) 'BUTTON_DOWN_PRESSED
            m.onDownPressed()          
        else if(keyCode = 4) 'BUTTON_LEFT_PRESSED 
            m.onLeftPressed()          
        else if(keyCode = 5) 'BUTTON_RIGHT_PRESSED
            m.onRightPressed()        
        else if(keyCode = 6) 'BUTTON_SELECT_PRESSED
            m.onSelectPressed()        
        else if(keyCode = 7) 'BUTTON_INSTANT_REPLAY_PRESSED
            m.onInstantReplayPressed()
        else if(keyCode = 8) 'BUTTON_REWIND_PRESSED
            m.onRewindPressed()        
        else if(keyCode = 9) 'BUTTON_FAST_FORWARD_PRESSED
            m.onFastForwardPressed()  
        else if(keyCode = 10) 'BUTTON_INFO_PRESSED
            m.onInfoPressed()         
        else if(keyCode = 13) 'BUTTON_PLAY_PRESSED
            m.onPlayPressed()          
        else if(keyCode = 15) 'BUTTON_ENTER_PRESSED
            m.onEnterPressed()         
        else if(keyCode = 17) 'BUTTON_A_PRESSED
            m.onAPressed()             
        else if(keyCode = 18) 'BUTTON_B_PRESSED
            m.onBPressed()             
        else if(keyCode = 22) 'BUTTON_PLAY_ONLY_PRESSED
            m.onPlayOnlyPressed()     
        else if(keyCode = 23) 'BUTTON_STOP_PRESSED
            m.onStopPressed()
        end if          
    end function
    
    this.onKeyUp = function(keyCode as Integer)
        if(keyCode = 100) 'BUTTON_BACK_RELEASED
            m.onBackReleased()     
        else if(keyCode = 102) 'BUTTON_UP_RELEASED
            m.onUpReleased()               
        else if(keyCode = 103) 'BUTTON_DOWN_RELEASED
            m.onDownReleased()          
        else if(keyCode = 104) 'BUTTON_LEFT_RELEASED
            m.onLeftReleased()          
        else if(keyCode = 105) 'BUTTON_RIGHT_RELEASED
            m.onRightReleased()        
        else if(keyCode = 106) 'BUTTON_SELECT_RELEASED
            m.onSelectReleased()        
        else if(keyCode = 107) 'BUTTON_INSTANT_REPLAY_RELEASED
            m.onInstantReplayReleased()
        else if(keyCode = 108) 'BUTTON_REWIND_RELEASED
            m.onRewindReleased()        
        else if(keyCode = 109) 'BUTTON_FAST_FORWARD_RELEASED
            m.onFastForwardReleased()  
        else if(keyCode = 110) 'BUTTON_INFO_RELEASED
            m.onInfoReleased()         
        else if(keyCode = 113) 'BUTTON_PLAY_RELEASED
            m.onPlayReleased()          
        else if(keyCode = 115) 'BUTTON_ENTER_RELEASED
            m.onEnterReleased()         
        else if(keyCode = 117) 'BUTTON_A_RELEASED
            m.onAReleased()             
        else if(keyCode = 118) 'BUTTON_B_RELEASED
            m.onBReleased()             
        else if(keyCode = 122) 'BUTTON_PLAY_ONLY_RELEASED
            m.onPlayOnlyReleased()     
        else if(keyCode = 123) 'BUTTON_STOP_RELEASED
            m.onStopReleased()
        end if
    end function
    
    ' PRESSED
    this.onBackPressed = function()
    end function
    
    this.onUpPressed = function()
    end function
    
    this.onDownPressed = function()
    end function
    
    this.onLeftPressed = function()
    end function
    
    this.onRightPressed = function()
    end function
    
    this.onSelectPressed = function()
    end function
    
    this.onInstantReplayPressed = function()
    end function
    
    this.onRewindPressed = function()
    end function
    
    this.onFastForwardPressed = function()
    end function
    
    this.onInfoPressed = function()
    end function
    
    this.onPlayPressed = function()
    end function
    
    this.onEnterPressed = function()
    end function
    
    this.onAPressed = function()
    end function
    
    this.onBPressed = function()
    end function
    
    this.onPlayOnlyPressed = function()
    end function
    
    this.onStopPressed = function()
    end function
    
    ' RELEASED
    this.onBackReleased = function()
    end function
    
    this.onUpReleased = function()
    end function
    
    this.onDownReleased = function()
    end function
    
    this.onLeftReleased = function()
    end function
    
    this.onRightReleased = function()
    end function
    
    this.onSelectReleased = function()
    end function
    
    this.onInstantReplayReleased = function()
    end function
    
    this.onRewindReleased = function()
    end function
    
    this.onFastForwardReleased = function()
    end function
    
    this.onInfoReleased = function()
    end function
    
    this.onPlayReleased = function()
    end function
    
    this.onEnterReleased = function()
    end function
    
    this.onAReleased = function()
    end function
    
    this.onBReleased = function()
    end function
    
    this.onPlayOnlyReleased = function()
    end function
    
    this.onStopReleased = function()
    end function
        
    return this
    
end function