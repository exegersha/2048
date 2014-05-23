' UTILITY METHODS

function registryTestsSetup() as Object
    globalAA = getGLobalAA()

	globalAA.registryTestsParams = {
		section: "registryTest",
		testObject: {
			keyA : "valueA"
			keyB : "valueB"
			keyC : "valueC"
		},
		testKey: "aTestKey",
		testValue: "aTestValue"
	}

	globalAA.rgm = RegistryManager()

	registryTestsClearRegistryForSection()
	registryTestsClearRegistryForSection(globalAA.registryTestsParams.section)

	return globalAA
end function

function registryTestsTearDown() as Void
	globalAA = getGLobalAA()
	section = globalAA.registryTestsParams.section

	registryTestsClearRegistryForSection()
	registryTestsClearRegistryForSection(globalAA.registryTestsParams.section)

	globalAA.rgm = invalid
	globalAA.registryTestsParams = invalid
end function

function registryTestsClearRegistryForSection(section=invalid as Dynamic) as Void
	if (section = invalid)
		section = getGLobalAA().rgm.DEFAULT_SECTION
	end if

	keyList = RegKeyList(section)
    for each key in keyList
        RegDelete(key, section)
    end for
end function


' TESTS START HERE
' TESTS FOR THE Write METHOD

function testWriteSingleNoParams(t as Object) as Void
	globalAA = registryTestsSetup()

	globalAA.rgm.write()

	' Passing no arguments should use the default section
	keyList = RegKeyList(globalAA.rgm.DEFAULT_SECTION)
	t.assertEqual(keyList.Count(), 0)

	registryTestsTearDown()
end function

function testWriteNoValue(t as Object) as Void
	' It's impossible to test this since the write method takes arguments as
	' 	Strings, and trying to call write(key, , section) fails
	' 	as the value is expected to be a string.
end function

function testWriteNoValueNoSection(t as Object) as Void
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey

	globalAA.rgm.write(key)

	' Passing no arguments should use the default section
	keyList = RegKeyList(globalAA.rgm.DEFAULT_SECTION)

	t.assertEqual(keyList.Count(), 0)

	registryTestsTearDown()
end function

function testWriteNoSection(t as Object) as Void
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.rgm.DEFAULT_SECTION

	globalAA.rgm.write(key, value)
	keyList = RegKeyList(section)

	t.assertEqual(keyList.Count(), 1)
	t.assertTrue(RegKeyExists(key, section))
	t.assertEqual(RegRead(key, section), value)

	registryTestsTearDown()
end function

function testWriteSingle(t as Object) as Void
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	globalAA.rgm.write(key, value, section)

	t.assertTrue(RegKeyExists(key, section))
	t.assertEqual(RegRead(key, section), value)

	registryTestsTearDown()
end function


' TESTS FOR THE WriteAll METHOD

function testWriteAllNoParams(t as Object) as Void
	globalAA = registryTestsSetup()

	globalAA.rgm.writeAll()

	' Passing no arguments should use the default section
	keyList = RegKeyList(globalAA.rgm.DEFAULT_SECTION)

	t.assertEqual(keyList.Count(), 0)

	registryTestsTearDown()
end function

function testWriteAll(t as Object) as Void
	globalAA = registryTestsSetup()

	testObject = globalAA.registryTestsParams.testObject
	section = globalAA.registryTestsParams.section

	globalAA.rgm.writeAll(testObject, section)

	for each key in testObject
        t.assertTrue(RegKeyExists(key, section))
		t.assertEqual(RegRead(key, section), testObject[key])
    end for

	registryTestsTearDown()
end function


' TESTS FOR THE Read METHOD

function testReadSingleNoParams(t as Object) as Void
	globalAA = registryTestsSetup()

	' Passing no arguments should return invalid
	t.assertInvalid(globalAA.rgm.read())

	registryTestsTearDown()
end function

function testReadNoSection(t as Object) as Void
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue

	RegWrite(key, value, globalAA.rgm.DEFAULT_SECTION)

	readValue = globalAA.rgm.read(key)

	t.assertNotInvalid(readValue)
	t.assertEqual(readValue, value)

	registryTestsTearDown()
end function

function testReadSingle(t as Object) as Void
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	RegWrite(key, value, section)

	readValue = globalAA.rgm.read(key, section)

	t.assertNotInvalid(readValue)
	t.assertEqual(readValue, value)

	registryTestsTearDown()
end function


' TESTS FOR THE ReadAll METHOD

function testReadAllNoParams(t as Object) as Void
	globalAA = registryTestsSetup()

	' Passing no arguments should return an empty object
	' 	(as we didn't setup the registry with values in the globalAA.rgm.DEFAULT_SECTION section)
	t.assertEqual({}, globalAA.rgm.readAll())

	registryTestsTearDown()
end function

function testReadAllNoParamsWithDefaultValues(t as Object) as Void
	globalAA = registryTestsSetup()

	testObject = globalAA.registryTestsParams.testObject

	' Writing all values of the testObject to the default section
	for each key in testObject
		RegWrite(key, testObject[key], globalAA.rgm.DEFAULT_SECTION)
    end for

	' Passing no arguments should return an object with
	' 	all our default values
	readObject = globalAA.rgm.readAll()

	t.assertEqual(readObject, testObject)

	registryTestsTearDown()
end function

function testReadAll(t as Object) as Void
	globalAA = registryTestsSetup()

	testObject = globalAA.registryTestsParams.testObject
	section = globalAA.registryTestsParams.section

	' Writing all values of the testObject to the default section in the registry
	for each key in testObject
		RegWrite(key, testObject[key], section)
    end for

	' Passing no arguments should return an object with
	' 	all our default values
	readObject = globalAA.rgm.readAll(section)

	t.assertEqual(readObject, testObject)

	registryTestsTearDown()
end function


' TESTS FOR THE Remove METHOD

function testRemoveNoParams(t as Object)
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	RegWrite(key, value, section)

	globalAA.rgm.remove()

	t.assertTrue(RegKeyExists(key, section))

	registryTestsTearDown()
end function

function testRemoveNoSection(t as Object)
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	RegWrite(key, value, section)

	globalAA.rgm.remove(key)

	t.assertTrue(RegKeyExists(key, section))

	registryTestsTearDown()
end function

function testRemove(t as Object)
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	RegWrite(key, value, section)

	globalAA.rgm.remove(key, section)

	t.assertFalse(RegKeyExists(key, section))

	registryTestsTearDown()
end function


' TESTS FOR THE Remove METHOD

function testRemoveAllNoParams(t as Object)
	globalAA = registryTestsSetup()

	testObject = globalAA.registryTestsParams.testObject
	section = globalAA.registryTestsParams.section

	' Writing all values of the testObject to the default section in the registry
	for each key in testObject
		RegWrite(key, testObject[key], section)
    end for

	globalAA.rgm.removeAll()

	for each key in testObject
		t.assertTrue(RegKeyExists(key, section))
    end for

	registryTestsTearDown()
end function

function testRemoveAll(t as Object)
	globalAA = registryTestsSetup()

	testObject = globalAA.registryTestsParams.testObject
	section = globalAA.registryTestsParams.section

	' Writing all values of the testObject to the default section in the registry
	for each key in testObject
		RegWrite(key, testObject[key], section)
    end for

	globalAA.rgm.removeAll(section)

	for each key in testObject
		t.assertFalse(RegKeyExists(key, section))
	end for

	registryTestsTearDown()
end function


' TESTS FOR THE Exists METHOD

function testExistsNoParams(t as Object)
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	RegWrite(key, value, section)

	returnVal = globalAA.rgm.exists()

	t.assertFalse(returnVal)

	registryTestsTearDown()
end function

function testExistsNoSection(t as Object) as Void
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	RegWrite(key, value, section)

	returnVal = globalAA.rgm.exists(key)

	t.assertFalse(returnVal)

	registryTestsTearDown()
end function

function testExists(t as Object) as Void
	globalAA = registryTestsSetup()

	key = globalAA.registryTestsParams.testKey
	value = globalAA.registryTestsParams.testValue
	section = globalAA.registryTestsParams.section

	RegWrite(key, value, section)

	returnVal = globalAA.rgm.exists(key, section)

	t.assertTrue(returnVal)

	registryTestsTearDown()
end function
