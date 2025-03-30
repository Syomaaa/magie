AddCSLuaFile()

SWEP.PrintName 		      = "Lune 3" 
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

SWEP.Category             = "Lune"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 25

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 35 
config.dmg2 = 35   -- degat en continue de zone*
config.tmp = 10 -- temps du pet
config.zone = 800

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

		local lune_zone = ents.Create( "lune_zone" ) 
		lune_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
		lune_zone:SetPos( pos) 
		lune_zone.Owner = own
		lune_zone:Spawn() 
		lune_zone:Activate() 
		own:DeleteOnRemove( lune_zone )
		lune_zone:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )
		

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

function luneAttack( tar, atk, per, fce, own )
	if !isvector( fce ) or ( isnumber( tar.Immune ) and tar.Immune > CurTime() ) then fce = Vector( 0, 0, 0 ) end fce = fce * 0.1
	if tar:IsOnFire() then tar:Extinguish() end if isnumber( per ) and atk != tar then

		local pos = own:GetPos() + Vector(0,0,config.zone/1.3)
		local lune = ents.Create( "ball_lune" )
		lune:SetPos( pos)
		lune:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		lune:SetAngles( own:EyeAngles()  ) 
		lune:SetOwner( atk  )
		lune:Spawn() 
		lune:Activate() 
		own:DeleteOnRemove( lune )
		lune:GetPhysicsObject():SetVelocity( fce * 30 )
		lune:SetPhysicsAttacker( own )
		lune:EmitSound( "weapons/fx/nearmiss/bulletltor07.wav" )
	end
end

if true then
	local ENT = {}
	ENT.PrintName = "lune_zone"
	ENT.Base = "base_anim"
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	ENT.Effect = false  ENT.Owner = nil  ENT.Gre = 1  ENT.NextSnd = CurTime() + math.Rand( 5, 20 )
	ENT.Enemy = nil  ENT.NextFind = 0  ENT.ClBeam = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/hunter/misc/shell2x2.mdl" )
		self:SetMaterial("models/rendertarget")
		self:SetColor(Color(255,255,255,255))
		self:SetMoveType( MOVETYPE_NONE ) 
		self:SetSolid( SOLID_NONE )
		self:DrawShadow( false )
		self:SetModelScale(config.zone/43,0.2)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmp )

		self.moon = ents.Create("prop_dynamic")
		self.moon:SetPos(self:GetPos() + Vector(0,0,config.zone/1.2))
		self.moon:SetAngles(Angle(0,0,0))
		self.moon:SetModelScale(3,0.1)
		self.moon:SetModel("models/planets/luna_big.mdl")
		self.moon:Spawn()
		self.moon:Activate()
		SafeRemoveEntityDelayed(self.moon,config.tmp)

	end
	function ENT:Think() self:NextThink( CurTime() )
		if SERVER and IsValid( self.Owner ) then local own = self.Owner
			self.moon:SetAngles(self.moon:GetAngles() + Angle(0,1,0))
			if self:IsOnFire() then self:Extinguish() end if own:IsOnFire() then 
				own:Extinguish() 
			end
			if self.NextFind < CurTime() then 
				self.NextFind = CurTime() + 0.2
				local tar = nil  local dis = -1
				for k, v in pairs( ents.FindInSphere( self:WorldSpaceCenter(), config.zone ) ) do
					if !IsValid( v ) or ( !v:IsPlayer() and !v:IsNPC() ) or ( ( v:IsPlayer() and !v:Alive() ) or ( v:IsNPC() and v:GetNPCState() == NPC_STATE_DEAD ) )
					or v == own or v == self then continue end local ddd = v:WorldSpaceCenter():DistToSqr( self:WorldSpaceCenter() )
					
					if dis == -1 or ddd < dis then
						local tr = util.TraceLine( {
							start = self:WorldSpaceCenter(),
							endpos = v:WorldSpaceCenter(),
							filter = { own, self },
						} )
						if !tr.Hit or tr.Entity == v then dis = ddd  tar = v end
					end
				end self.Enemy = tar 
				if IsValid( self.Enemy ) then
					self:SetNWEntity( "Enm", self.Enemy )
					local ppp = ( self.Enemy:WorldSpaceCenter() - self:WorldSpaceCenter() - Vector(0,0,config.zone/1.5)):GetNormal()*1000
					luneAttack( self.Enemy, self.Owner, 5, ppp, self)
				else
					 self:SetNWEntity( "Enm", Entity( 0 ) )
				end
			end
			local enm = self.Enemy  if IsValid( enm ) then
				local psp = ( enm:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormal()*own:OBBMaxs().x*4
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
				util.Effect( "lune_zone_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	
	scripted_ents.Register( ENT, "lune_zone" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "water"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/planets/luna_small.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:luneBreak( ppp )
		if self.XDEBZ_Hit or !isvector( ppp ) then return end local own = self.Owner
		self.XDEBZ_Hit = true self:EmitSound("physics/cardboard/cardboard_box_impact_bullet1.wav", 65, math.Rand(30,60), 0.8)
		for k,v in pairs(ents.FindInSphere(ppp ,300)) do
			if IsValid(v) and v != own then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
				dmginfo:SetDamagePosition( ppp )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
			end
		end
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.1 )

	end
	function ENT:StartTouch( ent )
		if self.XDEBZ_Hit or ent:GetClass() == self:GetClass() or ent.XDEBZ_Gre then return end  local own = self.Owner
		if IsValid( own ) and own == ent then return end self:luneBreak( self:GetPos() )
	end
	function ENT:PhysicsCollide( data, phys )
		if self.XDEBZ_Hit then return end  local own = self.Owner
		if IsValid( data.HitEntity ) and ( data.HitEntity:GetClass() == self:GetClass() or ( IsValid( own ) and own == data.HitEntity ) or data.HitEntity.XDEBZ_Gre ) then return end
		self:luneBreak( data.HitPos + data.HitNormal*5 )
	end
	function ENT:Think() if !SERVER then return end
	if !self.XDEBZ_Hit then self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*10000 ) end end
	function ENT:OnTakeDamage( dmginfo ) if !self.XDEBZ_Hit then self:luneBreak( self:GetPos() ) end end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "ball_lune_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "ball_lune" )
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
	effects.Register( EFFECT, "lune_zone_effect" )
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
				for i=1, 3 do
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt" ,ent:WorldSpaceCenter() + Vector(math.random(-3,3),math.random(-3,3),math.random(-3,3)))
					if particle then  local size = math.Rand( 2, 5 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.5, 1 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 255, 255, 255 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 2 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt" ,ent:WorldSpaceCenter() +  Vector(math.random(-7,7),math.random(-7,7),math.random(-7,7)))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.5, 1 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 1, 2 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 255, 255, 255 )
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
	effects.Register( EFFECT, "ball_lune_effect" )
end