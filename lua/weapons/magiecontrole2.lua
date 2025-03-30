AddCSLuaFile()

SWEP.PrintName 		      = "Contrôle 2" 
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

SWEP.Category             = "Contrôle"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.tmp = 5    -- temps pour l'attaque 
config.zone = 600

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self.Owner

		if SERVER then
			local base = ents.Create( "control_zone" )
			base:SetPos( own:GetPos() ) 
			base:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
			base:SetOwner( own ) 
			base:Spawn() 
			base:Activate() 
			base:EmitSound("ambient/levels/labs/electric_explosion5.wav", 80, math.Rand(30,60), 0.7)

			timer.Simple(config.tmp,function()
				config.switch = true
			end)
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
	return false
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "control_zone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2.mdl" )
		self:SetMaterial("models/wireframe")
		self.nextAtk = 0
		self.go = false
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetParent(self.Owner)
		self:SetModelScale(config.zone/40,0.5)
		self:SetColor(Color(10,10,10,30))
		self:GetPhysicsObject():EnableGravity( false )
		if self.Owner:Alive() then
			self.Owner:GodEnable()
		end

		local idx = "controleEff"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "[0]_fog_ambient", 1, self, 1 )
				end
			end)

		SafeRemoveEntityDelayed(self,config.tmp)
	end
	function ENT:Think() if !SERVER or !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() then
		if SERVER then self:Remove() end return end
		local own = self.Owner

		if !IsValid(zone) then
			zone = ents.Create("prop_dynamic")
			zone:SetModel( "models/hunter/misc/shell2x2.mdl" )
			zone:SetMaterial( "models/wireframe" )
			zone:SetSolid( SOLID_NONE )  
			zone:SetMoveType( MOVETYPE_NONE )
			zone:SetRenderMode( RENDERMODE_TRANSCOLOR )
			zone:SetPos(self:GetPos())
			zone:SetParent(self)
			zone:DrawShadow( false )
			zone:SetModelScale(0,0)
			zone:SetColor(Color(10,10,10,30))
			zone:SetModelScale(config.zone/40,0.5)
			SafeRemoveEntityDelayed( zone, 0.5)
		end
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if self.Owner:Alive() && SERVER then
			self.Owner:GodDisable()
		end
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			
		end
	end
	scripted_ents.Register( ENT, "control_zone" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "metal_zone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2.mdl" )
		self:SetMaterial("models/wireframe")
		self.nextAtk = 0
		self.go = false
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetParent(self.Owner)
		self:SetModelScale(config.zone/40,0.5)
		self:SetColor(Color(10,10,10,30))
		self:GetPhysicsObject():EnableGravity( false )
		if self.Owner:Alive() then
			self.Owner:GodEnable()
		end

		local idx = "metalEff"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "metal_shield", 1, self, 1 )
				end
			end)

		SafeRemoveEntityDelayed(self,config.tmp)
	end
	function ENT:Think() if !SERVER or !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() then
		if SERVER then self:Remove() end return end
		local own = self.Owner

		if !IsValid(zone) then
			zone = ents.Create("prop_dynamic")
			zone:SetModel( "models/hunter/misc/shell2x2.mdl" )
			zone:SetMaterial( "models/wireframe" )
			zone:SetSolid( SOLID_NONE )  
			zone:SetMoveType( MOVETYPE_NONE )
			zone:SetRenderMode( RENDERMODE_TRANSCOLOR )
			zone:SetPos(self:GetPos())
			zone:SetParent(self)
			zone:DrawShadow( false )
			zone:SetModelScale(0,0)
			zone:SetColor(Color(10,10,10,30))
			zone:SetModelScale(config.zone/40,0.5)
			SafeRemoveEntityDelayed( zone, 0.5)
		end
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if self.Owner:Alive() && SERVER then
			self.Owner:GodDisable()
		end
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			
		end
	end
	scripted_ents.Register( ENT, "metal_zone" )
end
