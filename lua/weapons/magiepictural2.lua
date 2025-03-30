AddCSLuaFile()

SWEP.PrintName 		      = "Picturale 2" 
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

SWEP.Category             = "Picturale"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 50
config.dmg2 = 50  -- dmg de .. à ..
config.tmp = 1 -- temps de l'attaque

config.switch = true


--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

function SWEP:Think()
end
-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		if SERVER then

			config.switch = false

			local own = self:GetOwner()
			local pos = own:GetPos()

			local own = self:GetOwner()
			local pos = self.Owner:GetEyeTrace().HitPos
			local pictZone = ents.Create( "pictu_zone" )
			pictZone:SetOwner( own ) 
			pictZone:SetPos( pos )
			pictZone:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
			pictZone:Spawn() 
			pictZone:Activate()

			pictZone:EmitSound("physics/cardboard/cardboard_box_impact_bullet3.wav", 65, math.Rand(140,160), 0.8)

			
			timer.Simple(0.1,function()
				config.switch = true
			end)

		end

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
	ENT.PrintName = "pictu2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/plates/plate32x32.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think()
		if !SERVER then return end self:NextThink( CurTime() + 0.2 ) 
		local own = self.Owner
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,300)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
				dmginfo:SetDamagePosition( self:GetPos() )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
			end
		end
		return true
	end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "pictu_zone_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "pictu_zone" )
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end  self.Owner = ent
		local mag = math.Round( data:GetMagnitude() )
		self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = 0
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs()*100, ent:GetPos() + ent:OBBMins()*100 )
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 10 do
					local particle = self.Emitter:Add( "paint.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 30, 50 ))
					if particle then local size = math.Rand( 3, 15 )
						particle:SetVelocity( Vector(math.Rand(-10,10), math.Rand(-10,10), math.Rand(1,20)) * 30)
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 2 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 155 )
						particle:SetStartSize( size )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 2 )
						particle:SetColor( math.random(20,255), math.random(20,255), math.random(20,255) )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 10 do
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter()+ Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 30, 50 ))
					if particle then local size = math.Rand( 3, 15 )
						particle:SetVelocity( Vector(math.Rand(-10,10), math.Rand(-10,10), math.Rand(1,20)) * 30)
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 2 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 155 )
						particle:SetStartSize( size )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 2 )
						particle:SetColor( math.random(20,255), math.random(20,255), math.random(20,255) )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "pictu_zone_effect" )
end

