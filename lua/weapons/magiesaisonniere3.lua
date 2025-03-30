AddCSLuaFile()

SWEP.PrintName 		      = "Saisonniere 3" 
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

SWEP.Category             = "Saisonniere"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.addVie = 35  -- regene tout le temps
config.zone = 125
config.vitesseRegene = 0.5  -- interval regene 
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

		if !IsValid( healsaison ) then 
			local healsaison = ents.Create( "healsaison_continue" )

			local tra = util.TraceLine( {
				start = own:EyePos(), 
				endpos = own:EyePos() + own:EyeAngles():Forward()*2000,
				ask = MASK_NPCWORLDSTATIC, 
				filter = { self, own }
			} )  

			healsaison:SetPos( tra.HitPos ) 
			healsaison:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
			healsaison:SetOwner( own ) 
			healsaison:Spawn() 
			healsaison:Activate() 
			self:DeleteOnRemove( healsaison )
			healsaison:EmitSound("weapons/physcannon/energy_bounce2.wav", 75,math.random(60,80))
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

		if !IsValid( healsaison ) then 
			local healsaison = ents.Create( "healsaison_continue" )
			healsaison:SetPos( own:GetPos() ) 
			healsaison:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
			healsaison:SetOwner( own ) 
			healsaison:Spawn() 
			healsaison:Activate() 
			self:DeleteOnRemove( healsaison )
			healsaison:EmitSound("weapons/physcannon/energy_bounce2.wav", 75,math.random(60,80))
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
	ENT.PrintName = "Cloudsaison1"
	ENT.Spawnable = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetColor(Color(127,255,255))
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		self:SetModelScale(0,0)
		self:SetModelScale(config.zone/83.3,0.7)
		SafeRemoveEntityDelayed( self, 1 )
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
			if (v:IsPlayer() or v:IsNPC()) && IsValid(v) then
				local effsaison = ents.Create( "effsaison_heal" )
				effsaison:SetPos( v:GetPos() + Vector(0,0,15) ) 
				effsaison:SetParent(v)
				effsaison:Spawn() 
				effsaison:Activate()
			end
		end

		local idx = "soinsaison3"..self:EntIndex()
		timer.Create(idx,0.01,1,function()
			if IsValid(self) then
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetScale(1)
				effectdata:SetEntity(self)
				ParticleEffectAttach( "[9]_bubble_sphere", 1, self, 1 )
			end
		end)
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.Effect then self.Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "healsaison_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "healsaison_continue" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "Cloudsaison2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  ENT.Tars = {}  ENT.NextAtk = 0
	ENT.Effect = false  ENT.Gre = 1  ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetColor(Color(127,255,255))
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
				ParticleEffectAttach( "[9]_bubble_sphere", 1, self, 1 )
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
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "healsaison_eff_small", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "effsaison_heal" )
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
						particle:SetColor( 71, 85, 255 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100))
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
						particle:SetColor( 71, 85, 255 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
					particle:SetDieTime( 0.5 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 75 )
					particle:SetEndSize( 100 )
					particle:SetColor( 71, 85, 255 )
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
				dlight.r = 0
				dlight.g = 255
				dlight.b = 127
				dlight.Brightness = 5
				dlight.Size = config.zone*3
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "healsaison_eff" )
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
						particle:SetColor( 71, 85, 255 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 30 ) + Vector(math.random(-30,30),math.random(-30,30),math.random(-30,30))
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
						particle:SetColor( 71, 85, 255 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-15,15),math.random(-15,15),math.random(-15,15)))
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
					particle:SetDieTime( 0.5 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 75 )
					particle:SetEndSize( 100 )
					particle:SetColor( 71, 85, 255 )
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
				dlight.r = 0
				dlight.g = 255
				dlight.b = 127
				dlight.Brightness = 5
				dlight.Size = config.zone
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "healsaison_eff_small" )
end