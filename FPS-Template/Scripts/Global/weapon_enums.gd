class_name WeaponEnums extends Node

#these enums exist in two places, here and on the weapon_res, so must be updated there too
enum WeaponType {
	EMPTY,
	SHOTGUN,
	SNIPER,
	ASSAULT_RIFLE,
	PISTOL,
	SMG
}


enum WeaponState {
	IN_WOLRD,
	IN_HAND,
	IN_INVENTORY
}
