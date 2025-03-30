AddCSLuaFile()

SWEP.PrintName 		      = "Spirit 2" 
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

SWEP.Category             = "Spirit"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.Cooldown = 30

SWEP.ActionDelay = 1

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 15
config.dmg2 = 15

config.Cooldown = 0.2 -- coolwon atk pet

config.zone = 200

config.tmp = 15 -- temps du pet

local ENT = {}
ENT.PrintName = "monster"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true  ENT.Tick = 0  ENT.Dead = false
ENT.Effect = false  ENT.Owner = nil
ENT.Enemy = nil  ENT.NextFind = 0 

config.switch = false

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
   
	self:SetHoldType( "magic" )
end

--------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	local own = self.Owner
	local pos = own:GetShootPos()
	if IsValid( own.Minion ) then own:PrintMessage( HUD_PRINTCENTER, "Un seul minion à la fois !" ) return end
		
		local monster = ents.Create( "spirit_ghost" )
		if SERVER then
			monster:EmitSound( "npc/ichthyosaur/water_growl5.wav" )
		end
		monster:SetPos( own:GetShootPos() +own:EyeAngles():Forward()*40 )
		monster:SetAngles( own:EyeAngles() ) 
		monster:SetOwner( own )
		monster:Spawn() 
		monster:Activate()
		own:DeleteOnRemove( monster )
		monster:SetPhysicsAttacker( own )
		own.Minion = monster 
		own:SetNWEntity( "Mint2", monster )
		undo.Create( "monster" ) undo.AddEntity( monster ) undo.SetPlayer( own ) undo.Finish()

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

--------------------------------------------------------------------------------------------------------------

function GhostAttack( tar, atk, per, fce, own )
	if !isvector( fce ) or ( isnumber( tar.Immune ) and tar.Immune > CurTime() ) then fce = Vector( 0, 0, 0 ) end fce = fce * 0.1
	if tar:IsOnFire() then tar:Extinguish() end if isnumber( per ) and atk != tar then

		config.own = atk
		local pos = own:GetPos()
		local ball = ents.Create( "ghost_ball" )
		ball:SetPos( pos )
		ball:SetAngles( own:EyeAngles() + Angle(0,150,0) ) 
		ball:SetOwner( atk and own )
		ball:Spawn() 
		ball:Activate() 
		own:DeleteOnRemove( ball )
		ball:GetPhysicsObject():SetVelocity( fce * 20 )
		ball:SetPhysicsAttacker( own )
	end
end

if true then
	function ENT:Initialize()
		 if !SERVER then return end 
		self:SetModel( "models/trixxedheart/oneshot/ShadeNiko2.mdl" )
		self:SetMoveType( MOVETYPE_NOCLIP ) 
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON ) 
		self:DrawShadow( false )
		self:SetModelScale(0.4,0.2)
		self:SetMaterial( "poke/props/plainshiny" )
		self:SetColor(Color(35,20,50,90))
		self:SetBloodColor( DONT_BLEED )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think() self:NextThink( CurTime() ) 
		self.Tick = self.Tick + 0.01  
		local tic = self.Tick
		if self.Dead then return end
		if SERVER and ( !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() or !IsValid( self.Owner.Minion ) or self.Owner.Minion != self ) then
			self:monsterKill() return
		end
		if SERVER and IsValid( self.Owner ) then local own = self.Owner
			if self:IsOnFire() then self:Extinguish() end if own:IsOnFire() then own:Extinguish() end
			if self.NextFind < CurTime() then self.NextFind = CurTime() + config.Cooldown
				local tar = nil  local dis = -1
				for k, v in pairs( ents.FindInSphere( self:WorldSpaceCenter(), 1000 ) ) do
					if IsValid( v ) and ( v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != own and v != self then
						local ddd = v:WorldSpaceCenter():DistToSqr( self:WorldSpaceCenter() )
						
						if dis == -1 or ddd < dis then
							local tr = util.TraceLine( {
								start = self:WorldSpaceCenter(),
								endpos = v:WorldSpaceCenter(),
								filter = { own, self },
							} )
							if !tr.Hit or tr.Entity == v then dis = ddd  tar = v end
						end
					end
				end 
				self.Enemy = tar 
				self.anime = false
				if IsValid( self.Enemy ) then
					local ppp = ( self.Enemy:WorldSpaceCenter() - self:WorldSpaceCenter() + Vector(0,0,20)):GetNormal()*1000
					GhostAttack( self.Enemy, self.Owner, 5, ppp, self)
				end
			end
			local top = Vector( math.sin( tic )*own:OBBMaxs().x*4, math.cos( tic )*own:OBBMaxs().x*4, own:OBBMaxs().z +math.sin( tic*2 )*5 )
			local enm = self.Enemy  if IsValid( enm ) then
				local psp = ( enm:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormal()*own:OBBMaxs().x*4
				
			end
			local tr = util.TraceLine( {
				start = own:GetPos(),
				endpos = own:GetPos() + own:GetAngles():Forward()*-60 + Vector(0,0,60),
				filter = { own, self },
				mask = MASK_SHOT_HULL
			} )
			local vel = tr.HitPos + tr.HitNormal*60  
			local ang = self:GetVelocity():Angle().yaw 
			if IsValid( enm ) then 
				ang = ( enm:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormal():Angle().yaw 
			end
			vel = ( vel - self:EyePos() )  
			local spd = math.max( vel:Length(), 0 )
			vel:Normalize() 
			self:SetLocalVelocity( vel * spd * 5 ) 
			if self:WorldSpaceCenter():Distance( own:EyePos() ) >= 2048 then
				self:SetPos( own:GetPos() ) 
				self:SetParent( own )  
			end
			local def = self:GetAngles().yaw  
			def = Lerp( 0.2, def, ang )  
			self:SetAngles( Angle( 0, def , 0 ) )
		end 
		return true
	end
	function ENT:Use( act ) if self.Dead then return end local own = self.Owner
		if IsValid( own ) and act == own then self:monsterKill() end
	end
	function ENT:monsterKill()
		if self.Dead then return end local own = self.Owner
		self.Dead = true self:EmitSound( "Underwater.BulletImpact" )
		SafeRemoveEntityDelayed( par, 1 )  self:Remove()
	end
	function ENT:OnRemove()
        config.switch = true
    end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "spirit_ghost" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "ghsoball"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/blocks/cube05x05x05.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetMaterial( "models/shadertest/shader3" )
		self:GetPhysicsObject():EnableGravity( false )
		self:SetColor( Color( 255 , 255 ,255 , 100 ) )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD)
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:PhysicsCollide( data, phys )
		SafeRemoveEntityDelayed( self, 0 )
		self:EmitSound("weapons/fx/nearmiss/bulletLtoR06.wav", 65, math.Rand(30,60), 0.8)
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		end 
		local own = self.Owner
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,200)) do
			if IsValid(v) and v != config.own and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( config.own )
				dmginfo:SetInflictor( config.own )
				v:TakeDamageInfo(dmginfo)
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  
	end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "ghost_ball_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "ghost_ball" )
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
				for i=1, 2 do
					local ppp = ent:WorldSpaceCenter()+ Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
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
						particle:SetRollDelta( 1 )
						particle:SetColor( 80, 0, 130 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 1, 2 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 10, 0, 60 )
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
	effects.Register( EFFECT, "ghost_ball_effect" )
end

-----------------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	return true
end

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end