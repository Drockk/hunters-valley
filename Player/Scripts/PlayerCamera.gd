class_name PlayerCamera extends Camera2D

func _ready() -> void:
	LevelManager.TileMapBoundsChanged.connect(UpdateLimits)
	UpdateLimits(LevelManager.current_tilemap_bounds)

func UpdateLimits(_bounds: Array[Vector2]) -> void:
	if _bounds == []:
		return
	
	limit_left = int(_bounds[0].x)
	limit_top = int(_bounds[0].y)
	limit_right = int(_bounds[1].x)
	limit_bottom = int(_bounds[1].y)
	pass
