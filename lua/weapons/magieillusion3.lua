AddCSLuaFile()

SWEP.PrintName 		      = "Illusion 3" 
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

SWEP.Category             = "Illusion"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 20

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 35
config.dmg2 = 35    -- degat en continue de zone
config.tmp = 5    -- temps de la zone
config.zone = 12

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()
		local pos = own:GetPos()
		local ang = Angle(0,own:GetAngles().y,0):Forward()


		local illusion2 = ents.Create( "illusion2" ) 
		illusion2:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
		illusion2:SetPos( pos + ang) 
		illusion2.Owner = own
		illusion2:Spawn() 
		illusion2:Activate() 
		own:DeleteOnRemove( illusion2 )
		illusion2:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )

		timer.Simple(config.tmp-1, function()
			if IsValid(illusion2) then
				illusion2:SetModelScale( 1, 1 )
			end
		end)

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
	ENT.PrintName = "illusion"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2.mdl" )
		self:SetMaterial("models/shiny")
		self:SetSolid( SOLID_NONE ) self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,255,255,100 ) )
		self:SetModelScale( config.zone, 0.7 ) local own = self.Owner
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think()
		if !CLIENT then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone*43)) do
				if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					v:AddEFlags("-2147483648" )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)
					v:RemoveEFlags("-2147483648" )
					v:SetEyeAngles( Angle(math.random(0,10),math.random(0,360),0) )
					v:EmitSound( "npc/headcrab/attack1.wav",65 )
				elseif IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
		self:NextThink( CurTime() + 0.3 )
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
				util.Effect( "illusion2_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "illusion2" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-600,600),math.random(-600,600),math.random(-400,600)) )
					if particle2 then  local size = math.Rand( 3, 6 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.3 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-600,600),math.random(-600,600),math.random(-400,600)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.2, 0.4) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 3 )
						particle2:SetEndSize( 3 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, 50 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=0, 1 do
					local particle2 = self.Emitter:Add( "carte1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-600,600),math.random(-600,600),math.random(-400,600)) )
					if particle2 then  local size = math.Rand( 4, 6 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.4, 0.8 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=0, 1 do
					local particle2 = self.Emitter:Add( "carte2.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-600,600),math.random(-600,600),math.random(-400,600)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.4, 0.8) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 5 )
						particle2:SetEndSize( 5 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, 50 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "illusion2_effect" )
end