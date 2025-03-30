AddCSLuaFile()

SWEP.PrintName 		      = "Soin 1" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 85
SWEP.ViewModel      = ""
SWEP.WorldModel   	= ""
SWEP.AutoisActiveTo 	      = false 
SWEP.AutoisActiveFrom       = true 
SWEP.DrawAmmo             = false 
SWEP.Base                 = "weapon_base" 
SWEP.Slot 			      = 2
SWEP.SlotPos              = 1 
SWEP.HoldType             = "magic"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Soin"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 20
config.dmg2 = 20
config.tmp = 10     -- temps pour l'attaque 
config.addVie = 10
config.zone = 200

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()

		if !IsValid( heal )  then 
			local heal = ents.Create( "plant_heal_zone" )
			heal:SetPos( own:GetPos() + Vector( 0, 0, own:OBBCenter().z/2 ) ) 
			heal:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
			heal:SetOwner( own ) 
			heal:Spawn() 
			heal:Activate() 
			self:DeleteOnRemove( heal )
			heal:EmitSound("weapons/physcannon/energy_bounce1.wav", 75,math.random(50,80))
			SafeRemoveEntityDelayed(heal,config.tmp)
			self.nani = heal
		end


	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	return true
end

function SWEP:SecondaryAttack()
    self.CooldownDelay = CurTime()
    if !SERVER then return end
    SafeRemoveEntity(self.nani)
    return true
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	SafeRemoveEntity(self.nani)
	return true
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "Spike"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Upper = 0 
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/flowers/flower_of_truth.mdl" )
		self:SetSolid( SOLID_NONE )  
		self:SetMoveType( MOVETYPE_NONE )
		self:SetColor(Color(220,255,220,220))
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetModelScale(0,0)
		self:SetModelScale(2,0.7)
		self:SetPos( self:GetPos() - Vector( 0, 0, 70 ) ) 
		self:SetAngles(Angle(0,180,0))
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:Think() 
		if !SERVER or self.XDEBZ_Broken then return end
		if self.XDEBZ_Upper < 70 then 
			self.XDEBZ_Upper = self.XDEBZ_Upper + 10
			self:SetPos( self:GetPos() + Vector( 0, 0, 10 ) )
		end
		self:NextThink( CurTime() + 0.01 ) return true
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "plant_heal" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "Cloud"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  ENT.XDEBZ_Tars = {}  ENT.XDEBZ_NextAtk = 0
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Gre = 1  ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/tubes/circle4x4.mdl" )
		self:SetColor(Color(100,255,100))
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		self:SetModelScale(0,0)
		self:SetModelScale(config.zone/83.3,0.7)
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think() 
		if !SERVER or !IsValid( self.Owner ) then
			if SERVER then 
				self:Remove() 
			end 
		return end
		local own = self.Owner
		local tra = util.TraceLine( {
		start = own:EyePos(), 
		endpos = own:EyePos() + own:EyeAngles():Forward()*2000,
		mask = MASK_NPCWORLDSTATIC, 
		filter = { self, own } } )  
		local ptt = tra.HitPos + tra.HitNormal*8
		if self:GetPos():Distance( ptt ) > 150 then 
			self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*150 ) 
		end
		if self.XDEBZ_NextAtk < CurTime() then 
			self.XDEBZ_NextAtk = CurTime() + math.Rand( 0.1, 0.2 )
			local tas = {}  
			for k, v in pairs( ents.FindInSphere( self:WorldSpaceCenter(), config.zone ) ) do
				if !IsValid( v ) or math.abs( v:GetPos().z - self:WorldSpaceCenter().z ) > 18 then continue end 
				if v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					table.insert( tas, v )
				end
			end 
			local tar = tas[ math.random( #tas ) ]
			if IsValid( tar ) then
				local rps = VectorRand():GetNormal()*15  rps = Vector( rps.x, rps.y, 0 )
				local ppp = tar:GetPos() + rps
				local spk = ents.Create( "plant_heal" ) 
				spk:SetPos( ppp )
				spk:SetAngles( Angle( 180, math.Rand( 0, 360 ), 0 ) )
				spk:SetOwner( self ) 
				spk:Spawn() 
				spk:Activate()

				for k,v in pairs(ents.FindInSphere(ppp ,config.zone)) do
					if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( ppp )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
					if v:IsPlayer() and v != own and (own:Health() + config.addVie < own:GetMaxHealth()) then
						own:SetHealth(own:Health()+config.addVie)
					elseif v:IsPlayer() and (v:Health() + config.addVie >= v:GetMaxHealth()) then
						own:SetHealth(own:GetMaxHealth())
					elseif v:IsNPC() and v != own and (own:Health() + config.addVie < own:GetMaxHealth()) then
						own:SetHealth(own:Health()+config.addVie)
					elseif v:IsNPC() and (v:Health() + config.addVie >= v:GetMaxHealth()) then
						own:SetHealth(own:GetMaxHealth())
					end
				end
			end
		end
		self:NextThink( CurTime() ) return true
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "heal_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "plant_heal_zone" )
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
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-50,100),math.random(-50,100),math.random(-50,100))
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
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
						particle:SetColor( 150, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-50,100),math.random(-50,100),math.random(-50,100))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
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
						particle:SetColor( 150, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-50,100),math.random(-50,100),math.random(-20,10)))
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
					particle:SetDieTime( 0.5 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 75 )
					particle:SetEndSize( 100 )
					particle:SetColor( 150, 255, 200 )
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
				dlight.r = 100
				dlight.g = 255
				dlight.b = 100
				dlight.Brightness = 5
				dlight.Size = config.zone*3
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "heal_eff" )
end