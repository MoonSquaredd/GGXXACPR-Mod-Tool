extends Node

var outputFilePath = ""
var printText = "Number of %s %s: "
var extraText = "extra_%s"
var separator = [255, 255, 255, 255]

signal feedback

func getDWORD(binary, offset):
	var DWORD = []
	for i in 4:
		DWORD.append(binary[(offset+3) - i])
	return DWORD

func getWORD(binary, offset):
	var WORD = []
	for i in 4:
		WORD.append(binary[offset + i])
	return WORD

func getOffset(DWORD, currentOffset):
	var offset = ((DWORD[0]*16777216) + (DWORD[1]*65536) + (DWORD[2]*256) + DWORD[3])
	
	return (offset + currentOffset)

func getPointers(binary, object, offset):
	# Reads and returns all the relative pointers of the given Object.
	var objOffset = getOffset(object, offset)
	
	var poseDataOffset = getOffset(getDWORD(binary, objOffset), objOffset)
	var spriteDataOffset = getOffset(getDWORD(binary, objOffset+4), objOffset)
	var scriptsOffset = getOffset(getDWORD(binary, objOffset+8), objOffset)
	var palettesOffset= getOffset(getDWORD(binary, objOffset+12), objOffset)
	
	return [poseDataOffset, spriteDataOffset, scriptsOffset, palettesOffset]

func getPoseList(binary, offset):
	var poseList = []
	var posePointer = 0
	
	while true:
		var currentPose = getOffset(getDWORD(binary, offset+(posePointer*4)), offset)
		var currentDWORD = getDWORD(binary, offset+(posePointer*4))
		
		if currentDWORD == separator:
			break
		
		poseList.append(currentPose)
		posePointer += 1
		
	return poseList

func getSpriteList(binary, offset):
	var spriteList = []
	var spritePointer = 0
	
	while true: 
		var currentSprite = getOffset(getDWORD(binary, offset+(spritePointer*4)), offset)
		var currentDWORD = getDWORD(binary, offset+(spritePointer*4))
		
		if currentDWORD == separator:
			break
		
		spriteList.append(currentSprite)
		spritePointer += 1

	return spriteList

func getPaletteList(binary, offset):
	var paletteList = []
	var palettePointer = 0
	
	while true:
		var currentPalette = getOffset(getDWORD(binary, offset+(palettePointer*4)), offset)
		var currentDWORD = getDWORD(binary, offset+(palettePointer*4))
		
		if currentDWORD == separator:
			break
		
		paletteList.append(currentPalette)
		palettePointer += 1
	
	return paletteList

func createFolder(folderName, parentFolder):
	var folderPath = "%s/%s"
	var existantFolder = DirAccess.dir_exists_absolute(folderPath % [parentFolder, folderName])
	
	if !existantFolder:
		DirAccess.make_dir_absolute(folderPath % [parentFolder, folderName])
	
	return folderPath % [parentFolder, folderName]

func separateRaw(rawData, outputFile):
	for i in rawData:
		for j in i:
			outputFile.store_8(j)

func extractPose(binary, poseOffset, iterator, fork):
	var forkFolder = createFolder(fork, outputFilePath)
	var folder = createFolder("poses", forkFolder)
	var filePath = "%s/pose_%s.bin"
	var outputFile = FileAccess.open(filePath % [folder, iterator], FileAccess.WRITE)
	var rawIterator = 0
	
	var rawOffset = poseOffset
	var rawData = []
	
	while true:
		var currentOffset = (rawOffset + (rawIterator*4))
		var currentWORD = getWORD(binary, currentOffset)
		
		if currentWORD == separator:
			break
		
		rawData.append(currentWORD)
		rawIterator += 1
	
	separateRaw(rawData, outputFile)

func extractSprite(binary, spriteOffset, iterator, fork):
	var forkFolder = createFolder(fork, outputFilePath)
	var folder = createFolder("sprites", forkFolder)
	var filePath = "%s/sprite_%s.bin"
	var outputFile = FileAccess.open(filePath % [folder, iterator], FileAccess.WRITE)
	var rawIterator = 0
	
	var rawOffset = spriteOffset
	var rawData = []
	
	while true:
		var currentOffset = (rawOffset + (rawIterator*4))
		var currentWORD = getWORD(binary, currentOffset)
		
		if currentWORD == separator:
			break
		
		rawData.append(currentWORD)
		rawIterator += 1
	
	separateRaw(rawData, outputFile)

func extractScript(binary, scriptsOffset, fork):
	var folder = createFolder(fork, outputFilePath)
	var filePath = "%s/play_data.bin"
	var outputFile = FileAccess.open(filePath % [folder], FileAccess.WRITE)
	var rawIterator = 0
	
	var rawOffset = scriptsOffset
	var rawData = []
	
	while true:
		var currentOffset = (rawOffset + (rawIterator*4))
		var currentWORD = getWORD(binary, currentOffset)
		
		if currentWORD == separator:
			break
		
		rawData.append(currentWORD)
		rawIterator += 1
	
	separateRaw(rawData, outputFile)

func extractPalette(binary, paletteOffset, iterator):
	var folder = createFolder("palettes", outputFilePath)
	var filePath = "%s/pal_%s.bin"
	var outputFile = FileAccess.open(filePath % [folder, iterator], FileAccess.WRITE)
	var eofReached = false
	var rawIterator = 0
	
	var rawOffset = paletteOffset
	var rawData = []
	
	while !eofReached:
		var currentOffset = (rawOffset + (rawIterator*4))
		var currentWORD = getWORD(binary, currentOffset)
		
		if currentWORD == separator:
			eofReached = true
			break
		
		rawData.append(currentWORD)
		rawIterator += 1
	
	for i in rawData:
		for j in i:
			outputFile.store_8(j)

func extractionMain(binary, pointers, fork):
	var poseList = getPoseList(binary, pointers[0])
	for i in poseList.size():
		extractPose(binary, poseList[i], i, fork)
	print(printText % [fork, "Poses"], poseList.size())
	
	var spriteList = getSpriteList(binary, pointers[1])
	for i in spriteList.size():
		extractSprite(binary, spriteList[i], i, fork)
	print(printText % [fork, "Sprites"], spriteList.size())
	
	extractScript(binary, pointers[2], fork)
	print(fork, " Play Data extracted")

func getExtras(binary):
	# Iterates over pointers after the character object pointer until it reaches the 0xFFFFFFFF separator.
	var extraObjects = []
	var pointerPointer = 1
	while true:
		var currentPointer = getDWORD(binary, (pointerPointer*4))
		
		if (pointerPointer >= 4) or (currentPointer == separator):
			break
		
		extraObjects.append(currentPointer)
		pointerPointer += 1
	
	return extraObjects

func read(filePath):
	# Open the Binary and read it, copying its bytes to an array that is going to be used in the entire process.
	var inputFile = FileAccess.open(filePath, FileAccess.READ)
	var content = []
	while true:
		content.append(inputFile.get_8())
		if inputFile.eof_reached():
			break
	
	# Get the Object File pointers at the start of the Binary.
	var characterObj = getDWORD(content, 0)
	var extraObjs = getExtras(content)
	
	# Get the Object Relative pointers at their respective headers.
	var characterPointers = getPointers(content, characterObj, 0)
	var extraPointers = []
	for i in extraObjs.size():
		extraPointers.append(getPointers(content, extraObjs[i], 0))
	
	# Extracts all Palettes.
	var paletteList = getPaletteList(content, characterPointers[3])
	for i in paletteList.size():
		extractPalette(content, paletteList[i], i)
	print("Number of Palettes: ", paletteList.size())
	
	# Extracts the rest of the content. Object relative.
	extractionMain(content, characterPointers, "character")
	for i in extraObjs.size():
		extractionMain(content, extraPointers[i], extraText % [i])
	
	# Just to make sure the file is closed once done.
	feedback.emit()
	inputFile.close()

# Entry Point | Once the "Extract" button is pressed, the logic starts here.
func _on_feedback_file_found(inFilePath, outFilePath):
	# Sets the Output Directory variable and attempts to read the binary file.
	outputFilePath = outFilePath
	read(inFilePath)
