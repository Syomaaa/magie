AddCSLuaFile()

SWEP.PrintName 		      = "Vent 1" 
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

SWEP.Category             = "Vent"

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

config.nb = 20 -- nombre kunai
config.vitesse = 0.1 -- tmp que les kunai spawn 1 par 1 et s'envoient toute les .....s
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

		local ply = self.Owner
		timer.Create("speed"..self:EntIndex(),config.vitesse,config.nb, function()
			if IsValid(self) and self:GetOwner():Alive() then
				local lame = ents.Create("lame2")
				lame:SetOwner(ply)
				lame:SetPos(self.Owner:GetShootPos() + Vector(math.random(35,-35),math.random(35,-35),math.random(10,20)))
				lame:SetAngles(Angle(0,self.Owner:EyeAngles().Yaw+90,self.Owner:EyeAngles().r+90))
				lame:Spawn()
				lame:Activate()
			end
		end)
		
		timer.Simple(1, function()
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
	ENT.PrintName = "lame2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/touhou/bluekunai.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetColor( Color( 80,255,80,255 ) )
		self:SetParent(self.Owner)
		timer.Simple(config.tmp, function()
			if IsValid(self) and self:GetOwner():Alive() then
				self.speed = true
				local dir = self.Owner:GetAimVector()*(10000) + VectorRand():GetNormal()*5
				self:SetParent(nil)
				self:PhysicsInit( SOLID_VPHYSICS )
				self:SetMoveType( MOVETYPE_VPHYSICS )
				self:SetSolid( SOLID_VPHYSICS ) 
				self:GetPhysicsObject():EnableGravity( false )
				self:GetPhysicsObject():SetVelocity( dir )
				self:SetPhysicsAttacker( self.Owner) 
			end
		end)
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:StartTouch( ent )
		if self.XDEBZ_Hit or ent:GetClass() == self:GetClass() or ent.XDEBZ_Gre then return end  local own = self.Owner
		if IsValid( own ) and own == ent then return end self:LameBreak( self:GetPos() )
	end
	function ENT:PhysicsCollide( data, phys )
		if self.XDEBZ_Hit then return end  local own = self.Owner
		if IsValid( data.HitEntity ) and ( data.HitEntity:GetClass() == self:GetClass() or ( IsValid( own ) and own == data.HitEntity ) or data.HitEntity.XDEBZ_Gre ) then return end
		self:LameBreak( data.HitPos + data.HitNormal*4 )
		SafeRemoveEntityDelayed( self, 0 )
		self:EmitSound("weapons/fx/nearmiss/bulletLtoR06.wav", 65, math.Rand(30,60), 0.8)
	end
	function ENT:OnTakeDamage( dmginfo ) if !self.XDEBZ_Hit then self:LameBreak( self:GetPos() ) end end
	function ENT:OnTakeDamage( dmg ) end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "lame2_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
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
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  
	end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "lame2_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "lame2" )
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
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
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
						particle2:SetColor( 100, 255, 150 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=0, 1 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()+ Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)) )
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
						particle2:SetColor( 100, 255, 150 )
						particle2:SetGravity( Vector( 0, 0, 50 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=0,1 do
					local particle = self.Emitter:Add( "cloud/cloud", ent:WorldSpaceCenter()  )
					if particle then  local size = math.Rand( 1,2 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.1, 0.3 ) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 2 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6)
						particle:SetColor( 200, 220, 200 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 2 )
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
	effects.Register( EFFECT, "lame2_effect" )
end