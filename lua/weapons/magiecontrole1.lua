AddCSLuaFile()

SWEP.PrintName 		      = "Contrôle 1" 
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

SWEP.Category             = "Contrôle"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.Cooldown = 2

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 20
config.dmg2 = 20  -- dmg de .. à ..
config.nb = 20 -- nombre pierre
config.vitesse = 0.1 -- tmp que les pierres spawn 1 par 1 et s'envoient toute les .....s
config.tmp = 0.2 -- tmp avant qu'ils s'envoient

--------------------------------------------------------------------------------------------------------------


function SWEP:Initialize()
	self:SetHoldType("magic")
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		config.switch = false

		local own = self.Owner

		self.base = ents.Create( "base_pierre" )
		self.base:SetPos( own:GetPos() + Vector( 0, 0, -20 ) ) 
		self.base:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
		self.base:SetOwner( own ) 
		self.base:Spawn() 
		self.base:Activate() 

		config.base = self.base
		
		
		timer.Simple(config.tmp, function()
			config.switch = true
		end)

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

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
	ENT.PrintName = "base"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/rock/scattersmooth_04.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetColor(Color(10,10,10))
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetParent(self.Owner)
		timer.Create("speed"..self:EntIndex(),config.vitesse,config.nb, function()
			if IsValid(self) and self:GetOwner():Alive() then
				self.pierre = ents.Create("pierre")
				self.pierre:SetOwner(self.Owner)
				self.pierre:SetPos(self:GetPos() + Vector(math.random(80,-80),math.random(80,-80),math.random(-10,10)))
				self.pierre:SetAngles(Angle(0,0,90))
				self.pierre:Spawn()
				self.pierre:Activate()
				
			end
		end)
		timer.Simple(config.tmp/2,function()
			timer.Create("up"..self:EntIndex(),0.01,50, function()
				if IsValid(self) and self:GetOwner():Alive() then
					self:SetPos(self:GetPos() + Vector(0,0,2))
				end
			end)
		end)
		SafeRemoveEntityDelayed( self, 5 )
	end
	if CLIENT then
		function ENT:Draw()
		end
	end
	scripted_ents.Register( ENT, "base_pierre" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "grass"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/rock/scattersmooth_04.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetModelScale( 0.4, 0 )
		self:SetParent(config.base)
		timer.Simple(config.tmp, function()
			if IsValid(self) and self:GetOwner():Alive() then
				self.speed = true
				local dir = self.Owner:GetAimVector()*(10000)
				self:SetAngles(Angle(self.Owner:EyeAngles().x+90,self.Owner:EyeAngles().Yaw,self.Owner:EyeAngles().r+90))
				self:SetParent(nil)
				self:PhysicsInit( SOLID_VPHYSICS )
				self:SetMoveType( MOVETYPE_VPHYSICS )
				self:SetSolid( SOLID_VPHYSICS ) 
				self:GetPhysicsObject():EnableGravity( false )
				self:GetPhysicsObject():SetVelocity( dir)
				self:SetPhysicsAttacker( self.Owner) 
				self:EmitSound("weapons/fx/nearmiss/bulletLtoR06.wav", 70, math.Rand(30,40), 0.8)
			end
		end)
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:PhysicsCollide( data, phys )
		SafeRemoveEntityDelayed( self, 0.1 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit && self.speed then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*10000 ) 
		end 
		local own = self:GetOwner()
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,150)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
				SafeRemoveEntityDelayed( self, 0.1 )
			end
		end  
	end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "pierre_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "pierre" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.05
				for i=0,1 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)))
					if particle2 then  local size = math.Rand( 3, 6 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.2 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 50, 50, 50 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=0, 1 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()+ Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.2) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 3 )
						particle2:SetEndSize( 3 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor(  50, 50, 50  )
						particle2:SetGravity( Vector( 0, 0, 50 ) )
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
	effects.Register( EFFECT, "pierre_eff" )
end