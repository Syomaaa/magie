AddCSLuaFile()

SWEP.PrintName 		      = "Soleil 4" 
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

SWEP.Cooldown = 20

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 50
config.dmg2 = 50   -- degat en continue de le lune quand elle tombe

config.bigdmg1 = 125 
config.bigdmg2 = 125   -- degat de le lune quand elle est au sol
config.tmp = 3 -- temps du chute max
config.tmpFall = 0.01 --tmp avant que la lune tombe
config.zone = 1000
config.push = 2000

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
 self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		own = self:GetOwner()
		local own = self.Owner
		local tra = util.TraceLine( {
		start = own:EyePos(), 
		endpos = own:EyePos() + own:EyeAngles():Forward()*3000,
		mask = MASK_NPCWORLDSTATIC, 
		filter = { self, own } } )  
		local pos = tra.HitPos + tra.HitNormal*8
		config.hitpos = pos

		local ang = Angle(0,own:GetAngles().y,0):Forward()
		if tra.HitWorld then
			local soleil_lune = ents.Create( "metal_soleil" ) 
			soleil_lune:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			soleil_lune:SetPos( pos + Vector(0,0,1000) ) 
			soleil_lune.Owner = own
			soleil_lune:Spawn() 
			soleil_lune:Activate() 
			own:DeleteOnRemove( soleil_lune )
			soleil_lune:EmitSound( "ambient/levels/canals/tunnel_wind_loop1.wav",400 )

			timer.Simple(config.tmp,function()
				soleil_lune:StopSound( "ambient/levels/canals/tunnel_wind_loop1.wav",400 )
			end)
		end
		

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:SecondaryAttack()
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.PrintName = "lune_zone"
	ENT.Base = "base_anim"
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	ENT.Effect = false  ENT.Owner = nil  ENT.Gre = 1  ENT.NextSnd = CurTime() + math.Rand( 5, 20 )
	ENT.Enemy = nil  ENT.NextFind = 0  ENT.ClBeam = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/planets/sun.mdl" )
        self:SetMaterial( "models/planets/sun0.mdl" )
		self:SetColor(Color(255,255,255,255))
		self:SetMoveType( MOVETYPE_NONE ) 
		self:SetSolid( SOLID_NONE )
		self:DrawShadow( false )
		self:SetModelScale(12,0)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmp )
		config.smoke=true
	end
	function ENT:Think()
		self:NextThink( CurTime() ) 
		if SERVER then
			if SERVER and IsValid( own ) then
				self:SetPos(self:GetPos() - Vector(0,0,30))
			end
			if self.NextFind < CurTime() then 
				self.NextFind = CurTime() + 0.2
				for k,v in pairs(ents.FindInSphere(self:GetPos() ,1000)) do
					if IsValid(v) and v != own then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( self:GetPos() )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
			if self:GetPos().z <= config.hitpos.z + 500 && self:GetPos().z >= config.hitpos.z + 450 && config.smoke then
				local exploEff = ents.Create("env_smokestack")
				exploEff:SetKeyValue("smokematerial", "particles/smokey")
				exploEff:SetKeyValue("rendercolor", "100 100 100" )
				exploEff:SetKeyValue("targetname","exploEff")
				exploEff:SetKeyValue("basespread","600")
				exploEff:SetKeyValue("spreadspeed","300")
				exploEff:SetKeyValue("speed","100")
				exploEff:SetKeyValue("startsize","400")
				exploEff:SetKeyValue("endzide","700")
				exploEff:SetKeyValue("rate","200")
				exploEff:SetKeyValue("jetlength","1000")
				exploEff:SetPos(self:GetPos() - Vector(0,0,470))
				exploEff:Spawn()
				exploEff:Fire("turnon","",0)
				exploEff:Fire("Kill","",4)
				config.smoke=false
			elseif self:GetPos().z <= config.hitpos.z then
				self:EmitSound("ambient/explosions/explode_2.wav",100,100,3)

				for _, ply in pairs(ents.FindInSphere(self:GetPos(), config.zone)) do
					if IsValid(ply) and ply:IsPlayer() and ply != self.Owner then
						local direction = (ply:GetPos() - self:GetPos()):GetNormalized()

						local pushVector = direction *  config.push 
						ply:SetVelocity(pushVector)
					end
				end

				for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
					if IsValid(v) and v != own then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( self:GetPos() )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end

				SafeRemoveEntity(self)
			end
		end
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
				util.Effect( "soleil_big_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	
	scripted_ents.Register( ENT, "metal_soleil" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "soleilciel"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/planets/sun.mdl" )
        self:SetMaterial( "models/planets/sun0.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmp)
		self.Shake = ents.Create( "env_shake" )
		self.Shake:SetPos( self:GetPos() - Vector(0,0,2000) )
		self.Shake:SetKeyValue( "amplitude", "4" )
		self.Shake:SetKeyValue( "radius", config.zone*3 )
		self.Shake:SetKeyValue( "duration", "10" )
		self.Shake:SetKeyValue( "frequency", "255" )
		self.Shake:SetKeyValue( "spawnflags", "4" )
		self.Shake:Spawn()
		self.Shake:Activate()
		self.Shake:Fire( "StartShake", "", 0 )
		timer.Simple(config.tmpFall,function()
			if IsValid(self) then
				local soleil = ents.Create( "soleil_big" ) 
				soleil:SetPos( self:GetPos() ) 
				soleil:Spawn() 
				soleil:Activate() 
			end
		end)
	end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "ciel_soleil_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "ciel_soleil" )
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
					local particle2 = self.Emitter:Add( "etoile.vmt", ent:WorldSpaceCenter() + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone/2,config.zone)) )
					if particle2 then  local size = math.Rand( 4, 7 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.3, 0.8 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 200, 200, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone/2,config.zone)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 1, 2) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 5 )
						particle2:SetEndSize( 10 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255  )
						particle2:SetGravity( Vector( 0, 0, 0 ) )
						particle2:SetAirResistance( 2 )
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
	effects.Register( EFFECT, "soleil_big_effect" )
end

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
				for i=1, 15 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-2500,2500),math.random(-2500,2500),math.random(-30,30))
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 100, 200 )
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
						particle:SetColor( 20, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-2500,2500),math.random(-2500,2500),math.random(-30,30))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 3 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 10, 20 ) )
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
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()
	end
	effects.Register( EFFECT, "ciel_soleil_effect" )
end