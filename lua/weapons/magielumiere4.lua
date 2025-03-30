AddCSLuaFile()

SWEP.PrintName 		      = "Lumière 4" 
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

SWEP.Category             = "Lumière"

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
config.dmg1 = 105
config.dmg2 = 110
config.tmp = 1    -- temps pour l'attaque 

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()


   if(CLIENT) then

	fxEmitter = ParticleEmitter(vector_origin)

	end
   
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	    config.switch = false

		local own = self:GetOwner()

		pluielight = ents.Create( "pluie_light" )
		pluielight:SetPos( own:GetPos() + own:EyeAngles():Forward()*1000 + Vector(0,0,700)) 
		pluielight:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
		pluielight:SetOwner( own ) 
		pluielight:Spawn() 
		pluielight:Activate() 

		timer.Create("lightstorm"..pluielight:EntIndex(), 0.04, 30, function()
			if (IsValid(pluielight) && IsValid(self) && self:GetOwner():Alive() ) then
				local air = pluielight:GetPos() - Vector(math.random(-300,300),math.random(-300,300),0)
				local pluie = ents.Create("sword_light")
				pluie:SetPos(air)
				pluie:SetOwner(self:GetOwner())
				pluie:Activate()
				pluie:Spawn()
			end
		end)

		timer.Simple(config.tmp,function()
			config.switch = true
		end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	return true
end

-------------------------------------------------------------------------------------------------------------

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
	ENT.PrintName = "pluie_light"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/tubes/circle4x4.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		SafeRemoveEntityDelayed(self,config.tmp)
	end
	function ENT:StartTouch( ent ) end
    function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			local ef = EffectData()
			ef:SetEntity( self )
			util.Effect( "pluie_light_eff", ef )
			self:DrawShadow( false )
		end
	end
	scripted_ents.Register( ENT, "pluie_light" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "lameLight"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.Effect = false  ENT.Hit = false  ENT.Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/leitris/broadsword.mdl" )
		self:SetMaterial("models/shiny")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetAngles(Angle(180,math.random(0,360),90))
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableGravity(true);
		self:SetColor( Color(255, 255, 150,150 ) )
		SafeRemoveEntityDelayed( self, 1 )

		local par = ents.Create( "info_particle_system" ) 
		par:SetKeyValue( "effect_name", "[1]_light_flash" )
		par:SetKeyValue( "start_active", "1" )
		par:SetParent(self)
		par:SetPos( self:GetPos() ) 
		par:SetAngles( self:GetAngles() )
		par:Spawn() 
		par:Activate() 

	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.2 )
	end
	function ENT:Think() if !SERVER then return end
		self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*200 ) 

		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then
			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,500)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					self:EmitSound("weapons/fx/nearmiss/bulletLtoR06.wav", 65, math.Rand(30,60), 0.8)
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:AddEFlags("-2147483648" )
					v:TakeDamageInfo(dmginfo)
					v:RemoveEFlags("-2147483648" )
				end
			end  
		end
	end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			self:DrawShadow( false )
		end
	end
	scripted_ents.Register( ENT, "sword_light" )
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
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp+ Vector(math.random(-600,600),math.random(-600,600),0) )
					if particle then  local size = math.Rand( 5, 10 )
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
						particle:SetColor( 255, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 8 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 )
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp + Vector(math.random(-600,600),math.random(-600,600),0))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 3 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 1, 2 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 255, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-600,600),math.random(-600,600),0))
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetAngles( Angle( 90, CurTime() * 10, 0 ) )
					particle:SetDieTime( 0.5 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 255 )
					particle:SetEndSize( 100 )
					particle:SetColor( 255, 255, 200 )
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
				dlight.r = 255
				dlight.g = 255
				dlight.b = 200
				dlight.Brightness = 5
				dlight.Size = 256
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "pluie_light_eff" )
end