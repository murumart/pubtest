extends PanelContainer

@onready var face_texture: TextureRect = %FaceTexture
@onready var name_label: Label = %NameLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var magic_bar: ProgressBar = %MagicBar

var actor: Variant
