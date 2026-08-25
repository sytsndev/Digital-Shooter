class_name WeaponSlot extends Resource

var weapon_res: WeaponResource
var is_active: bool = false


func _init(p_weapon_res = null, p_is_active = false):
	weapon_res = p_weapon_res
	is_active = p_is_active
