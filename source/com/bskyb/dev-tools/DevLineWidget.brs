function DevLineWidget (properties = {} as Object) as Object
     
    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {    
        TOSTRING: "<DevLineWidget>",

        ' METHODS    
        handleDispose: function ()
            print "Disposing DevLineWidget"
        end function,

        init: function (properties = {} as Object)
            devLine = Rectangle()
            devLine.width = properties.width
            devLine.height = properties.height
            devLine.colour = properties.colour
            m.addChild(devLine)

            positionLabelGlobal = TextField()
            positionLabelGlobal.setFont(StyleUtils().fonts.BROWN_PRO_20_LIGHT)
            positionLabelGlobal.colour = properties.colour
            positionLabelGlobal.setText("Global X: " + StringFromInt(devLine.globalX) + ", Global Y: " + StringFromInt(devLine.globalY))

            if (properties.width > properties.height) ' horizontal line'
                positionLabelGlobal.setXY(65, devLine.y - positionLabelGlobal.height - 10)  
            else
                positionLabelGlobal.setXY(devLine.x + 10, 65)  
            end if
            m.addChild(positionLabelGlobal)

            positionLabelRelative = TextField()
            positionLabelRelative.setFont(StyleUtils().fonts.BROWN_PRO_20_LIGHT)
            positionLabelRelative.colour = properties.colour
            positionLabelRelative.setText("Relative X: " + StringFromInt(devLine.x) + ", Relative Y: " + StringFromInt(devLine.y))

            if (properties.width > properties.height) ' horizontal line'
                positionLabelRelative.setXY(65, positionLabelGlobal.y - positionLabelRelative.height - 5)  
            else
                positionLabelRelative.setXY(devLine.x + 10, positionLabelGlobal.y + positionLabelRelative.height + 5)  
            end if

            m.addChild(positionLabelRelative)
        end function
    }
    
    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this
end function