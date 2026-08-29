class_name WeaponResource extends Resource

enum WeaponType {
	EMPTY,
	SHOTGUN,
	SNIPER,
	ASSAULT_RIFLE,
	PISTOL,
	SMG
}


@export_category("Toggles")
@export var infite_ammo: bool = false

@export_category("Weapon Info")
@export var weapon_id: int
@export var weapon_name: String
var weapon_state: WeaponEnums.WeaponState
var weapon_slot: String

@export_category("Weapon Ammo")
@export var max_ammo: int
@export var reserve_ammo: int
@export var current_ammo: int

@export_category("Weapon Stats")
@export var full_auto: bool
@export var fire_rate: float
@export var weapon_type: WeaponType
@export var reload_delay: float

@export_category("Weapon Model")
@export var weapon_model_in_hands: String
@export var weapon_model_in_world: String
@export var weapon_position_x: float
@export var weapon_position_y: float
@export var weapon_position_z: float
@export var weapon_rotation_x: float
@export var weapon_rotation_y: float
@export var weapon_rotation_z: float
