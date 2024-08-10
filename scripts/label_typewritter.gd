extends Label

var total_characters = 0
var text_speed = 35
var is_typing = false
var accumulated_time = 0.0

func _ready():
	# count numbers of characters in text
	total_characters = text.length()
	# initially no text displayed
	visible_characters = 0
	# connect the visibility_changed signal to the _on_visibility_changed function
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))

func _process(delta):
	if is_typing:
		if visible_characters < total_characters:
			accumulated_time += delta * text_speed
			while accumulated_time >= 1.0:
				visible_characters += 1
				accumulated_time -= 1.0
				if visible_characters >= total_characters:
					break

func start_typing():
	is_typing = true

func _on_visibility_changed():
	if visible:
		visible_characters = 0
		accumulated_time = 0.0
		is_typing = true
	else:
		is_typing = false
