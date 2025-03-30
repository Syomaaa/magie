if (SERVER) then
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= false
end

if (CLIENT) then
	SWEP.PrintName		= "Berserker1"
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
SWEP.Category		= "Berserker"

SWEP.WorldModel		= "models/izuki/uki_commande2/halberd4.mdl"
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

SWEP.ActionDelay = 0.2
SWEP.NextAction = 0

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "epee1" )
	if (SERVER) then
		self:Setepee1( 1 )
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
	return true
end