AddCSLuaFile()

SWEP.PrintName 		      = "Piège 3" 
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

SWEP.Category             = "Piège"

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
config.dmg1 = 115
config.dmg2 = 115    -- degat en continue de zone
config.tmp = 15    -- temps du piege
config.tmpAct = 1    -- temps du piege actif
config.zone = 300


--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()


	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

			local own = self:GetOwner()
			local pos = own:GetEyeTrace().HitPos
			local ang = Angle(0,own:GetAngles().y,0)

			local piege_zone = ents.Create( "piege3" ) 
			piege_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			piege_zone:SetPos( pos + ang) 
			piege_zone.Owner = own
			piege_zone:Spawn() 
			piege_zone:Activate() 
			own:DeleteOnRemove( piege_zone )
			piege_zone:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )
			
			config.spawn = true


		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale( 0, 0 )
		self:SetModelScale( config.zone/83.3, 0.7 ) 
		local own = self.Owner
		config.alp = 255
		SafeRemoveEntityDelayed( self, config.tmp )
		timer.Create("alpha"..self:EntIndex(),0.1,25.5,function()
			if IsValid(self) && config.alp > 10 then
				config.alp = config.alp - 10
				self:SetColor( Color( 100,200,100,config.alp ) )
			end
		end)
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_ACID )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
					if IsValid(self) and config.spawn == true then
						local piege_zone = ents.Create( "piege_gaz" ) 
						piege_zone.Owner = own
						piege_zone:SetPos( self:GetPos())
						piege_zone:Spawn() 
						piege_zone:Activate()
						config.spawn = false 
						SafeRemoveEntityDelayed( self,0 )
						self:SetColor( Color( 100,200,100,255 ) )
					end
				end
			end
		end
		self:NextThink( CurTime() + 0.2 ) 
		return true
	end
	scripted_ents.Register( ENT, "piege3" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale( config.zone/83.3, 0 ) 
		self:SetColor( Color( 100,200,100,255 ) )
		SafeRemoveEntityDelayed( self, config.tmpAct )
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
				if IsValid(v) and v != own and (v:IsNPC() or v:IsPlayer()) then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_ACID )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
		self:NextThink( CurTime() + 0.5 ) 
		return true
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "piege_zone_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "piege_gaz" )
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = CurTime()
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
		ent.RenderOverride = function( ent )
			render.SuppressEngineLighting( true ) ent:DrawModel() render.SuppressEngineLighting( false )
		end
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then 
			self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 5 do
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter() + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-200,config.zone)) )
					if particle then  local size = math.Rand( 20,30 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 100 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 3, 4 ) )
						particle:SetStartAlpha( 140 )
						particle:SetEndAlpha( 140 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 3 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 1 )
						particle:SetRollDelta( 2 )
						particle:SetColor( 100, 160, 100 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 1 )
						particle:SetCollide( false )
						particle:SetBounce( 10 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "piege_zone_effect" )
end