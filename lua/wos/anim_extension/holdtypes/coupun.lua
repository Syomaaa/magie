--=====================================================================
/*		My Custom Holdtype
			Created by Ayako( STEAM_0:0:156046020 )*/
local DATA = {}
DATA.Name = "requin"
DATA.HoldType = "wos-requin-naruto"
DATA.BaseHoldType = "normal"
DATA.Translations = {} 

DATA.Translations[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = {
	{ Sequence = "alexis_animation10", Weight = 1 },
}

wOS.AnimExtension:RegisterHoldtype( DATA )
--=====================================================================
