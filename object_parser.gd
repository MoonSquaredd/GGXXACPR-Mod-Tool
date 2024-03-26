extends Node

const SEPARATOR = 0xFFFFFFFF
var indexes = ["character"]
var subIndexes = ["pose", "sprite", "script", "palette"]
var strFormat = "%s%d"
var outFileName = "%s/%s_%s.%s"
var suffix = 0

signal objects_parsed

func getPointers(file, offset):
	file.seek(offset)
	var pointerList = []
	while true:
		var pointer = file.get_32()
		
		if (pointer == SEPARATOR) or (file.eof_reached()):
			break
		
		pointerList.append(pointer + offset)
	return pointerList

func extract(file, src, dest):
	file.seek(src)
	
	while true:
		var current = file.get_32()
		if (current == SEPARATOR) or (file.eof_reached()):
			break
		
		dest.store_32(current)

func getSubFiles(file, object):
	file.seek(object)
	var pointers = getPointers(file, object)
	return pointers

func getFiles(file, object, type):
	file.seek(object)
	
	var pointers = getPointers(file, object)
	
	var poseFiles = getSubFiles(file, pointers[0])
	var spritesFiles = getSubFiles(file, pointers[1])
	var scriptFile = [pointers[2]]
	
	var outFiles = [poseFiles, spritesFiles, scriptFile]
	
	match type:
		"character":
			var paletteFiles = getSubFiles(file, pointers[3])
			outFiles.append(paletteFiles)
		"sound":
			return pointers
	
	return outFiles

func createSubFolders(index, folder):
	var folderFormat = "%s/%s"
	match index:
		"character":
			for i in subIndexes:
				var newSubFolder = DirAccess.make_dir_absolute(folderFormat % [folder, i])
		"sound":
			return
		_:
			for i in (subIndexes.size() - 1):
				var newSubFolder = DirAccess.make_dir_absolute(folderFormat % [folder, subIndexes[i]])

func createFolders(outputPath):
	var folderFormat = "%s/%s"
	for i in indexes:
		DirAccess.make_dir_absolute(folderFormat % [outputPath, i])
		createSubFolders(i, folderFormat % [outputPath, i])

## Entry Point
func _on_main_parse_objects(filePath, outputPath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var objectPointers = getPointers(file, 0)
	
	var characterObjectFile = objectPointers[0]
	var extraObjects = []
	for i in objectPointers.size()-2:
		var extraObjectFile = objectPointers[i+1]
		extraObjects.append(extraObjectFile)
		indexes.append(strFormat % ["extra_", i])
	var soundObjectFile = objectPointers[-1]
	indexes.append("sound")
	
	var characterFiles = getFiles(file, characterObjectFile, "character")
	var extraFiles = []
	for i in extraObjects.size():
		var extraFile = getFiles(file, extraObjects[i], "extra")
		extraFiles.append(extraFile)
	var soundFiles = getFiles(file, soundObjectFile, "sound")
	
	createFolders(outputPath)
	
	## This section is a mess, i'll fix this later teehee
	for i in characterFiles.size():
		var folderFormat = "%s/%s/%s"
		for j in characterFiles[i].size():
			extract(file, characterFiles[i][j], FileAccess.open(outFileName % [folderFormat % [outputPath, "character", subIndexes[i]], subIndexes[i], j, "bin"], FileAccess.WRITE))
	
	for i in extraFiles.size():
		for j in extraFiles[i].size():
			var folderFormat = "%s/%s/%s"
			for k in extraFiles[i][j].size():
				extract(file, extraFiles[i][j][k], FileAccess.open(outFileName % [folderFormat % [outputPath, strFormat % ["extra_", i], subIndexes[j]], subIndexes[j], k, "bin"], FileAccess.WRITE))
				
				objects_parsed.emit()
