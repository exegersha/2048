'' ArrayUtils.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION
'' OR DISTRIBUTION STRICTLY PROHIBITED.

' Converts the elements in an array to strings, inserts the specified separator between the elements, concatenates them, and returns the resulting string.
function ArrayJoin(arr as Object, sep=", " as String) as String
    ' Check Array isn't empty
    if (arr = invalid) return ""

    index = 0
    total = arr.count()
    output = ""

    ' There are items in the array
    while (index < total)
        v = arr[index]
        vType = type(v)
        'print v; " = "; vType
        if (vType = "roString" OR vType = "String")
            v = v
        else if (vType = "roInt" OR vType = "roInteger" OR vType = "roFloat")
            v = StringFromNumber(v)
        else if (vType = "roBoolean")
            if (v)
                v = "true"
            else
                v = "false"
            end if
        else
            v = "<" + type(v) + ">"
        end if

        ' Ignoring empty elements
        if( NOT v = "" )
            output = output + v + sep
        end if

        index = index + 1
    end while

    return Mid(output, 0, Len(output) - Len(sep))
end function

' Splices array according to parameters.
' @param arr, the array to splice. Please observe that the actual array will be modified and returned
' @param index, start index to splice from
' @param itemsToRemove, number om items to remove from array
' @param item, object to insert at index. If an array is passed in, the containing items will be added rather than the array itself.
' @return newArr, the modified input array
function ArraySplice (arr as Object, index as Integer, itemsToRemove = -1 as Integer, item = invalid as Object) as Object
    newArr = []

    if (index < 0)
        if (index = -1)
            index = arr.count() + index
        else
            index = arr.count() - 1 + index
        end if
    end if

    if (itemsToRemove = -1)
        itemsToRemove = arr.count() - index
    end if

    for i = 0 to index - 1 step 1
        newArr.push(arr.shift())
    end for

    if (itemsToRemove > 0)
        while (itemsToRemove > 0)
            arr.shift()
            itemsToRemove = itemsToRemove - 1
        end while
    end if

    if (type(item) = "roArray")
        length = item.count()
        for i = 0 to length - 1 step 1
            newArr.push(item[i])
        end for

    else if (item <> invalid)
        newArr.push(item)
    end if

    length = arr.count()
    for i = 0 to length - 1 step 1
        newArr.push(arr.shift())
    end for

    length = newArr.count()
    for i = 0 to length - 1 step 1
        arr.push(newArr.shift())
    end for

    return arr
end function

' TODO: ADD TESTS
function ArrayClone(source=[] as Object) as Object
    newArr = []

    for i = 0 to source.Count() - 1 step 1
        newArr.push(source[i])
    end for

    return newArr
end function

' Compare two associative arrays for equality, checking if each Key<->Value entry in arrA is present in arrB, and both arrays have the same size.
' NOTE: it does NOT consider the order of the entries for comparison.
function AssociativeArrayEqual(arrA as Object, arrB as Object) as Boolean
    equals = true
    if (AssociativeArrayCount(arrA) = AssociativeArrayCount(arrB))
        for each key in arrA
            if (type(arrA[key]) = "roAssociativeArray")
                equals = equals AND AssociativeArrayEqual(arrA[key], arrB[key])
            else if (type(arrA[key]) ="roArray")
                equals = equals AND ArrayEqual(arrA[key], arrB[key])
            else
                if NOT (arrB.DoesExist(key) AND arrB.LookUp(key)=arrA[key])
                    equals = false
                end if
            end if

            if NOT equals
                exit for
            end if
        end for
    else
        equals = false
    end if
    return equals
end function

'Returns the number of entries in an roAssociativeArray
function AssociativeArrayCount(aa as Object) as Integer
    i = 0
    for each k in aa
        i = i + 1
    end for
    return i
end function

'Compare two roArray objects for equality.
' NOTE: it considers the order of elements for comparison.
function ArrayEqual(arr1 as Object, arr2 as Object) as Boolean
    equals = true
    l1 = arr1.Count()
    l2 = arr2.Count()
    if not l1 = l2 then
        equals = false
    else
        for i = 0 to l1 - 1 step 1
            v1 = arr1[i]
            v2 = arr2[i]
            if (type(v1)="roArray")
                equals = equals AND ArrayEqual(v1, v2)
            else
                if not v1 = v2 then
                    equals = false
                end if
            end if

             if NOT equals
                exit for
            end if
        end for
    end if

    return equals
end function
