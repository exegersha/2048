function countObjectProperties(obj as Object) as Integer
    n = 0

    for each prop in obj
        n = n + 1
    end for

    return n
end function
