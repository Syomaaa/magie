AddCSLuaFile()

SWEP.PrintName 		      = "Temps 1" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 85
SWEP.ViewModel      = ""
SWEP.WorldModel   	= ""
SWEP.AutoSwitchTo 	      = false 
SWEP.AutoSwitchFrom       = true 
SWEP.DrawAmmo             = false 
SWEP.Base                 = "weapon_base" 
SWEP.Slot 			      = 2
SWEP.SlotPos              = 1 
SWEP.HoldType             = "magic"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Temps"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 25
config.dmg2 = 30 -- dmg de .. à ..

config.zone = 150
config.hitbox = 100

SWEP.Cooldown = 0.2
SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()
		local ang = Angle(0, own:EyeAngles().Yaw, 0)
		local pos = self.Owner:GetShootPos() + self.Owner:EyeAngles():Right() * 40 * -0.35
		local dir = own:EyeAngles():Forward() * 3000 + VectorRand():GetNormal() * 50

		local temps = ents.Create("temps")
		if IsValid(temps) then
			temps:SetPos(pos)
			temps:SetAngles(ang)
			temps:SetOwner(own)
			temps:Spawn()
			temps:Activate()
			own:DeleteOnRemove(temps)
			local phys = temps:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(dir * 10)
			end
			temps:SetPhysicsAttacker(own)
		end

		pos = self.Owner:GetShootPos() + self.Owner:EyeAngles():Right() * 40 * 0.35
		local temps2 = ents.Create("temps")
		if IsValid(temps2) then
			temps2:SetPos(pos)
			temps2:SetAngles(ang)
			temps2:SetOwner(own)
			temps2:Spawn()
			temps2:Activate()
			own:DeleteOnRemove(temps2)
			local phys = temps2:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(dir * 10)
			end
			temps2:SetPhysicsAttacker(own)
			temps2:EmitSound("weapons/fx/nearmiss/bulletLtoR14.wav")
		end

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown .. "s de cooldown !")
	end
	return true
end

function SWEP:SecondaryAttack()
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "temps"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH

	function ENT:Initialize()
		local own = self:GetOwner()
		self:DrawShadow(false)
		if !SERVER then return end
		self:SetModel("models/rumiadammaku/bluesphere_2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetTrigger(true)
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:SetColor(Color(255, 255, 255, 150))
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableGravity(false)
			phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
		end
		SafeRemoveEntityDelayed(self, 2)
	end

	function ENT:PhysicsCollide(data, phys)
		self:GetPhysicsObject():EnableMotion(false)
		SafeRemoveEntityDelayed(self, 0)
	end

	function ENT:Think()
		if !SERVER then return end
		if !self.XDEBZ_Hit then
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:AddVelocity(phys:GetVelocity():GetNormal() * 2000)
			end
		end

		local own = self.Owner

		for k, v in pairs(ents.FindInSphere(self:GetPos(), config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type(v) == "NextBot") then
				self:GetPhysicsObject():EnableMotion(false)
				SafeRemoveEntityDelayed(self, 0)
			end
		end
		self:NextThink(CurTime())
		return true
	end

	function ENT:OnRemove()
	if SERVER then
		local own = self.Owner
		for k, v in pairs(ents.FindInSphere(self:GetPos(), config.zone)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type(v) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType(DMG_GENERIC)
				dmginfo:SetDamage(math.random(config.dmg1, config.dmg2))
				dmginfo:SetDamagePosition(self:GetPos())
				dmginfo:SetAttacker(own)
				dmginfo:SetInflictor(self)
				v:TakeDamageInfo(dmginfo)

				local direction = (v:GetPos() - own:GetPos()):GetNormalized()
				local pushForce = 300
				local velocity = direction * pushForce
				v:SetVelocity(velocity)
			end
		end
	end
end

	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.XDEBZ_Effect then
				self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity(self)
				util.Effect("temps_effect", ef)
				self:DrawShadow(false)
			end
		end
	end
	scripted_ents.Register(ENT, "temps")
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init(data)
		local ent = data:GetEntity()
		if !IsValid(ent) then return end
		self.Owner = ent
		self.Emitter = ParticleEmitter(self.Owner:WorldSpaceCenter())
		self.NextEmit = CurTime()
		self:SetRenderBoundsWS(ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins())
		ent.RenderOverride = function(ent)
			render.SuppressEngineLighting(true)
			ent:DrawModel()
			render.SuppressEngineLighting(false)
		end
	end

	function EFFECT:Think()
		local ent = self.Owner
		if IsValid(ent) then
			self:SetRenderBoundsWS(ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins())
			self.Emitter:SetPos(ent:WorldSpaceCenter())
			if self.NextEmit < CurTime() then
				self.NextEmit = CurTime() + 0.03
				for i = 1, 3 do
					local particle2 = self.Emitter:Add("swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)))
					if particle2 then
						local size = math.Rand(3, 6)
						particle2:SetVelocity(VectorRand(-1, 1):GetNormal() * 50)
						particle2:SetLifeTime(0)
						particle2:SetDieTime(math.Rand(0.1, 0.3))
						particle2:SetStartAlpha(255)
						particle2:SetEndAlpha(0)
						particle2:SetStartSize(size)
						particle2:SetEndSize(size * 4)
						particle2:SetAngles(Angle(0, 0, 0))
						particle2:SetRoll(180)
						particle2:SetRollDelta(6)
						particle2:SetColor(100, 150, 255)
						particle2:SetGravity(Vector(0, 0, 25))
						particle2:SetAirResistance(10)
						particle2:SetCollide(false)
						particle2:SetBounce(0)
					end
				end
				for i = 1, 3 do
					local particle2 = self.Emitter:Add("swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter() + Vector(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20)))
					if particle2 then
						particle2:SetVelocity(VectorRand(-1, 1):GetNormal() * 30)
						particle2:SetLifeTime(0)
						particle2:SetDieTime(math.Rand(0.2, 0.4))
						particle2:SetStartAlpha(255)
						particle2:SetEndAlpha(0)
						particle2:SetStartSize(3)
						particle2:SetEndSize(3)
						particle2:SetAngles(Angle(0, 0, 0))
						particle2:SetRoll(180)
						particle2:SetRollDelta(6)
						particle2:SetColor(100, 150, 255)
						particle2:SetGravity(Vector(0, 0, 50))
						particle2:SetAirResistance(10)
						particle2:SetCollide(false)
						particle2:SetBounce(0)
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end
		return false
	end

	function EFFECT:Render()
	end

	effects.Register(EFFECT, "temps_effect")
end