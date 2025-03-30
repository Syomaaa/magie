AddCSLuaFile()

SWEP.PrintName 		      = "Bestial 2" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 54
SWEP.UseHands = true
SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
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

SWEP.Category             = "Bestial"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 13

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "fist" )
	self.sprint = false
end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Int", 2, "Combo" )

end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )

end

------------------------------------------------------------------------------------------------------------

AddCSLuaFile("poke_ghosttype.lua")
SWEP.Base = "poke_ghosttype"
--[[------------------------------
Configuration
--------------------------------]]
local config = {}
config.ActionDelay = 0.2 -- Time in between each action.
--[[-------------------------------------------------------------------------
Mirror Coat
---------------------------------------------------------------------------]]
config.MirrorCoatDelay = 2
config.MirrorCoatDuration = 5 -- Time until the beam shoots.
config.MirrorCoatDamageMulti = 2 -- Multiply the damage by how much?
config.MirrorCoatDamageCap = 200 -- Max damage cap? Set to 0 for no cap.

config.MirrorCoatSound = "weapons/physcannon/physcannon_claws_close.wav"
config.MirrorCoatShootSound = "npc/strider/fire.wav"

config.MirrorCoatBeamSize = 30 -- Size of physical beam. ( not visual )
config.MirrorCoatBeamRange = 4567
config.MirrorCoatBeamFX = "fx_poke_mirrorcoatbeam"
--[[-------------------------------------------------------------------------
Messages ( debug )
---------------------------------------------------------------------------]]
config.PrintMessages = false
config.MirrorCoatMessage = "Mirror Coat!"

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack() 
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	if SERVER then self:MirrorCoatActivate() end
	self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:SecondaryAttack() 
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Deploy()

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
	vm:SetPlaybackRate( speed )

	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:UpdateNextIdle()

	if ( SERVER ) then
		self:SetCombo( 0 )
	end

	return true

end

function SWEP:Think()

	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()

	if ( idletime > 0 && CurTime() > idletime ) then

		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )

		self:UpdateNextIdle()

	end

	local meleetime = self:GetNextMeleeAttack()

	if ( meleetime > 0 && CurTime() > meleetime ) then


		self:SetNextMeleeAttack( 0 )

	end

	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then

		self:SetCombo( 0 )

	end

    local own = self.Owner

	if own:KeyDown( IN_ATTACK2 ) and own:Alive() and !self.sprint then
		if !self.sprint then
			timer.Remove("speed"..own:EntIndex())
		end
		own:SetRunSpeed( own:GetRunSpeed()*2)
		own:SetWalkSpeed(own:GetWalkSpeed()*2)
		own:SetJumpPower(own:GetJumpPower()*1.3)
		self.sprint = true
	end

	if( own:KeyReleased( IN_ATTACK2 )) and self.sprint then
		self.sprint = false
		own:SetRunSpeed( own:GetRunSpeed()/2)
		own:SetWalkSpeed(own:GetWalkSpeed()/2)
		own:SetJumpPower(own:GetJumpPower()/1.3)
	end

end


function SWEP:Deploy()
	if !SERVER then return end
	local own = self.Owner
	self.powerup = ents.Create( "powerup" ) 
	self.powerup:SetPos( own:GetPos() ) 
	self.powerup:SetParent(own)
	self.powerup:Spawn() 
	self.powerup:Activate() 
	own:DeleteOnRemove( self.powerup )
end

function SWEP:Holster()
	
	SafeRemoveEntity( self.powerup)
	return true
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "luneciel"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/planets/luna_small.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self.Light = ents.Create( "light_dynamic" )
		self.Light:SetPos( self:WorldSpaceCenter() ) 
		self.Light:SetAngles( self:GetAngles() ) 
		self.Light:SetKeyValue( "_light", "255 220 120 255" )
		self.Light:SetKeyValue( "brightness", "1" ) 
		self.Light:SetOwner( self ) 
		self.Light:SetParent( self )
		self.Light:SetKeyValue( "distance", "100" )
		self.Light:Spawn() 
		self.Light:Activate() 
		self:DeleteOnRemove( self.Light )
		self.Light:Fire( "TurnOn" )
	end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "powerup_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "powerup" )
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
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.02
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 20 ) + Vector(math.random(-1,1),math.random(-1,1),math.random(0,20))
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 2, 4 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.5, 1.5 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 255, 230, 120 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 20 ) + Vector(math.random(-1,1),math.random(-1,1),math.random(0,20))
				local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetDieTime( math.Rand( 1, 3 ) )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( math.Rand( 1, 6 ) )
					particle:SetEndSize( 0 )
					particle:SetAngles( Angle( 0, 0, 0 ) )
					particle:SetRoll( 180 )
					particle:SetRollDelta( 12 )
					particle:SetColor( 255, 230, 120 )
					particle:SetGravity( Vector( 0, 0, 100 ) )
					particle:SetAirResistance( 10 )
					particle:SetCollide( false )
					particle:SetBounce( 0 )
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()
	end
	effects.Register( EFFECT, "powerup_beteeffect" )
end