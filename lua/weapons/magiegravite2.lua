AddCSLuaFile()

SWEP.PrintName 		      = "Gravité 2" 
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

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 30
config.dmg2 = 30    -- degat en continue de zone
config.tmp = 3    -- temps de la zone
config.unslow = 2.5  -- temps du slow
config.beforeSlow = 0  -- temps avant slow apres la bulle active
config.slow = 3  -- vitesse divise par ...
config.zone = 300 -- zone de touche
config.tmpfreeze = 1.5

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()
		local pos = own:GetEyeTrace().HitPos
		local ang = Angle(0,own:GetAngles().y,0)

		config.switch = true

		local controle_zone = ents.Create( "controle_zone" ) 
		controle_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
		controle_zone:SetPos( pos + ang) 
		controle_zone.Owner = own
		controle_zone:Spawn() 
		controle_zone:Activate() 
		own:DeleteOnRemove( controle_zone )

		controle_zone:EmitSound( "ambient/energy/force_field_loop1.wav",75,40,0.4 )

		timer.Simple(config.tmp-1, function()
			if IsValid(controle_zone) then
				controle_zone:SetModelScale( 1, 1 )
				controle_zone:StopSound( "ambient/energy/force_field_loop1.wav")
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
end

function SWEP:SecondaryAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	local Owner = self.Owner
	for k,v in pairs(ents.FindInSphere(Owner:GetPos(), 300)) do
		local phys = v:GetPhysicsObject()
		if IsValid(v) and IsValid(phys) then
			phys:EnableGravity(false)
			phys:AddVelocity(Vector(0, 0, 20))
			v:SetGravity(0.01)
			timer.Create(v:EntIndex().."_gpow_GravityControl", 10, 1, function()
				if IsValid(phys) and IsValid(v) then
					phys:EnableGravity(true)
					v:SetGravity(1)
				end
			end)
		end
	end
	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:Reload()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	local Owner = self.Owner
	local tr = Owner:GetEyeTrace()
	local phys = tr.Entity:GetPhysicsObject()
	if tr.HitNonWorld and IsValid(tr.Entity) and IsValid(phys) then
		phys:EnableGravity(false)
		phys:AddVelocity(Vector(0, 0, 20))
		tr.Entity:SetGravity(0.01)
		timer.Create(tr.Entity:EntIndex().."_gpow_GravityControl", 10, 1, function()
			if IsValid(phys) and IsValid(tr.Entity) then
				phys:EnableGravity(true)
				tr.Entity:SetGravity(1)
			end
		end)
	end
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
	ENT.PrintName = "tmpZone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2.mdl" )
		self:SetMaterial( "debug/env_cubemap_model" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,255,255,20 ) )
		self:SetModelScale( config.zone/41, 0.7 ) 
		local own = self.Owner
		SafeRemoveEntityDelayed( self, config.tmp )
		timer.Simple(config.beforeSlow,function()
			if IsValid(self) then
				for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
					if v:IsPlayer() and v != own then
						v:SetRunSpeed( v:GetRunSpeed()/config.slow )
						v:SetWalkSpeed( v:GetWalkSpeed()/config.slow )
						v:SetJumpPower( v:GetJumpPower()/config.slow )
						timer.Simple(config.unslow,function()
							if IsValid(self) then
								v:SetRunSpeed( v:GetRunSpeed()*config.slow )
								v:SetWalkSpeed( v:GetWalkSpeed()*config.slow )
								v:SetJumpPower( v:GetJumpPower()*config.slow )
							end
						end)		
					end
					
					if IsValid(v) and v != self.Owner and (v:IsPlayer())  then
						v:SetMoveType(MOVETYPE_NONE)
						v:Freeze(true)
						timer.Simple(config.tmpfreeze,function()
							if IsValid(v) then
								v:SetMoveType(MOVETYPE_WALK)
								v:Freeze(false)
							end
						end)
					end
					if IsValid(v) and v:IsNPC() and v != self.Owner then
						v:SetCondition( 67 )
						timer.Simple(config.tmpfreeze,function()
							if IsValid(v) then
								v:SetCondition( 68 )
							end
						end)
					end
					if v:IsNPC() and v != own then	
						if SERVER then
							v:SetCondition( 67 )
							timer.Simple(0.2,function()
								if IsValid(self) then
									
								end
							end)
							timer.Simple(config.unslow, function()
								if IsValid(v) then 
									v:SetCondition( 68 )
								end
							end)
						end
					end
				end
			end
		end)
	end
	function ENT:Think()
		if SERVER then
			local own = self.Owner
			if IsValid(self) then
				for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
					if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( self:GetPos() )
						v:AddEFlags("-2147483648" )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
						v:RemoveEFlags("-2147483648" )
					end
				end
			end
		end
		self:NextThink( CurTime() +0.5 ) return true
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "controle_zone_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "controle_zone" )
end

function SWEP:Holster()
	if config.switch == false then
		return false
	else
		return true
	end
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
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-400,config.zone)) )
					if particle2 then  local size = math.Rand( 3, 6 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.3 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 255 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 100, 100, 100 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "gravite2.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-400,config.zone)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.5,1) )
						particle2:SetStartAlpha( 100 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 100 )
						particle2:SetEndSize( 150 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 0 )
						particle2:SetRollDelta( 0 )
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, -1500 ) )
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
	effects.Register( EFFECT, "controle_zone_effect" )
end