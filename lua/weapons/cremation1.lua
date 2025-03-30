AddCSLuaFile()

SWEP.PrintName = "Crémation 1"
SWEP.Category = "Crémation"
SWEP.Author = "CeiLciuZ"
SWEP.Purpose = "Well we sure as hell didn't use guns! We would just wrestle Hunters to the ground with our bare hands! I used to kill ten, twenty a day, just using my fists."

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HitDistance = 48

function SWEP:Initialize()

	self:SetHoldType( "magic" )

end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Int", 2, "Combo" )

end

function SWEP:PrimaryAttack( right )

	self:SetNextPrimaryFire( CurTime() + 0.2 )

	local shot = ents.Create("un")
	shot:SetPos(self.Owner:GetPos() + Vector(0,0,50))
	shot:SetOwner(self.Owner)
	shot:SetAngles(self.Owner:GetAngles())
	shot:Spawn()
	shot:GetPhysicsObject():EnableMotion(true)

	local phys = shot:GetPhysicsObject()
	phys:EnableGravity(false)

	phys:SetVelocity( shot:GetForward() * 3000 )

end

function SWEP:SecondaryAttack()
end

local phys_pushscale = GetConVar( "phys_pushscale" )

function SWEP:OnDrop()

	self:Remove() -- You can't drop fists

end

function SWEP:Holster()

	self:SetNextMeleeAttack( 0 )

	return true

end