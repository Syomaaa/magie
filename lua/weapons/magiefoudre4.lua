SWEP.PrintName 		      = "Foudre 4" 
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

SWEP.Category             = "Foudre"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 35
config.dmg2 = 35  -- dmg de .. à ..

config.tagetZoneSize = 800
config.hitbox = 250
config.hitboxDgt = 300
config.zone = 800

config.cooldownStar = 0.1 --cooldown entre chaque etoiles filante

SWEP.Cooldown = 20

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

--------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	local own = self.Owner

		local fou = ents.Create( "foudre4" )
		fou:SetPos( own:GetPos() )
		fou:SetOwner( own )
		fou:Spawn() 
		fou:Activate() 
		

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

--------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	return true
end


function SWEP:Deploy()
	return true
end


function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "foudre4"
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
			
			ParticleEffectAttach( "[0]_bad_weather", 1, self, 1 )

			SafeRemoveEntityDelayed(self,5)

			local touched = false
		end
	end
	function ENT:Think()
		if not SERVER then return end
		local own = self:GetOwner()

		local pos = self:GetPos() + Vector(math.random(-config.zone/2,config.zone/2),math.random(-config.zone/2,config.zone/2),1000)
		local dir = self:GetAngles():Up()*-60 +VectorRand():GetNormal()*5

		local starfoudre4 = ents.Create( "foudre4_star" )
		starfoudre4:SetPos( pos )
		starfoudre4:SetOwner( own )
		starfoudre4:Spawn() 
		starfoudre4:Activate() 
		own:DeleteOnRemove( starfoudre4 )
		starfoudre4:GetPhysicsObject():SetVelocity( dir )
		starfoudre4:SetPhysicsAttacker( own )
		
	
		self:NextThink(CurTime() + config.cooldownStar)
		return true
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "foudre4" )
end


if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "foudre4_star"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end
			local idx = "foudre4star"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					ParticleEffectAttach( "[14]_lightning_sphere_trail_2", 1, self ,1)
				else
					timer.Remove(idx)
				end
			end)
			local idx = "foudre4star1"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					ParticleEffectAttach( "[0]_thunder_weather", 1, self ,1)
				else
					timer.Remove(idx)
				end
			end)
			SafeRemoveEntityDelayed(self,2)
		end
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think()
		if not SERVER then return end
		
		self:GetPhysicsObject():AddVelocity(self:GetPhysicsObject():GetVelocity():GetNormal() * 3000)
		
		local own = self.Owner
		local target = nil
		local closestDistance = math.huge
	
		for _, entity in pairs(ents.FindInSphere(self:GetPos(), config.tagetZoneSize)) do
			if IsValid(entity) and entity != own and (entity:IsPlayer() or type(entity) == "NextBot") then
				local distance = self:GetPos():Distance(entity:GetPos())
				if distance < closestDistance then
					closestDistance = distance
					target = entity
				end
			end
		end
	
		if target then
			local direction = (target:GetPos() + Vector(0,0,30) - self:GetPos()):GetNormalized()
			self:GetPhysicsObject():SetVelocity(direction * 2000)
		end

		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or type( v ) == "NextBot") then
				SafeRemoveEntityDelayed( self, 0 )
			end
		end
	
		self:NextThink(CurTime())
		return true
	end
	
	function ENT:OnRemove()
		if SERVER then
			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitboxDgt)) do
                if IsValid(v) and v != own and (v:IsPlayer() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end  
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "foudre4_star" )
end