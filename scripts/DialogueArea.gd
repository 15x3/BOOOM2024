extends Area3D

@export var dialogue_resources : DialogueResource
@export var dialogue_start : String = "this_is_a_node_title"
# Called when the node enters the scene tree for the first time.
func action() -> void:
	DialogueManager.show_example_dialogue_balloon(dialogue_resources,dialogue_start)
	# 如果只希望出现一次,加个queue_free
	queue_free()
	pass # Replace with function body.
