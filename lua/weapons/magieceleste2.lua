AddCSLuaFile()

SWEP.PrintName 		      = "Celeste 2" 
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

SWEP.Category             = "Celeste"

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
config.addVie = 20  -- regene tout le temps
config.zone = 125
config.vitesseRegene = 0.2  -- interval regene 
config.nbRegene = 10  --nb de fois regene

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
	
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()

		if !IsValid( celeste ) then 
			local celeste = ents.Create( "celeste_continue" )

			local tra = util.TraceLine( {
				start = own:EyePos(), 
				endpos = own:EyePos() + own:EyeAngles():Forward()*2000,
				ask = MASK_NPCWORLDSTATIC, 
				filter = { self, own }
			} )  

			celeste:SetPos( tra.HitPos ) 
			celeste:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
			celeste:SetOwner( own ) 
			celeste:Spawn() 
			celeste:Activate() 
			self:DeleteOnRemove( celeste )
			celeste:EmitSound("weapons/physcannon/energy_bounce2.wav", 75,math.random(60,80))
		end

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	return true
end

function SWEP:SecondaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()

		if !IsValid( celeste ) then 
			local celeste = ents.Create( "celeste_continue" )
			celeste:SetPos( own:GetPos() ) 
			celeste:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
			celeste:SetOwner( own ) 
			celeste:Spawn() 
			celeste:Activate() 
			self:DeleteOnRemove( celeste )
			celeste:EmitSound("weapons/physcannon/energy_bounce2.wav", 75,math.random(60,80))
		end

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	return true
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "CloudCeleste1"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  ENT.XDEBZ_Tars = {}  ENT.XDEBZ_NextAtk = 0
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Gre = 1  ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetColor(Color(0,255,255))
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		self:SetModelScale(0,0)
		self:SetModelScale(config.zone/83.3,0.7)
		SafeRemoveEntityDelayed( self, 1 )
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
			if (v:IsPlayer() or v:IsNPC()) && IsValid(v) then
				local effceleste = ents.Create( "eff_healceleste" )
				effceleste:SetPos( v:GetPos() + Vector(0,0,15) ) 
				effceleste:SetParent(v)
				effceleste:Spawn() 
				effceleste:Activate()
			end
		end
	
	local idx = "soinceleste3"..self:EntIndex()
		timer.Create(idx,0.01,1,function()
			if IsValid(self) then
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetScale(1)
				effectdata:SetEntity(self)
				ParticleEffectAttach( "[0]_letsdance", 1, self, 1 )
			end
		end)
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "heal_effceleste", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "celeste_continue" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "CloudCeleste2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  ENT.XDEBZ_Tars = {}  ENT.XDEBZ_NextAtk = 0
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Gre = 1  ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetColor(Color(0,255,255))
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		self:SetModelScale(0,0)
		SafeRemoveEntityDelayed( self, config.vitesseRegene*config.nbRegene )
		local idx = "soin2saison2"..self:EntIndex()
		timer.Create(idx,0.01,1,function()
			if IsValid(self) then
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetScale(1)
				effectdata:SetEntity(self)
				ParticleEffectAttach( "[0]_letsdance", 1, self, 1 )
			end
		end)
	end
	function ENT:Think()
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,10)) do
			if v:IsPlayer() && IsValid(v) then
				if v:IsPlayer() and (v:Health() + config.addVie < v:GetMaxHealth()) then
					v:SetHealth(v:Health()+config.addVie)
				elseif v:IsPlayer() and (v:Health() + config.addVie >= v:GetMaxHealth()) then
					v:SetHealth(v:GetMaxHealth())
				end
			elseif v:IsNPC() && IsValid(v) then
				if v:IsNPC() and (v:Health() + config.addVie < v:GetMaxHealth()) then
					v:SetHealth(v:Health()+config.addVie)
				end
			end
		end
		self:NextThink( CurTime() + config.vitesseRegene)
		return true
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "heal_eff_smallceleste", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "eff_healceleste" )
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
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100))
					local particleceleste = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particleceleste then  local size = math.Rand( 5, 10 )
						particleceleste:SetVelocity( VectorRand():GetNormal() * 10 )
						particleceleste:SetLifeTime( 0 )
                        particleceleste:SetDieTime( math.Rand( 0.5, 1.5 ) )
						particleceleste:SetStartAlpha( 255 )
						particleceleste:SetEndAlpha( 0 )
						particleceleste:SetStartSize( size )
						particleceleste:SetEndSize( size * 4 )
						particleceleste:SetAngles( Angle( 0, 0, 0 ) )
						particleceleste:SetRoll( 180 )
						particleceleste:SetRollDelta( 12 )
						particleceleste:SetColor( 129, 255, 255 )
						particleceleste:SetGravity( Vector( 0, 0, 150 ) )
						particleceleste:SetAirResistance( 10 )
						particleceleste:SetCollide( false )
						particleceleste:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100))
					local particleceleste = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particleceleste then
						particleceleste:SetLifeTime( 0 )
						particleceleste:SetDieTime( math.Rand( 1, 3 ) )
						particleceleste:SetStartAlpha( 255 )
						particleceleste:SetEndAlpha( 0 )
						particleceleste:SetStartSize( math.Rand( 1, 2 ) )
						particleceleste:SetEndSize( 0 )
						particleceleste:SetAngles( Angle( 0, 0, 0 ) )
						particleceleste:SetRoll( 180 )
						particleceleste:SetRollDelta( 12 )
						particleceleste:SetColor( 129, 255, 255 )
						particleceleste:SetGravity( Vector( 0, 0, 100 ) )
						particleceleste:SetAirResistance( 10 )
						particleceleste:SetCollide( false )
						particleceleste:SetBounce( 0 )
					end
				end
				local particleceleste = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
				if particleceleste then
					particleceleste:SetLifeTime( 0 )
					particleceleste:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
					particleceleste:SetDieTime( 0.5 )
					particleceleste:SetStartAlpha( 255 )
					particleceleste:SetEndAlpha( 0 )
					particleceleste:SetStartSize( 75 )
					particleceleste:SetEndSize( 100 )
					particleceleste:SetColor( 129, 255, 255 )
					particleceleste:SetGravity( Vector( 0, 0, 0 ) )
					particleceleste:SetAirResistance( 10 )
					particleceleste:SetCollide( false )
					particleceleste:SetBounce( 0 )
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
				dlight.r = 129
				dlight.g = 255
				dlight.b = 255
				dlight.Brightness = 5
				dlight.Size = config.zone*3
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "heal_effceleste" )
end

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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.03
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 30 ) + Vector(math.random(-30,30),math.random(-30,30),math.random(-30,30))
					local particleceleste = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particleceleste then  local size = math.Rand( 5, 10 )
						particleceleste:SetVelocity( VectorRand():GetNormal() * 10 )
						particleceleste:SetLifeTime( 0 )
						particleceleste:SetDieTime( math.Rand( 0.5, 1.5 ) )
						particleceleste:SetStartAlpha( 255 )
						particleceleste:SetEndAlpha( 0 )
						particleceleste:SetStartSize( size )
						particleceleste:SetEndSize( size * 4 )
						particleceleste:SetAngles( Angle( 0, 0, 0 ) )
						particleceleste:SetRoll( 180 )
						particleceleste:SetRollDelta( 12 )
						particleceleste:SetColor( 129, 255, 255 )
						particleceleste:SetGravity( Vector( 0, 0, 150 ) )
						particleceleste:SetAirResistance( 10 )
						particleceleste:SetCollide( false )
						particleceleste:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 30 ) + Vector(math.random(-30,30),math.random(-30,30),math.random(-30,30))
					local particleceleste = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particleceleste then
						particleceleste:SetLifeTime( 0 )
						particleceleste:SetDieTime( math.Rand( 1, 3 ) )
						particleceleste:SetStartAlpha( 255 )
						particleceleste:SetEndAlpha( 0 )
						particleceleste:SetStartSize( math.Rand( 1, 2 ) )
						particleceleste:SetEndSize( 0 )
						particleceleste:SetAngles( Angle( 0, 0, 0 ) )
						particleceleste:SetRoll( 180 )
						particleceleste:SetRollDelta( 12 )
						particleceleste:SetColor( 129, 255, 255 )
						particleceleste:SetGravity( Vector( 0, 0, 100 ) )
						particleceleste:SetAirResistance( 10 )
						particleceleste:SetCollide( false )
						particleceleste:SetBounce( 0 )
					end
				end
				local particleceleste = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-15,15),math.random(-15,15),math.random(-15,15)))
				if particleceleste then
					particleceleste:SetLifeTime( 0 )
					particleceleste:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
					particleceleste:SetDieTime( 0.5 )
					particleceleste:SetStartAlpha( 255 )
					particleceleste:SetEndAlpha( 0 )
					particleceleste:SetStartSize( 75 )
					particleceleste:SetEndSize( 100 )
					particleceleste:SetColor( 129, 255, 255 )
					particleceleste:SetGravity( Vector( 0, 0, 0 ) )
					particleceleste:SetAirResistance( 10 )
					particleceleste:SetCollide( false )
					particleceleste:SetBounce( 0 )
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
				dlight.r = 129
				dlight.g = 255
				dlight.b = 255
				dlight.Brightness = 5
				dlight.Size = config.zone
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "heal_eff_smallceleste" )
end