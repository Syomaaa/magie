AddCSLuaFile()

SWEP.PrintName 		      = "Sable 2" 
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

SWEP.Category             = "Sable"

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

config.dmg1 = 15
config.dmg2 = 15
config.tmp = 5     -- temps pour la tempete
config.zone = 300

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
			own:EmitSound("ambient/wind/wind_snippet5.wav", 60, 70, 0.6)
			local sand = ents.Create( "sand_storm" )
			sand:SetOwner( own ) 
			sand:SetPos( pos )
			sand:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
			sand:Spawn() 
			sand:Activate()

			timer.Simple(config.tmp,function()
				own:StopSound("ambient/wind/wind_snippet5.wav", 60, 70, 0.6)
			end)

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
	ENT.XDEBZ_Gre = 1  ENT.XDEBZ_Removed = false  ENT.XDEBZ_Storm = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2a.mdl" )
		self:SetMoveType( MOVETYPE_NONE ) 
		self:SetSolid( SOLID_NONE ) 
		self:PhysicsInit(SOLID_NONE)
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think() self:NextThink( CurTime() + 0.3 ) 
		if !SERVER then return end
			local fex = ents.Create( "env_physexplosion" )
			fex:SetPos( self:GetPos() + Vector( 0, 0, 500 ) )
			fex:SetKeyValue( "SpawnFlags", 1 + 2 ) 
			fex:SetKeyValue( "Radius", config.zone )
			fex:SetKeyValue( "Magnitude", 20 ) 
			fex:Spawn() 
			fex:Activate()
			fex:Fire( "Explode" ) 
			SafeRemoveEntityDelayed( fex, 0.1 )
			local own = ( IsValid( self.Owner ) and self.Owner or self )
			for k, v in pairs( ents.FindInSphere( self:GetPos() , config.zone*1.2 ) ) do
				if !IsValid( v ) or !v:GetModel() or !util.IsValidModel( v:GetModel() ) or v:GetModel() == "models/error.mdl" then continue end
				local vel = ( Angle( 0, math.random( 0, 360 ), 0 ):Forward()*1000 + Vector( 0, 0, -500 ) )
				local num = 0  
				if ( v:IsPlayer() or v:IsNPC() ) and v:GetMaxHealth() > 0 then 
					num = v:GetMaxHealth()  
				end
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
			return true
		end
	function ENT:OnTakeDamage( dmginfo ) end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "sand_storm_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "sand_storm" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				local pos = ent:WorldSpaceCenter()  local ang = Angle( 0, ent:GetAngles().yaw, 0 )  local rad = config.zone
				self.Emitter:SetPos( pos )
				for i = 1, 12 do
					local pp = ( pos + Vector( math.random( -rad, rad ), math.random( -rad, rad ), 0 ):GetNormal()*math.random( -rad, rad ) + Vector( 0, 0, rad*math.Rand( 0.5, 0.75 ) ) )
					local particle = self.Emitter:Add( "particle/snow.vmt", pp )
					if particle then
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal()*50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 160 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 2, 4 ) )
						particle:SetEndSize( 0 )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 170, 130, 60 )
						particle:SetGravity( Vector( 0, 0, -1000 ) )
						particle:SetAirResistance( 50 )
						particle:SetCollide( true )
						particle:SetBounce( 0 )
					end
				end
				for i = 1, 3 do
					local pp = ( pos + Vector( math.random( -rad, rad ), math.random( -rad, rad ), 0 ):GetNormal()*math.random( -rad*1.5, rad*1.5 ) + Vector( 0, 0, rad*math.Rand( 0.5, 1 ) ) )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", pp )
					if particle then local siz = 40
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal()*200 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 150 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( siz )
						particle:SetEndSize( siz * 2 )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 3 )
						particle:SetColor( 170, 130, 60 )
						particle:SetGravity( Vector( 0, 0, 0 ) )
						particle:SetAirResistance( 100 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i = 1, 6 do
					local pp = ( pos + Vector( math.random( -rad, rad ), math.random( -rad, rad ), 0 ):GetNormal()*math.random( -rad, rad ) + Vector( 0, 0, rad*0.75 ) )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", pp )
					if particle then local siz = math.Rand( 50, 70 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 155 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( siz )
						particle:SetEndSize( siz * 2 )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 170, 130, 60 )
						particle:SetGravity( Vector( math.Rand( -rad/2, rad/2 ), math.Rand( -rad/2, rad/2 ), -rad ) )
						particle:SetAirResistance( 0 )
						particle:SetCollide( true )
						particle:SetBounce( 0.2 )
					end
				end
				
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render() end
	effects.Register( EFFECT, "sand_storm_eff" )
end