extends Node

signal feedback
signal parse_objects

# Entry Point | Once the "Extract" button is pressed, the logic starts here.
func _on_feedback_file_found(inFilePath, outFilePath):
	# Parse and extract all objects within the character file.
	parse_objects.emit(inFilePath, outFilePath)

func _on_object_parser_objects_parsed():
	feedback.emit()
