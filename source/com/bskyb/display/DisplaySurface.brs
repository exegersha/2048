'' DisplaySurface.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function DisplaySurface(id="" as String) as Object
    
    'print "new DisplaySurface"
    this = DisplayObject(id)
    
    ' STATIC PROPERTIES
    this.TOSTRING = "<DisplaySurface>"
    this.MAX_VALUE = 2048
    
    ' PROPERTIES
    this.surface = invalid
    this.rotateTheta = 0
    
    ' "PRIVATE" METHODS
    
    ' METHODS
    this.noScaleRender = function()
        if(m.surface <> invalid AND m.screen <> invalid AND m.visible)
            m.screen.drawObject(m.globalX, m.globalY, m.surface)
        end if
    end function
    
    this.scaleRender = function()
        if(m.surface <> invalid AND m.screen <> invalid AND m.visible)
            m.screen.drawScaledObject(m.globalX, m.globalY, m.scaleX, m.scaleY, m.surface)
        end if
    end function
    
    this.rotateRender = function()
        if(m.surface <> invalid AND m.screen <> invalid AND m.visible)
            m.screen.drawRotatedObject(m.globalX, m.globalY, m.rotateTheta, m.surface)
        end if
    end function

    ' METHODS    
    this.init = function(width as Integer, height as Integer, alphaEnable = false as Boolean)
        if (width > m.MAX_VALUE) width = m.MAX_VALUE
        if (height > m.MAX_VALUE) height = m.MAX_VALUE
        m.width = width
        m.height = height
        if (m.surface <> invalid)
            m.surface = invalid
        end if
        'm.surface = createObject("roBitmap",{width:width, height:height, AlphaEnable: alphaEnable})
        bmp = createObject("roBitmap",{width:width, height:height, AlphaEnable: alphaEnable})
        
        m.surface = createObject("roRegion",bmp, 0, 0, width, height)
        m.surface.setScaleMode(1) ' smooth scaling
        m.surface.setAlphaEnable(alphaEnable)
    end function
    
    this.dispose = function()
        m.surface = invalid
    end function
    
    this.clear = function(colour=&h00000000 as Integer)
        if (m.surface <> invalid) m.surface.clear(colour)
    end function
    
    this.drawTo = function(displayObj as Object)
        prevScreen = displayObj.screen
        displayObj.setScreen(m.surface)
        displayObj.render()
        displayObj.setScreen(prevScreen) ' set objects screen back to previous
    end function
        
    this.setScale = function(scaleX as Float, scaleY as Float)
        m.scaleX = scaleX
        m.scaleY = scaleY
        
        if(m.scaleX = 1 AND m.scaleY = 1) 
            m.render = m.noScaleRender
        else
            m.render = m.scaleRender
        end if
    end function
    
    this.setRotate = function(theta as float) ' Works for 0, 90, 180 and 270
        m.rotateTheta = theta
        
        if (m.rotateTheta = 0)
            m.render = m.noScaleRender
        else
            m.render = m.rotateRender
        end if
    end function
        
    ' CONSTRUCTOR HERE
    this.render = this.noScaleRender
    
    
    return this
    
end function