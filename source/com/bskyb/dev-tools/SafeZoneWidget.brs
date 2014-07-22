' Safe zone widget used to display the two Roku safe zones ("Title" and "Action").
' When this widget gets created it will automatically add itself to the overlayContainer
' on Stage to make sure it is always present "on top" of the application.
' @name SafeZoneWidget
' @inherits CoreElement
' @param {Object} properties, containing properties used to override defauls.
' @return {Object} safeZoneWidgetInstance, the SafeZoneWidget as a SINGLETON
function SafeZoneWidget (properties = {} as Object) as Object

    if (m.safeZoneWidgetInstance = invalid)
        '  This object is passed to the CoreElement constructor at the bottom of this class
        classDefinition = {
            TOSTRING: "<SafeZoneWidget>",
            parentContainer: Stage().overlayContainer,
            style: {
                screen: {
                    width: 1280,
                    height: 720
                },
                safeZone: {
                    action: {
                        width: 1150,
                        height: 646,
                        colour: &h00, ' Transparent
                        borderColour: &hBE0E1999,
                        border: {
                            top: 35,
                            right: 64,
                            bottom: 35,
                            left: 64
                        }
                    },
                    title: {
                        width: 1022,
                        height: 578,
                        colour: &h00, ' Transparent
                        borderColour: &hBE0E19CC,
                        border: {
                            top: 70,
                            right: 128,
                            bottom: 70,
                            left: 128
                        }
                    }
                },
                text: {
                    colour: &h000000FF,
                    font: FontManager().getDefaultFont(16, false, false)
                }
            },

            actionSafeZone: invalid,
            actionSafeZoneTF: invalid,

            titleSafeZone: invalid,
            titleSafeZoneTF: invalid,

            settings: {
                options: {
                    TITLE_AND_ACTION_SZ: 0,
                    ACTION_SZ: 1,
                    NO_SZ: 2
                },
                selected: 2, ' Default: NO_SZ
                selections: [
                    function (context) as void
                        ' TITLE + ACTION SAFE ZONE
                        context.titleSafeZone.visible = true
                        context.titleSafeZoneTF.visible = true
                        context.actionSafeZone.visible = true
                        context.actionSafeZoneTF.visible = true
                    end function,
                    function (context) as void
                        ' ACTION SAFE ZONE
                        context.titleSafeZone.visible = false
                        context.titleSafeZoneTF.visible = false
                        context.actionSafeZone.visible = true
                        context.actionSafeZoneTF.visible = true
                    end function,
                    function (context) as void
                        ' OFF
                        context.titleSafeZone.visible = false
                        context.titleSafeZoneTF.visible = false
                        context.actionSafeZone.visible = false
                        context.actionSafeZoneTF.visible = false
                    end function
                ]
            },

            ' Sets the next setting by incrementing/decrementing by one depending on the control parameter.
            ' If we reach the end of the selections array, loop around to the beginning again.
            ' @param {Boolean} increment, increments if true otherwise decrements the selected setting. Defaults to "true".
            setNextSetting: function (increment = true as Boolean) as Void
                i = 1
                length = m.settings.selections.count()

                if NOT (increment)
                    i = -1
                end if

                nextSelection = m.settings.selected + i

                if (nextSelection < 0)
                    nextSelection = length - 1
                else if (nextSelection > length - 1)
                    nextSelection = 0
                end if

                m.settings.selections[nextSelection](m)
                m.settings.selected = nextSelection
            end function,

            ' Sets the setting specified by parameter if it is a valid option.
            ' @param {Integer} setting, the setting to set as current setting. Defaults to "NO_SZ".
            setSetting: function (setting = m.settings.options.NO_SZ as Integer) as Void
                if (m.settings.selections[setting] <> invalid)
                    m.settings.selections[setting](m)
                    m.settings.selected = setting
                end if
            end function,

            ' Creates all UI components associated with this widget.
            ' @param {Object} style, style for the UI components. Defaults to "current" style.
            createUI: function (style = m.style as Object) as Void
                ' SafeZones
                actionSafeZone = BorderedRectangle()
                actionSafeZone.colour = style.safeZone.action.colour
                actionSafeZone.borderColour = style.safeZone.action.borderColour
                actionSafeZone.height = style.safeZone.action.height
                actionSafeZone.width = style.safeZone.action.width
                actionSafeZone.border = style.safeZone.action.border

                actionSafeZoneTF = TextField()
                actionSafeZoneTF.colour = style.text.colour
                actionSafeZoneTF.setFont(style.text.font)
                actionSafeZoneTF.setText("Action Safe Zone, border width: " + StringFromInt(actionSafeZone.border.right) + " x " + StringFromInt(actionSafeZone.border.top))
                actionSafeZoneTF.setXY(style.screen.width / 2 - actionSafeZoneTF.width / 2, 16)

                titleSafeZone = BorderedRectangle()
                titleSafeZone.colour = style.safeZone.title.colour
                titleSafeZone.borderColour = style.safeZone.title.borderColour
                titleSafeZone.height = style.safeZone.title.height
                titleSafeZone.width = style.safeZone.title.width
                titleSafeZone.border = style.safeZone.title.border

                titleSafeZoneTF = TextField()
                titleSafeZoneTF.colour = style.text.colour
                titleSafeZoneTF.setFont(style.text.font)
                titleSafeZoneTF.setText("Title Safe Zone, border width: " + StringFromInt(titleSafeZone.border.right) + " x " + StringFromInt(titleSafeZone.border.top))
                titleSafeZoneTF.setXY(style.screen.width / 2 - titleSafeZoneTF.width / 2, 45)


                m.titleSafeZone = titleSafeZone
                m.addChild(titleSafeZone)
                m.titleSafeZoneTF = titleSafeZoneTF
                m.addChild(titleSafeZoneTF)

                m.actionSafeZone = actionSafeZone
                m.addChild(actionSafeZone)
                m.actionSafeZoneTF = actionSafeZoneTF
                m.addChild(actionSafeZoneTF)

                m.setSetting()
            end function,

            ' Initializes the SafeZoneWidget and creates
            ' @param {Object} properties, containing properties only to be used by the init method. Defaults to empty Object.
            init: function (properties = {} as Object) as Void
                m.createUI()
            end function
        }

        for each property in properties
            classDefinition.AddReplace(property, properties[property])
        end for

        m.safeZoneWidgetInstance = CoreElement(classDefinition)
    end if

    return m.safeZoneWidgetInstance

end function
