if (SERVER) then
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= false
end

if (CLIENT) then
	SWEP.PrintName		= "Vent 4"
	SWEP.DrawAmmo		= false
	SWEP.DrawCrosshair	= true
	SWEP.ViewModelFOV	= 70
	SWEP.ViewModelFlip	= false
	SWEP.CSMuzzleFlashes	= false
end

/*---------------------------------------------------------
	Main SWEP Setup
---------------------------------------------------------*/
SWEP.Author		= "Brounix"
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true
SWEP.Category		= "Vent"

SWEP.WorldModel		= "models/yuno/epee_yuno.mdl"
SWEP.ViewModel		= ""
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ReloadRate		= 1
SWEP.JumpRefire		= false
SWEP.OldSpin		= 0
SWEP.HoldType		= "g_combo1"


SWEP.Cooldown = 20 --cooldown general pour utiliser une atk spe
SWEP.Cooldown1 = 20 --cooldown bourasque
SWEP.Cooldown2 = 20 --cooldown tornade
SWEP.Cooldown3 = 10 --cooldown seconde attaque


SWEP.ActionDelay = 0.2
SWEP.NextAction = 0

SWEP.CooldownDelay = 0
SWEP.CooldownDelay1 = 0
SWEP.CooldownDelay2 = 0
SWEP.CooldownDelay3 = 0

SWEP.WElements = {
	["ailes"] = { type = "Model", model = "models/yuno/wings_yuno.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(-10, 6, -10), angle = Angle(90, 90, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
	["tete"] = { type = "Model", model = "models/yuno/crawn_yuno.mdl", bone = "ValveBiped.Bip01_Head1", rel = "", pos = Vector(5, -5, 9), angle = Angle(90, 90, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
}

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "magievent4" )
	if (SERVER) then
		self:Setmagievent4( 1 )
	end
end

function SWEP:Initialize()
	self.combo = 11
	self:SetHoldType("g_combo1")
	self.duringattack = false
	self.backtime = 0
	self.duringattacktime = 0
	self.dodgetime = 0
	self.plyindirction = false
	self.DownSlashed = true
	self.downslashingdelay = 0
	self.back = true
	config.canatk = true
end

function SWEP:SecondaryAttack()
	return false
end

