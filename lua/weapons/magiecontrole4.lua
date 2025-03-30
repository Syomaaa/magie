AddCSLuaFile()

SWEP.PrintName 		      = "Contrôle 4" 
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

SWEP.Cooldown = 20 -- seulement si il a mis des degats : jete la cible au sol
SWEP.next = 0


SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.zone = 300
config.dmg1 = 50
config.dmg2 = 50
config.dist = 15000    -- distance du grab

config.dgtCont1 = 50
config.dgtCont2 = 50

config.start = 0

config.tmp = 1.5

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
	self:GetVar( "distance", NULL )
	self:GetVar( "grabbedEnt", NULL )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
	
	return true
end

function SWEP:Think() if !SERVER or !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() then
	if SERVER then self:Remove() end return end

	local own = self.Owner
	local distance = self:GetVar( "distance", NULL )
	local grabbedEnt = self:GetVar( "grabbedEnt", NULL )
	local EyeTrace = own:GetEyeTrace()
	local max = 200

	if( grabbedEnt != nil and distance != NULL) then
		if( grabbedEnt:IsValid() ) then

			if grabbedEnt:IsPlayer() then
				local weapon = grabbedEnt:GetWeapon("keys")
				if IsValid(weapon) then
					grabbedEnt:SelectWeapon(weapon)
				end
			end

			if !IsValid(self.base) then
				self.next = CurTime() + self.Cooldown
				self:SetVar( "grabbedEnt", nil )
			end		
			
			local EyeDir = ( EyeTrace.HitPos - own:GetShootPos() )
			EyeDir:Normalize()


			grabbedEnt:SetVelocity( ( own:GetShootPos() + EyeDir * distance - Vector( 0, 0, grabbedEnt:GetModelRadius() / 2 ) - grabbedEnt:GetPos() ) * 10 - grabbedEnt:GetVelocity() )
		

			local tr = util.TraceHull( {
				start = grabbedEnt:GetPos(),
				endpos = grabbedEnt:GetPos() + grabbedEnt:GetVelocity() / 40,
				filter = grabbedEnt,
				mins = grabbedEnt:OBBMins(),
				maxs = grabbedEnt:OBBMaxs()
			} )
				
			if config.start < CurTime() then
				if( tr.HitWorld ) then
					for k,v in pairs(ents.FindInSphere(self:GetPos() ,1000)) do
						if IsValid(v) and IsValid(self) and v != own and (v:IsPlayer() or v:IsNPC()) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType( DMG_GENERIC  )
							dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
							dmginfo:SetDamagePosition( self:GetPos()  )
							dmginfo:SetAttacker( own )
							dmginfo:SetInflictor( own )
							v:TakeDamageInfo(dmginfo)
						end
					end
					self:SetVar( "grabbedEnt", nil )	
					config.start = CurTime() + 1
					self.next = CurTime() + self.Cooldown
					if IsValid(self.base) then
						self.base:SetModelScale(0,0.3)
						SafeRemoveEntityDelayed(self.base,0.3)
					end
				end
			end
		end
	end

	if self.next < CurTime() then
		if( own:KeyDown( IN_ATTACK ) && own:GetPos():Distance( EyeTrace.HitPos ) < config.dist && EyeTrace.Entity:IsValid() ) then
			if( EyeTrace.Entity:IsNPC() || EyeTrace.Entity:IsPlayer() ) then
				
				self:SetVar( "grabbedEnt", EyeTrace.Entity )
				grabbedEnt = self:GetVar( "grabbedEnt", NULL )
				
				self:SetVar( "distance", math.max( max, own:GetPos():Distance( grabbedEnt:GetPos() ) ) )

				if !IsValid(self.base) then
					self.base = ents.Create( "control" )
					self.base:SetPos( grabbedEnt:GetPos() + Vector(0,0,50) ) 
					self.base:SetParent(grabbedEnt)
					self.base:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
					self.base:SetOwner( own ) 
					self.base:Spawn() 
					self.base:Activate() 
					self.base:EmitSound("player/footsteps/grass4.wav", 100, math.Rand(20,40), 0.7)
				end
			end
		end
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end

	if( own:KeyReleased( IN_ATTACK ) and self:GetVar( "grabbedEnt") != nil ) then
		self:SetVar( "grabbedEnt", nil )
		self.next = CurTime() + self.Cooldown
		if IsValid(self.base) then
			self.base:SetModelScale(0,0.3)
			SafeRemoveEntityDelayed(self.base,0.3)
		end
	end

	self:NextThink( CurTime() ) return true
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
	ENT.PrintName = "control"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOT
	ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2.mdl" )
		self:SetMaterial("models/wireframe")
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetModelScale(config.zone/40,0.3)
		self:SetColor(Color(10,10,10,20))
		config.start = CurTime() + 1
		SafeRemoveEntityDelayed(self,config.tmp)
	end
	function ENT:Think()
		if !CLIENT then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),1000)) do
				if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dgtCont1,config.dgtCont2) )
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
	function ENT:OnRemove()
		
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "control_eff", ef )
			end
		end
	end
	scripted_ents.Register( ENT, "control" )
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
			self.Emitter:SetPos( ent:GetPos() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.05
				for i=0,10 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:GetPos()  + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200)))
					if particle2 then  local size = math.Rand( 10, 15 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.4, 1 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor(30, 30, 30 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=0, 10 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:GetPos() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200)) )
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
						particle2:SetColor(  30, 30, 30  )
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
	effects.Register( EFFECT, "control_eff" )
end