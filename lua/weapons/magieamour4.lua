AddCSLuaFile()

SWEP.PrintName 		      = "Amour 4" 
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

SWEP.Category             = "Amour"

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
config.dmg1 = 30
config.dmg2 = 30
config.tmp = 10     -- temps pour la tempete

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	
			local own = self:GetOwner()
			local pos = self.Owner:GetEyeTrace().HitPos
			local amour4 = ents.Create( "love_storm" )
			amour4:SetOwner( own ) 
			amour4:SetPos( pos )
			amour4:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
			amour4:Spawn() 
			amour4:Activate()

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
	ENT.PrintName = "Storm"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Gre = 1  ENT.XDEBZ_Removed = false  ENT.XDEBZ_Storm = false  ENT.XDEBZ_Effect = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2a.mdl" )
		self:SetMoveType( MOVETYPE_NONE ) 
		self:SetNotSolid( true )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self:SetModelScale( 0,0 )
		timer.Simple( 0.5, function()
			if IsValid( self ) and !self.XDEBZ_Removed then self:SetNWBool( "XDEBZ_Stormed", true ) end
		end )
		timer.Simple( 2, function()
			if IsValid( self ) and !self.XDEBZ_Removed then 
				self.XDEBZ_Storm = true
			end
		end )
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:OnRemove()
		if self.XDEBZ_Removed then return end 
		self.XDEBZ_Removed = true
	end
	function ENT:Think() self:NextThink( CurTime() + 0.3 ) if !SERVER then
		if self:GetNWBool( "XDEBZ_Stormed" ) then
			if !self.XDEBZ_Effect then 
				self.XDEBZ_Effect = true
				local ef = EffectData() ef:SetEntity( self ) util.Effect( "love_storm_eff", ef ) 
			end
		end
		return true end
		if self.XDEBZ_Storm and !self.XDEBZ_Removed then 
			util.ScreenShake( self:GetPos() + Vector( 0, 0, 500 ), 3, 10, 3, 800 )
			local fex = ents.Create( "env_physexplosion" )
			fex:SetPos( self:GetPos() + Vector( 0, 0, 500 ) )
			fex:SetKeyValue( "SpawnFlags", 1 + 2 ) 
			fex:SetKeyValue( "Radius", 800 )
			fex:SetKeyValue( "Magnitude", 20 ) 
			fex:Spawn() 
			fex:Activate()
			fex:Fire( "Explode" ) 
			SafeRemoveEntityDelayed( fex, 0.1 )
			local own = ( IsValid( self.Owner ) and self.Owner or self )
			for k, v in pairs( ents.FindInSphere( self:GetPos() + Vector( 0, 0, 500 ), 800 ) ) do
				if !IsValid( v ) or !v:GetModel() or !util.IsValidModel( v:GetModel() ) or v:GetModel() == "models/error.mdl" then continue end
				local vel = ( Angle( 0, math.random( 0, 360 ), 0 ):Forward()*1000 + Vector( 0, 0, -500 ) )
				local num = 0  
				if v != own and !v.XDEBZ_Gre and v != self and IsValid( v:GetPhysicsObject() ) then 
					v:SetVelocity( vel ) if IsValid( v:GetPhysicsObject() ) then v:GetPhysicsObject():AddVelocity( vel * ( v:GetPhysicsObjectCount() > 1 and 3 or 0.5 ) ) end end
					local trworld = {
					start = v:LocalToWorld(Vector(0, 0, 0)),
					endpos = v:LocalToWorld(Vector(0, 0, 0)) + Vector(0,0,-50),
					filter = v
					}            
					local trace = util.TraceLine(trworld)
					if v != own and trace.Hit and v:GetClass()  then
						local dmginfo = DamageInfo()
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamageForce( self:GetPos() + Vector( 0, 0, 500 ))
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor(own )
						v:TakeDamageInfo(dmginfo)
					end
				end
			end 
			return true
		end
	function ENT:OnTakeDamage( dmginfo ) end
	scripted_ents.Register( ENT, "love_storm" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				local pos = ent:WorldSpaceCenter()  local ang = Angle( 0, ent:GetAngles().yaw, 0 )  local rad = 800
				self.Emitter:SetPos( pos )
				for i = 1, 12 do
					local pp = ( pos + Vector( math.random( -rad, rad ), math.random( -rad, rad ), 0 ):GetNormal()*math.random( -rad, rad ) + Vector( 0, 0, rad*math.Rand( 0.5, 0.75 ) ) )
					local particle = self.Emitter:Add( "particle/snow.vmt", pp )
					if particle then
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal()*50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 2, 4 ) )
						particle:SetEndSize( 0 )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 255, 180, 200 )
						particle:SetGravity( Vector( 0, 0, -1000 ) )
						particle:SetAirResistance( 50 )
						particle:SetCollide( true )
						particle:SetBounce( 0 )
					end
				end
				for i = 1, 3 do
					local pp = ( pos + Vector( math.random( -rad, rad ), math.random( -rad, rad ), 0 ):GetNormal()*math.random( -rad*1.5, rad*1.5 ) + Vector( 0, 0, rad*math.Rand( 0.5, 1 ) ) )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", pp )
					if particle then local siz = 120
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal()*200 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( siz )
						particle:SetEndSize( siz * 2 )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 3 )
						particle:SetColor( 255, 180, 200 )
						particle:SetGravity( Vector( 0, 0, 0 ) )
						particle:SetAirResistance( 100 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i = 1, 6 do
					local pp = ( pos + Vector( math.random( -rad, rad ), math.random( -rad, rad ), 0 ):GetNormal()*math.random( -rad, rad ) + Vector( 0, 0, rad*0.75 ) )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", pp )
					if particle then local siz = math.Rand( 90, 120 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 155 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( siz )
						particle:SetEndSize( siz * 2 )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 255, 180, 200 )
						particle:SetGravity( Vector( math.Rand( -rad/2, rad/2 ), math.Rand( -rad/2, rad/2 ), -rad ) )
						particle:SetAirResistance( 0 )
						particle:SetCollide( true )
						particle:SetBounce( 0.2 )
					end
				end
				local pp = ( pos + Vector( math.random( -rad, rad ), math.random( -rad, rad ), 0 ):GetNormal()*math.random( -rad, rad ) + Vector( 0, 0, rad*math.Rand( 0.05, 0.75 ) ) )
				local particle = self.Emitter:Add( "love/heart1.vmt", pp )
				if particle then local siz = math.Rand( 5, 10 )
					particle:SetLifeTime( 0 )
					particle:SetDieTime( math.Rand( 0.5, 2 ) )
					particle:SetStartAlpha( 5 )
					particle:SetEndAlpha( 4 )
					particle:SetStartSize( 0 )
					particle:SetEndSize( siz )
					particle:SetColor( 255, 180, 200 )
					particle:SetGravity( VectorRand():GetNormal() * 100 )
					particle:SetAirResistance( 25 )
					particle:SetCollide( false )
					particle:SetBounce( 0 )
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render() end
	effects.Register( EFFECT, "love_storm_eff" )
end