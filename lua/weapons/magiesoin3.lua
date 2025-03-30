AddCSLuaFile()

SWEP.PrintName 		      = "Soin 3" 
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

SWEP.Category             = "Soin"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 16.5

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.tmp = 1.5     -- temps pour l'attaque 
config.addVie = 70  -- regene
config.zone = 500
config.vitesseRegene = 0.3  --deg + regene toute les .. tmp

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
    if self.Owner:IsOnGround() then
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()
		config.switch = false
		self.Owner:GodEnable()

		if self.MagicLoopSound then 
			self.MagicLoopSound:Stop() 
		end
		

		local heal = ents.Create( "heal_zone" )
		heal:SetPos( own:GetPos() ) 
		heal:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
		heal:SetOwner( own ) 
		heal:Spawn() 
		heal:Activate() 
		heal:EmitSound( "ambient/levels/citadel/field_loop2.wav",75,math.random(40,50))

		timer.Simple(config.tmp, function()
			heal:StopSound( "ambient/levels/citadel/field_loop2.wav" ) 
			config.switch = true
			self.Owner:GodDisable()
		end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	return true
	end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	if config.switch == false then
		return false
	else
		return true
	end
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "Cloud"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  config.NextAtk = 0  ENT.NextHeal = 0
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Gre = 1  ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetColor(Color(60,255,60))
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		self:SetModelScale(0,0)
		self:SetModelScale(config.zone/83.3,0.7)
		SafeRemoveEntityDelayed( self, config.tmp )
		local eff = ents.Create( "heal_zone_small" )
		eff:SetPos( self:GetPos()) 
		eff:Spawn() 
		eff:Activate() 
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			for k, v in pairs( ents.FindInSphere( self:GetPos(), config.zone ) ) do
				if self:GetPos():Distance( v:GetPos() ) < config.zone/5 then 
					if v:IsPlayer() and (v:Health() + config.addVie < v:GetMaxHealth())then
						v:SetHealth(v:Health()+config.addVie)
					elseif v:IsNPC() and (v:Health() + config.addVie < v:GetMaxHealth()) then
						v:SetHealth(v:Health()+config.addVie)
					elseif (v:Health() + config.addVie >= v:GetMaxHealth()) then
						v:SetHealth(v:GetMaxHealth())
					end
				end
			end 	
		end
		self:NextThink( CurTime()+ config.vitesseRegene) 
		return true
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "heal_zone_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "heal_zone" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "Cloud"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  ENT.XDEBZ_Tars = {}  ENT.XDEBZ_NextAtk = 0
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/jackjack/props/circle1.mdl" )
		self:SetMaterial( "Models/effects/comball_tape" )
		self:SetColor(Color(100,255,100,20))
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		self:SetModelScale(0,0)
		self:SetModelScale(1.2,0.7)
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "heal_zone_small" )
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = CurTime()
		self.Emitte2 = ParticleEmitter( self.Owner:WorldSpaceCenter(), true )
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )  self.NextLight = CurTime()
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() ) self.Emitte2:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone,config.zone))
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( config.zone/20,config.zone/15 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 1.5 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 150, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone,config.zone))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 3 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 5, 10 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 150, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone,-config.zone+100)))
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
					particle:SetDieTime( 1 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 200 )
					particle:SetEndSize( 300 )
					particle:SetColor( 150, 255, 200 )
					particle:SetGravity( Vector( 0, 0, 0 ) )
					particle:SetAirResistance( 10 )
					particle:SetCollide( false )
					particle:SetBounce( 0 )
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render() local own = self.Owner
		if IsValid( own ) and self.NextLight < CurTime() then self.NextLight = CurTime() + 0.01
			local dlight = DynamicLight( own:EntIndex() ) if dlight then
				dlight.Pos = own:WorldSpaceCenter()
				dlight.r = 150
				dlight.g = 255
				dlight.b = 200
				dlight.Brightness = 5
				dlight.Size = config.zone*3
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "heal_zone_eff" )
end