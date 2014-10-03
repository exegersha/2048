'' TweenManager.brs


function TweenManager() as Object
    
    if(m.tweenInstance = invalid)
        
        this = {}
        
        ' STATIC PROPERTIES
        this.TOSTRING = "<TweenManager>"
    
        ' PROPERTIES
        this.activeTweens = {}
        this.activeDelays = {}
        
        ' METHODS
        this.update = function()            
            m.updateTweens()
            m.updateDelays()            
        end function
        
        this.updateTweens = function()
            
            for each inst in m.activeTweens
                
                tween = m.activeTweens[inst]
                xPos = tween.target.x
                yPos = tween.target.y
                scaleX = tween.target.scaleX
                scaleY = tween.target.scaleY
                
                for each name in tween.props
                    
                    obj = tween.props[name]
                    currFrame = tween.currFrame
                    value = tween.ease(obj.begin, obj.change, currFrame, tween.totalFrames)
                                        
                    if(value <> invalid)'Special case for x, y, scaleX and scaleY
                        if(name = "x")
                            xPos = value
                            
                        else if(name = "y")
                            yPos = value
                            
                        else if(name = "scalex")
                            scaleX = value
                            
                        else if(name = "scaley")
                            scaleY = value
                            
                        else
                            tween.target[name] = value
                        end if
                    end if
                    
                    if(tween.offsets <> invalid) 
                        offSets = tween.offsets[currFrame]
                        if(offSets <> invalid)
                            xPos = xPos + offSets.x
                            yPos = yPos + offSets.y
                        end if
                    end if
                    
                    ' Perform X/Y
                    if (xPos <> tween.target.x or yPos <> tween.target.y)
                        tween.target.setXY(xPos, yPos)                    
                    end if
                    
                    ' Perform scaleX/scaleY
                    if (scaleX <> tween.target.scaleX or scaleY <> tween.target.scaleY)
                        tween.target.setScale(scaleX, scaleY)                        
                    end if
                    
                end for
                
                ' Tween is complete, remove it
                if (tween.currFrame = tween.totalFrames)
                    if (tween.onComplete <> invalid) tween.onComplete.destination[tween.onComplete.callback]()
                    m.activeTweens.delete(inst)
                else
                    tween.currFrame = tween.currFrame + 1
                    if (tween.onProgress <> invalid) tween.onProgress.destination[tween.onProgress.callback]()
                end if
                
            end for
            
        end function
        
        this.updateDelays = function()            
            for each inst in m.activeDelays                
                call = m.activeDelays[inst]
                ' Delay is complete, remove it
                if (call.currFrame = call.totalFrames AND call.target <> invalid)
                    m.activeDelays.delete(inst)
                    if (call.params <> invalid)
                        call.target[call.callback](call.params)
                    else
                        call.target[call.callback]()
                    end if 
                else
                    call.currFrame = call.currFrame + 1
                end if
            end for            
        end function
        
        ' PUBLIC METHODS        
        this.to = function(target as Object, frames as Integer, args={} as Object, offsets=invalid as Object)            
            tween = {target:target, currFrame:0, totalFrames:frames, props:{}, ease:Linear, offsets:offsets}            
            for each prop in args
                if (type(target[prop]) = "roInteger") or (type(target[prop]) = "roFloat")
                    tween.props[prop] = {begin:target[prop], change:args[prop]-target[prop]}
                else
                    tween[prop] = args[prop]
                end if                
            end for            
            m.activeTweens[target.id] = tween            
        end function
        
        this.killTweensOf = function(obj as Object) as Boolean
            if(m.activeTweens[obj.id] <> invalid)
                m.activeTweens.delete(obj.id)
                return true
            end if
            return false
        end function
        
        this.killAllTweens = function() as Boolean
            for each inst in m.activeTweens
                m.activeTweens.delete(inst)
            end for
            return true
        end function
        
        this.delayedCall = function(destination as Object, frames as Integer, callback as String, params=invalid as Object)
            id = destination.id + callback
            call = {target:destination, currFrame:0, totalFrames:frames, callback:callback, params:params}
            m.activeDelays[id] = call
        end function
        
        this.killDelayedCallTo = function(destination as Object, callback as String) as Boolean
            id = destination.id + callback
            if(m.activeDelays[id] <> invalid)
                m.activeDelays.delete(id)
                return true
            end if
            return false
        end function
        
        m.tweenInstance = this
        
    end if
    
    return m.tweenInstance
    
end function