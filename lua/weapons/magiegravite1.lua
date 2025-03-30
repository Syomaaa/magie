AddCSLuaFile()

SWEP.PrintName 		      = "Gravité 1" 
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

SWEP.Category             = "Gravité"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 0.3

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0

SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 60
config.dmg2 = 60
config.zone = 200
config.push = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

game.AddParticles( "particles/fear_explosion.pcf" )
PrecacheParticleSystem( "fear_explosion" )

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()
		local ang = Angle(0, own:EyeAngles().Yaw, 0)
		local pos = own:GetShootPos() + ang:Forward() * 70,10
		local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*50

		local bomb = ents.Create( "controle_nade" )
		bomb:SetPos( pos )
		bomb:SetAngles( ang ) bomb:SetOwner( own )
		bomb:Spawn() bomb:Activate() own:DeleteOnRemove( bomb )
		bomb:GetPhysicsObject():SetVelocity( dir )
		bomb:SetPhysicsAttacker( own )

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "controle_nade"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props_phx/misc/smallcannonball.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetTrigger( true )
		self:SetMaterial( "models/props_combine/com_shield001a" )
		self:GetPhysicsObject():SetMaterial( "glass" )
		self:GetPhysicsObject():SetMass( 2000 )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_WAS_THROWN )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
		self:UseTriggerBounds( self:OBBMins(), self:OBBMaxs() ) self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:ControlBreak( ppp )
		if self.XDEBZ_Hit or !isvector( ppp ) then return end local own = self.Owner  self.XDEBZ_Hit = true
		ParticleEffect("fear_explosion", self:GetPos(), self:GetAngles()) 
		if SERVER then
			local physExplo = ents.Create( "env_physexplosion" )
			physExplo:SetPos( self:GetPos() )
			physExplo:SetKeyValue( "magnitude", config.push )
			physExplo:SetKeyValue( "radius", config.zone)
			physExplo:SetKeyValue( "spawnflags", "2" )
			physExplo:Spawn()
			physExplo:Fire( "Explode", "", 0 )
		end
		self:EmitSound( "ambient/levels/labs/electric_explosion4.wav" , 100, 100,0.2)
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
			end
		end  
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.2 ) 
		self:SetRenderMode( RENDERMODE_NONE )
	end
	function ENT:PhysicsCollide( data, phys )
		if self.XDEBZ_Hit then return end  local own = self.Owner
		if IsValid( data.HitEntity ) and ( data.HitEntity:GetClass() == self:GetClass() or ( IsValid( own ) and own == data.HitEntity ) or data.HitEntity.XDEBZ_Gre ) then return end
		self:ControlBreak( data.HitPos + data.HitNormal*5 )
	end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "controle_nade_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "controle_nade" )
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
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() )
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
						particle2:SetColor( 200, 200, 200 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter() )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.4 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 3 )
						particle2:SetEndSize( 3 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 50, 50, 50 )
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
	effects.Register( EFFECT, "controle_nade_eff" )
end