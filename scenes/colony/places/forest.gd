extends "res://scenes/colony/place.gd"

# virtual overrides

func _ready() -> void:
	super()


# construction

# methods

func get_place_texture() -> Texture2D:
	var at := super() as AtlasTexture
	at.atlas = preload("res://scenes/colony/houses.png")
	at.region = Rect2(16, 0, 16, 16)
	return at
