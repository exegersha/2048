function StyleUtils()

    if (m.styleUtils = invalid)

        theme = NowTVTheme()
        aaFonts = AppFonts()

        m.styleUtils = {

        	fonts: aaFonts

' ////////////////////////////
'           SETTINGS VIEW
' ////////////////////////////
            settingsView: {
                bgColour: theme.GREEN
            }
        }

    end if

    return m.styleUtils

end function
