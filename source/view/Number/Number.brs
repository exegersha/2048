function Number (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<Number>"
        msgBus: MessageBus()
        ' aNumber: invalid
        value: invalid
        i: invalid
        j: invalid

        createUI: function () as Void
            ' STYLES TAKEN FROM : http://gamesdreams.com/showthread.php?297469-Play-2048-Game-Online
            ' aaTextColour = {}
            aaTextColour = {
                number2: &h776e65FF
                number4: &h776e65FF
            }
            ' aaBgColour = {}
            aaBgColour = {
                number2: &heee4daFF
                number4: &hede0c8FF
            }

            ' Move the style definitions for each number to style utils
            numberStyle = {
                minWidth: 96
                minHeight: 96
                font: StyleUtils().fonts.BROWN_PRO_48_BOLD
                active: {
                    textColour: aaTextColour["number" + m.value]
                    backgroundColour: aaBgColour["number" + m.value]
                }
                padding: {
                    top: 20
                    left: 30
                }
            }

            ' put a rectanlge in each position on the image-matrix
            aNumber = Button({style: numberStyle})
            aNumber.setText(m.value)
            ' aNumber.setXY(m.matrixXY[0,0].X, m.matrixXY[0,0].Y)

            ' position in matrixXY
            ' aNumber.i = 0
            ' aNumber.j = 0
            aNumber.setActive()
            m.addChild(aNumber)
            ' m.aNumber = aNumber
        end function

        init: function (properties = {} as Object) as Void
            ' number value = {2, 4, 8, ... , 1024}
            m.value = properties.value
            ' position in matrixXY
            m.i     = properties.i
            m.j     = properties.j
            m.createUI()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
