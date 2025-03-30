AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local config = {}

SWEP.Cooldown = 11.5
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0
config.dmg1 = 0
config.dmg2 = 0
config.tmp = 1.5     -- temps pour la tempete
config.zone = 300
config.tmpfreeze = 1.5

function SWEP:Initialize()
    local own = self:GetOwner()
    self:SetHoldType("fist")
    self.sprint = false
end

function SWEP:Think()

    local own = self.Owner

    if own:KeyDown( IN_ATTACK2 ) and own:Alive() and !self.sprint then

		own:SetRunSpeed(own:GetRunSpeed()*1.8)
		own:SetWalkSpeed(own:GetWalkSpeed()*1.8)
		own:SetJumpPower(own:GetJumpPower()*1.2)

		self.sprint = true
	end

	if( own:KeyReleased( IN_ATTACK2 )) and self.sprint then
		self.sprint = false
		own:SetRunSpeed( own:GetRunSpeed()/1.8)
		own:SetWalkSpeed(own:GetWalkSpeed()/1.8)
		own:SetJumpPower(own:GetJumpPower()/1.2)
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	
			local own = self:GetOwner()
			local pos = self.Owner:GetEyeTrace().HitPos
			local glace2 = ents.Create( "glace2" )
			glace2:SetOwner( own ) 
			glace2:SetPos( pos )
			glacee2:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
			glace2:Spawn() 
			glace2:Activate()

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:Deploy()
	local own = self.Owner
	self.eff = ents.Create( "sli_effect" ) 
	self.eff:SetPos( own:GetPos() ) 
	self.eff:SetParent(own)
	self.eff:Spawn() 
	self.eff:Activate() 
	own:DeleteOnRemove( self.eff )
end

function SWEP:Holster()
    SafeRemoveEntity(self.eff)
	return true
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "Glace2"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_NONE )
			self:SetMoveType( MOVETYPE_NONE )
			self:SetSolid( SOLID_NONE )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end
			local idx = "glace222222"..self:EntIndex()
			timer.Create(idx,0.2,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "[4]_frozen_dragon", 1, self, 1 )
				else
					timer.Remove(idx)
				end
			end)

			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
                if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)

					if IsValid(v) and v != self.Owner and (v:IsPlayer())  then
						v:SetMoveType(MOVETYPE_NONE)
						v:Freeze(true)
						timer.Simple(config.tmpfreeze,function()
							if IsValid(v) then
								v:SetMoveType(MOVETYPE_WALK)
								v:Freeze(false)
							end
						end)
					end
					if IsValid(v) and v:IsNPC() and v != self.Owner then
						v:SetCondition( 67 )
						timer.Simple(config.tmpfreeze,function()
							if IsValid(v) then
								v:SetCondition( 68 )
							end
						end)
					end
					
				end
			end  

			SafeRemoveEntityDelayed(self,config.tmp)
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "glace2" )
end