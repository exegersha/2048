function Number (properties = {} as Object) as Object

    '  This object is passed to the CoreElement constructor at the bottom of this class
    classDefinition = {

        TOSTRING: "<Number>"
        msgBus: MessageBus()
        value: invalid
        ' store position in matrixXY: i=row, j=column
        i: invalid
        j: invalid
        ' reference needed to disposeUI
        aNumber: invalid


        aaTextColour: {
            number2:    &h776e65FF
            number4:    &h776e65FF
            number8:    &hf7f5f2FF
            number16:   &hf7f5f2FF
            number32:   &hf7f5f2FF
            number64:   &hf7f5f2FF
            number128:  &hf7f5f2FF
            number256:  &hf7f5f2FF
            number512:  &hf7f5f2FF
            number1024: &hf7f5f2FF
            number2048: &hf7f5f2FF
        }
        aaBgColour: {
            number2:    &heee4daFF
            number4:    &hede0c8FF
            number8:    &hf2b179FF
            number16:   &hf59563FF
            number32:   &hf67c5fFF
            number64:   &hf65e3bFF
            number128:  &hedcf72FF
            number256:  &hf0cf4dFF
            number512:  &hebc450FF
            number1024: &he0b814FF
            number2048: &hebc400FF
        }
        aaFont: {
            number2:    StyleUtils().fonts.BROWN_PRO_48_BOLD
            number4:    StyleUtils().fonts.BROWN_PRO_48_BOLD
            number8:    StyleUtils().fonts.BROWN_PRO_48_BOLD
            number16:   StyleUtils().fonts.BROWN_PRO_38_BOLD
            number32:   StyleUtils().fonts.BROWN_PRO_38_BOLD
            number64:   StyleUtils().fonts.BROWN_PRO_38_BOLD
            number128:  StyleUtils().fonts.BROWN_PRO_32_BOLD
            number256:  StyleUtils().fonts.BROWN_PRO_32_BOLD
            number512:  StyleUtils().fonts.BROWN_PRO_32_BOLD
            number1024: StyleUtils().fonts.BROWN_PRO_28_BOLD
            number2048: StyleUtils().fonts.BROWN_PRO_28_BOLD
        }
        aaPadding: {
            number2: {top: 20, left: 33}
            number4: {top: 20, left: 33}
            number8: {top: 20, left: 33}
            number16: {top: 25, left: 25}
            number32: {top: 25, left: 25}
            number64: {top: 25, left: 25, right: 0, bottom: 0}
            number128: {top: 28, left: 20, right: 0, bottom: 0}
            number256: {top: 28, left: 20, right: 0, bottom: 0}
            number512: {top: 28, left: 20, right: 0, bottom: 0}
            number1024: {top: 30, left: 15, right: 0, bottom: 0}
            number2048: {top: 30, left: 15, right: 0, bottom: 0}
        }


        createUI: function () as Void
            numberStyle = {
                minWidth: 96
                minHeight: 96
                font: m.aaFont["number" + m.value]
                active: {
                    textColour: m.aaTextColour["number" + m.value]
                    backgroundColour: m.aaBgColour["number" + m.value]
                }
                padding: m.aaPadding["number" + m.value]
            }

            ' put a rectanlge in each position of the background image-matrix
            aNumber = Button({style: numberStyle})
            aNumber.setText(m.value)
            aNumber.setActive()
            m.addChild(aNumber)
            m.aNumber = aNumber
        end function

        init: function (properties = {} as Object) as Void
            ' number value = {2, 4, 8, ... , 1024}
            m.value = properties.value
            ' position in matrixXY
            m.i     = properties.i
            m.j     = properties.j
            m.createUI()
        end function

        dispose: function () as Void
            ' print m.TOSTRING; " dispose m.aNumber="; m.aNumber
            aNumber = m.aNumber
            if (aNumber <> invalid)
                m.removeChild(aNumber)
                aNumber.dispose()
                aNumber = invalid
            end if
            m.aNumber = aNumber
            m = invalid
            RunGarbageCollector()
        end function
    }

    for each property in properties
        classDefinition.AddReplace(property, properties[property])
    end for

    this = CoreElement(classDefinition)

    return this

end function
