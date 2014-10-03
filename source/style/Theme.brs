function AppTheme()
    return {

        ' The white, blacks and greys follow a naming convention that's
        '   simple to implement:
        '
        ' BLACK:
        '       - The base color is "safe black": #080808
        '       - Variations exist for different opacities
        '       - Black at 80% is therefore named BLACK_80, and
        '           the 80% is translated to 80% of 255 in
        '           hexadecimal, wich is CC
        '
        ' WHITE:
        '       - The base color is "safe white": #E9E9E9
        '       - Variations exist for different opacities
        '       - White at 25% is therefore named WHITE_25, and
        '           the 25% is translated to 25% of 255 in
        '           hexadecimal, wich is 40
        '
        ' GREYS:
        '       - Greys follow a regular pattern #XYXYXY, anything
        '           else than this is NOT grey
        '       - Variations may exist for different opacities
        '       - Names use the XY pattern followed by the opacity
        '           if needed.
        '           For example, a grey #767676 at 60% opacity will
        '           be named GREY_76_60, where 76 is the hex pattern
        '           and 60% us the opacity, which in hex is 99
        '           the color is therefore &h76767699

        CLEAR: &h00000000, ' Completely transparent
        GREEN: &h5B9B1FFF
    }
end function
