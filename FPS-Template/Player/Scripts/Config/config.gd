class_name Config
extends Control

@export var player: Player

@export_category("labels")
@export var crouch_toggle: CheckBox
@export var sprint_toggle: CheckBox
@export var d_jump_toggle: CheckBox
@export var wall_run_toggle: CheckBox
@export var slide_toggle: CheckBox
@export var dash_toggle: CheckBox

@export var movement_type: OptionButton
@export var slide_type: OptionButton


func _on_crouch_toggled(toggled_on: bool) -> void:
	player.player_res.crouch = toggled_on


func _on_sprint_toggled(toggled_on: bool) -> void:
	player.player_res.sprint = toggled_on


func _on_double_jump_toggled(toggled_on: bool) -> void:
	player.player_res.double_jump = toggled_on


func _on_wall_run_toggled(toggled_on: bool) -> void:
		player.player_res.wall_run = toggled_on


func _on_slide_toggled(toggled_on: bool) -> void:
	player.player_res.slide = toggled_on


func _on_dash_toggled(toggled_on: bool) -> void:
	player.player_res.dash = toggled_on


func _on_movement_type_item_selected(index: int) -> void:
	if index == 0:
		player.player_res.movement_type = player.player_res.MovementType.FLOATY
	elif index == 1:
		player.player_res.movement_type = player.player_res.MovementType.WISH_DIR
	elif index == 2:
		player.player_res.movement_type = player.player_res.MovementType.MOMENTUM


func _on_slide_type_item_selected(index: int) -> void:
	if index == 0:
		player.player_res.slide_type = player.player_res.SlideType.DASH_SLIDE
	elif index == 1:
		player.player_res.slide_type = player.player_res.SlideType.GLIDE_SLIDE


func _on_camera_lean_toggled(toggled_on: bool) -> void:
	player.player_res.c_lean = toggled_on


func _on_camera_fov_change_toggled(toggled_on: bool) -> void:
		player.player_res.c_fov_change = toggled_on
