'' InteractiveDisplayObjectContainer.brs


function InteractiveDisplayObjectContainer(girdSize=5 as Integer, id="" as String) as Object
    
    'print "new InteractiveObjectContainer: " + id
    this = DisplayObjectContainer(id)
    
    ' STATIC PROPERTIES
    this.TOSTRING = "<InteractiveDisplayObjectContainer>"
        
    ' PROPERTIES
    this.girdSize = girdSize
    this.interactiveChildren = invalid
    this.focusedInteractiveChild = invalid
    this.focusedGridX = 0
    this.focusedGridY = 0
    
    ' METHODS    
    this.onUpPressed = function()
        if NOT(m.changeActive(0, -1))
            ' Nowhere else to go.
            m.onMovedOffUp()
        end if   
    end function
    
    this.onDownPressed = function()
        if NOT(m.changeActive(0, 1))
            ' Nowhere else to go.
            m.onMovedOffDown()
        end if
    end function
    
    this.onLeftPressed = function()
        if NOT(m.changeActive(-1, 0))
            ' Nowhere else to go.
            m.onMovedOffLeft()
        end if
    end function
    
    this.onRightPressed = function()
        if NOT(m.changeActive(1, 0))
            ' Nowhere else to go.
            m.onMovedOffRight()
        end if
    end function
    
    this.changeActive = function(x as Integer, y as Integer) as Boolean
        newFocusedGridX = m.focusedGridX + x
        newFocusedGridY = m.focusedGridY + y
        
        if (newFocusedGridX >= 0) AND (newFocusedGridX < m.girdSize) AND (newFocusedGridY >= 0) AND (newFocusedGridY < m.girdSize)
            ' If the new grid position is invalid try and find the nearest valid one.
            if (m.interactiveChildren[newFocusedGridX][newFocusedGridY] = invalid)
                checkCount = m.girdSize/2 + 1
                alternativeX1 = newFocusedGridX
                alternativeY1 = newFocusedGridY
                alternativeX2 = newFocusedGridX
                alternativeY2 = newFocusedGridY
                
                while (m.interactiveChildren[alternativeX1][alternativeY1] = invalid) AND (m.interactiveChildren[alternativeX2][alternativeY2] = invalid) AND (checkCount >= 0)
                    if (y <> 0)
                        alternativeX1 = alternativeX1 - 1
                        alternativeX2 = alternativeX2 + 1
                    end if
                    
                    if (x <> 0)
                        alternativeY1 = alternativeY1 - 1
                        alternativeY2 = alternativeY2 + 1
                    end if
                    
                    if (alternativeX1 < 0)
                        alternativeX1 = 0
                    end if
                    
                    if (alternativeX2 > m.girdSize)
                        alternativeX2 = m.girdSize - 1
                    end if
                    
                    if (alternativeY1 < 0)
                        alternativeY1 = 0
                    end if
                    
                    if (alternativeY2 > m.girdSize)
                        newFocusedGridY = m.girdSize - 1
                    end if
                    
                    checkCount = checkCount - 1                    
                end while
                
                if (m.interactiveChildren[alternativeX1][alternativeY1] <> invalid)
                    newFocusedGridX = alternativeX1
                    newFocusedGridY = alternativeY1
                else
                    if (m.interactiveChildren[alternativeX2][alternativeY2] <> invalid)
                        newFocusedGridX = alternativeX2
                        newFocusedGridY = alternativeY2
                    end if
                end if                    
            end if
            
            if (m.interactiveChildren[newFocusedGridX][newFocusedGridY] <> invalid)
                ' Valid object to select at the new position.
                m.focusedInteractiveChild.setActive(false)
                m.focusedGridX = newFocusedGridX
                m.focusedGridY = newFocusedGridY
                m.focusedInteractiveChild = m.interactiveChildren[m.focusedGridX][m.focusedGridY]
                m.focusedInteractiveChild.setActive(true)
                
                return true
            end if
        end if
        
        return false
    end function
    
    this.onFocusIn = function(eventObj as Object)
        'print m.TOSTRING; " setFocus: "; focusObj.TOSTRING; " ("; focusObj.id; ")"
        m.initialiseFirstInteractiveChild()
        
        if (m.focusedInteractiveChild <> invalid)
            m.focusedInteractiveChild.setActive(true)
        end if
    end function
    
    this.onFocusOut = function(evntObj as Object)
        if (m.focusedInteractiveChild <> invalid)
            m.focusedInteractiveChild.setActive(false)
        end if
    end function 
    
    this.addInteractiveChild = function(child as Object, xGridPosition as Integer, yGridPosition as Integer)
        m.addChild(child)
        m.interactiveChildren[xGridPosition][yGridPosition] = child
    end function
    
    this.removeInteractiveChild = function(child as Object, xGridPosition as Integer, yGridPosition as Integer)
        m.removeChild(child)
        m.interactiveChildren[xGridPosition][yGridPosition] = invalid
    end function
    
    this.initialiseFirstInteractiveChild = function() as void
        for y=m.girdSize to 0 step -1
            for x=0 to m.girdSize step +1            
                if (m.interactiveChildren[x][y] <> invalid)
                    m.focusedGridX = x
                    m.focusedGridY = y
                    
                    m.focusedInteractiveChild = m.interactiveChildren[x][y]
                    
                    return
                end if
            end for
        end for
    end function
    
    ' Overide in derived class to perform custom operations.
    this.onMovedOffUp = function() as Object
    end function
    
    this.onMovedOffDown = function() as Object
    end function
    
    this.onMovedOffLeft = function() as Object
    end function
    
    this.onMovedOffRight = function() as Object
    end function
    
    ' CONSTRUCTOR CODE
    Dim newInteractiveChildren[girdSize, girdSize]
    this.interactiveChildren = newInteractiveChildren
    
    for x=0 to this.girdSize
        for y=0 to this.girdSize
            this.interactiveChildren[x][y] = invalid
        end for
    end for
    
    return this
    
end function