AddCSLuaFile()

SWEP.PrintName = "Spirit 1"
SWEP.Category = "Spirit"
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

SWEP.HitDistance = 100

SWEP.Cooldown = 0.2
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0


function SWEP:Initialize()
	self:SetHoldType("magic")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Int", 2, "Combo")
end

function SWEP:PrimaryAttack(right)
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then
		if !SERVER then return end

		local shot = ents.Create("shotparticlesept")
		shot:SetPos(self.Owner:GetPos() + Vector(0,0,50))
		-- shot:SetPos(self.Owner:GetPos())
		shot:SetOwner(self.Owner)
		shot:SetAngles(self.Owner:GetAngles())
		shot:Spawn()
		shot:GetPhysicsObject():EnableMotion(true)

		local phys = shot:GetPhysicsObject()
		phys:EnableGravity(false)

		phys:SetVelocity(shot:GetForward() * 3000)

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as ".. self.Cooldown .."s de cooldown !")
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Holster()
	self:SetNextMeleeAttack(0)
	return true
end
