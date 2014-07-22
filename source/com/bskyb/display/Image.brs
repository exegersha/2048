'' Image.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

function Image(id="" as String) as Object

    'print "new Image"
    this = DisplayObject(id)

    ' STATIC PROPERTIES
    this.TOSTRING = "<Image>"

    ' PROPERTIES
    this.path = ""
    this.destroyOnDispose = false ' if this is set to true, when we dispose an object it will destroy the image in cache(AssetService) and thus free up videomem
    this.bitmap = invalid
    this.request = invalid
    this.isInternal = false

    ' "PRIVATE" METHODS

    ' METHODS
    this.noScaleRender = function()
        if(m.bitmap <> invalid AND m.visible AND m.screen <> invalid)
            m.screen.drawObject(m.globalX, m.globalY, m.bitmap)
        end if
    end function

    this.scaleRender = function()
        if(m.bitmap <> invalid AND m.visible AND m.screen <> invalid)
            m.screen.drawScaledObject(m.globalX, m.globalY, m.scaleX, m.scaleY, m.bitmap)
        end if
    end function

    ' no scale by default
    this.render = this.noScaleRender

    ' METHODS
    this.load = function(path as String, width=0 as Integer, height=0 as Integer)

        'print m.TOSTRING; " load: "; path
        m.cancelLoad()

        m.path = path
        'print "load: "; path

        ' This code checks for internal assets (this seems to be quicker to load)
        if (StringContains(path, "pkg://"))
            m.isInternal = true
            bmp = AssetService().loadInternal(path)
            m.bitmap = invalid

            if (bmp <> invalid)
                ' create a region from the bitmap - this enables us to have smooth scaling
                m.bitmap = createObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
                m.bitmap.setScaleMode(1) ' smooth scaling
            end if

            if(m.bitmap = invalid)
                print "!!! Error creating bitmap: ";path
            else
                m.dispatchOnLoadedEvent()
            end if
        else
            m.isInternal = false
            m.request = createObject("roTextureRequest", path)
            if (width > 0 AND height > 0)
                m.request.setSize(width, height)
            end if
            AssetService().load(m.request, m, "onBitmapLoaded", "onBitmapLoadFailed")
        end if
    end function

    this.cancelLoad = function()
        if (m.request <> invalid)
            AssetService().cancel(m.request)
            m.request = invalid
        end if
    end function

    ' this clears the image object so no rendering takes place
    this.clear = function()
        m.cancelLoad()
        m.bitmap = invalid
    end function

    ' The difference between clear and dispose is that dispose will remove the bitmap from the internal asset list
    ' This will free up video memory
    this.dispose = function()
        'print "DISPOSING " ; m.path
        if(m.destroyOnDispose)
          if m.isInternal = true
            AssetService().cleanInternalFromPath(m.path)
          else
            AssetService().unloadBitmap(m.path)
          end if
        end if
        m.cancelLoad()
        m.bitmap = invalid
    end function

    this.dispatchOnLoadedEvent = function()
        m.width = m.bitmap.GetWidth()
        m.height = m.bitmap.GetHeight()
        m.dispatchEvent(Event({
            eventType: "onLoaded",
            target: m
        }))
    end function

    this.onBitmapLoaded = function(bmp as Object)
        if (m.request <> invalid)
            'm.bitmap = bmp
            ' create a region from the bitmap - this enables us to have smooth scaling
            m.bitmap = createObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
            m.bitmap.setScaleMode(1) ' smooth scaling
            'm.request = invalid
            m.dispatchOnLoadedEvent()
        end if
    end function

    this.onBitmapLoadFailed = function()
        print m.TOSTRING; " onBitmapLoadFailed: "; m.path
        m.dispatchEvent(Event({
            eventType: "onFailed",
            target: m
        }))
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

    return this

end function