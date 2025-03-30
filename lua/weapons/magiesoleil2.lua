AddCSLuaFile()

SWEP.PrintName 		      = "Soleil 2" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 54
SWEP.UseHands = true
SWEP.ViewModel = ""
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

SWEP.Category             = "Soleil"

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

config.zone = 300

config.dmgzone1 = 30
config.dmgzone2 = 35

config.tmp = 1.5 -- temps de la canicule

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
			
	        
	        config.switch = false

			local own = self:GetOwner()
			local pos = self.Owner:GetEyeTrace().HitPos
			local ang = ( Angle( 0, own:GetAngles().yaw, 0 ) ) 

			local dragTorn = ents.Create("env_smokestack")
			dragTorn:SetKeyValue("smokematerial", "swarm/particles/particle_smokegrenade1.vmt")
			dragTorn:SetKeyValue("rendercolor", "180, 100, 50" )
			dragTorn:SetKeyValue("targetname","dragTorn")
			dragTorn:SetKeyValue("basespread","400")
			dragTorn:SetKeyValue("spreadspeed","300")
			dragTorn:SetKeyValue("speed","300")
			dragTorn:SetKeyValue("startsize","60")
			dragTorn:SetKeyValue("endzide","0")
			dragTorn:SetKeyValue("rate","500")
			dragTorn:SetKeyValue("jetlength","1000")
			dragTorn:SetKeyValue("twist","100")
			dragTorn:SetPos(self.Owner:GetEyeTrace().HitPos)
			dragTorn:SetParent(own)
			dragTorn:Spawn()
			dragTorn:Fire("turnon","",0)
			dragTorn:Fire("Kill","",config.tmp-0.5)

			local canicule = ents.Create("canicule")
			canicule:SetPos(self.Owner:GetEyeTrace().HitPos)
			canicule:DrawShadow(false)
			canicule:SetOwner( own )
			canicule:Spawn()
			canicule:Activate()
			
			canicule:EmitSound( "ambient/fire/ignite.wav",60,100)

			timer.Simple(config.tmp,function()
				canicule:StopSound( "ambient/fire/ignite.wav",60,100 )
				config.switch = true
			end)

			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
		return true
end

function SWEP:SecondaryAttack()
	return false
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
	ENT.PrintName = "canicule"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.NextFind = 0
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE)
		self:SetSolid( SOLID_NONE ) 
		self:SetParent(self.Owner)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed(self,config.tmp)

		self.sun = ents.Create("prop_dynamic")
		self.sun:SetPos(self:GetPos() + Vector(0,0,config.zone/1.2))
		self.sun:SetSolid(SOLID_NONE)
		self.sun:DrawShadow(false)
		self.sun:SetAngles(Angle(0,0,0))
		self.sun:SetColor(Color(255,255,255,245))
		self.sun:SetModelScale(0,0)
		self.sun:SetModelScale(4,0.8)
		self.sun:SetModel("models/planets/sun.mdl")
		self.sun:SetMaterial( "models/planets/sun0.mdl" )
		self.sun:Spawn()
		self.sun:Activate()
		SafeRemoveEntityDelayed(self.sun,config.tmp-0.2)
	end
	function ENT:Think() if !SERVER then return end self:NextThink(CurTime())
	local own = self.Owner
	if IsValid(self.sun) then
		self.sun:SetPos(self:GetPos() + Vector(0,0,config.zone/1.2))
		self.sun:SetAngles(self.sun:GetAngles() + Angle(0,1,0))
	end
	if self.NextFind < CurTime() then 
		self.NextFind = CurTime() + 0.2
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_BURN )
				dmginfo:SetDamage( math.random(config.dmgzone1,config.dmgzone2) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( own )
				if (v:IsNPC() or v:IsPlayer() or type(v) == "NextBot" or string.find(v:GetClass(),"prop")) and !v:IsOnFire()  and v != self.Owner then
					v:Ignite(3)
				end
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
			end
		end  
	end
	return true
end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "canicule_effect", ef )
			end
		end
	end
	scripted_ents.Register( ENT, "canicule" )
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
				for i=1, 10 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 ) + Vector(0,0,1)
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 10, 14 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 200 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 180, 100, 50 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 2 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 ) + Vector(0,0,1)
					local particle = self.Emitter:Add( "effects/fire_cloud1", ppp )
					if particle then  local size = math.Rand( 10, 14 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 200 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 150, 130, 130 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 5 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 ) + Vector(0,0,1)
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 3 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 3, 4 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 180, 100, 50 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 15 do
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 ) + Vector(0,0,1))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
						particle:SetDieTime( 0.5 )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( 75 )
						particle:SetEndSize( 100 )
						particle:SetColor( 180, 100, 50 )
						particle:SetGravity( Vector( 0, 0, 0 ) )
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
	function EFFECT:Render() local own = self.Owner
		if IsValid( own ) and self.NextLight < CurTime() then self.NextLight = CurTime() + 0.01
			local dlight = DynamicLight( own:EntIndex() ) if dlight then
				dlight.Pos = own:WorldSpaceCenter() - Vector(0,0,130)
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.Brightness = 5
				dlight.Size = 500
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "canicule_effect" )
end