SWEP.PrintName 		      = "Foudre Noir 3" 
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
SWEP.HoldType             = "normal"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Foudre Noir"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 350
config.dmg2 = 300 -- dmg de .. à ..

config.tagetZoneSize = 1000
config.hitbox = 200
config.zone = 300

config.hitbox1 = 250
config.zone1 = 350

SWEP.Cooldown = 15

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

		if SERVER then

			local own = self:GetOwner()
			local ang = Angle(own:EyeAngles().x, own:EyeAngles().y, math.random(20,160))
			local pos = own:GetShootPos() - Vector(0,0,5) + ang:Forward() * 10,10
			local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

			local foudrenoir3 = ents.Create( "foudrenoir3" )
			foudrenoir3:SetPos( pos )
			foudrenoir3:SetAngles( ang ) 
			foudrenoir3:SetOwner( own )
			foudrenoir3:Spawn() 
			foudrenoir3:Activate() 
			own:DeleteOnRemove( foudrenoir3 )
			foudrenoir3:GetPhysicsObject():SetVelocity( dir )
			foudrenoir3:SetPhysicsAttacker( own )
			foudrenoir3:EmitSound("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav", 60, 160, 0.6)

		end

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		if SERVER then

			local own = self:GetOwner()
			local ang = Angle(own:EyeAngles().x, own:EyeAngles().y, math.random(20,160))
			local pos = own:GetShootPos() - Vector(0,0,5) + ang:Forward() * 10,10
			local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

			local foudrenoir3fixe = ents.Create( "foudrenoir3fixe" )
			foudrenoir3fixe:SetPos( pos )
			foudrenoir3fixe:SetAngles( ang ) 
			foudrenoir3fixe:SetOwner( own )
			foudrenoir3fixe:Spawn() 
			foudrenoir3fixe:Activate() 
			own:DeleteOnRemove( foudrenoir3fixe )
			foudrenoir3fixe:GetPhysicsObject():SetVelocity( dir )
			foudrenoir3fixe:SetPhysicsAttacker( own )

		end

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "foudrenoir3"
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
			local idx = "fffouddrenoirrr3"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					ParticleEffectAttach( "[5]_darklightning_projectile", 1, self ,1)
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
		
		self:GetPhysicsObject():AddVelocity(self:GetPhysicsObject():GetVelocity():GetNormal() * 2000)
		
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
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end
	
		self:NextThink(CurTime())
		return true
	end
	
	function ENT:OnRemove()
		if SERVER then
			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
                if IsValid(v) and v != own and (v:IsPlayer() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg2,config.dmg2) )
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
	scripted_ents.Register( ENT, "foudrenoir3" )
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "foudrenoir3fixe"
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
			local idx = "foudrenoir3fixe"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					ParticleEffectAttach( "[5]_darklightning_projectile", 1, self ,1)
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
		
		self:GetPhysicsObject():AddVelocity(self:GetPhysicsObject():GetVelocity():GetNormal() * 2000)
		
		local own = self.Owner
		
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox1)) do
			if IsValid(v) and v != own and (v:IsPlayer() or type( v ) == "NextBot") then
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end
	
		self:NextThink(CurTime())
		return true
	end
	
	function ENT:OnRemove()
		if SERVER then
			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone1)) do
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
	scripted_ents.Register( ENT, "foudrenoir3fixe" )
end