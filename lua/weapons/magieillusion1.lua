AddCSLuaFile()

SWEP.PrintName 		      = "Illusion 1" 
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
SWEP.HoldType             = "magie"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Illusion"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 20
config.dmg2 = 30 -- dmg de .. à ..

SWEP.Cooldown = 0.2
SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()
		local ang = Angle(180, own:EyeAngles().Yaw, 0)
		local pos = self.Owner:GetShootPos()+ own:EyeAngles():Forward()*30 + self.Owner:EyeAngles():Right() * 40*-0.60
		local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*50
		
		local illusion = ents.Create( "illusion" )
		illusion:SetPos( pos  )
		illusion:SetAngles( ang ) illusion:SetOwner( own )
		illusion:Spawn() illusion:Activate() own:DeleteOnRemove( illusion )
		illusion:GetPhysicsObject():SetVelocity( dir*10 )
		illusion:SetPhysicsAttacker( own )

		pos = self.Owner:GetShootPos() + own:EyeAngles():Forward()*30 + self.Owner:EyeAngles():Right() * 40*0.60

		local illusion2 = ents.Create( "illusion" )
		illusion2:SetPos( pos )
		illusion2:SetAngles( ang ) illusion2:SetOwner( own )
		illusion2:Spawn() illusion2:Activate() own:DeleteOnRemove( illusion2 )
		illusion2:GetPhysicsObject():SetVelocity( dir*10 )
		illusion2:SetPhysicsAttacker( own )
		illusion2:EmitSound( "weapons/fx/nearmiss/bulletLtoR03.wav" )

		pos = self.Owner:GetShootPos() + own:EyeAngles():Forward()*30

		local illusion3 = ents.Create( "illusion" )
		illusion3:SetPos( pos )
		illusion3:SetAngles( ang ) illusion3:SetOwner( own )
		illusion3:Spawn() illusion3:Activate() own:DeleteOnRemove( illusion3 )
		illusion3:GetPhysicsObject():SetVelocity( dir*10 )
		illusion3:SetPhysicsAttacker( own )
		illusion3:EmitSound( "weapons/fx/nearmiss/bulletLtoR03.wav" )

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "illusion"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/cards/card1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,255,255,255 ) )
		self:SetModelScale(5,0.1)
		self:GetPhysicsObject():SetMass( 0 )
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:illusionBreak( ppp )
		if self.XDEBZ_Hit or !isvector( ppp ) then return end local own = self.Owner
		self.XDEBZ_Hit = true self:EmitSound( "weapons/fx/nearmiss/bulletLtoR03.wav" )
		for k,v in pairs(ents.FindInSphere(ppp ,150)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
				dmginfo:SetDamagePosition( ppp )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
			end
		end
		SafeRemoveEntityDelayed( self, 0 )

		explo = ents.Create("env_explosion")
		explo:SetKeyValue("iMagnitude","0")
		explo:SetKeyValue("spawnflags","64")
		explo:SetPos(self:GetPos())
		explo:Spawn()
		explo:Fire("Explode",0,0)

	end
	function ENT:StartTouch( ent )
		if self.XDEBZ_Hit or ent:GetClass() == self:GetClass() or ent.XDEBZ_Gre then return end  local own = self.Owner
		if IsValid( own ) and own == ent then return end self:illusionBreak( self:GetPos() )
	end
	function ENT:PhysicsCollide( data, phys )
		if self.XDEBZ_Hit then return end  local own = self.Owner
		if IsValid( data.HitEntity ) and ( data.HitEntity:GetClass() == self:GetClass() or ( IsValid( own ) and own == data.HitEntity ) or data.HitEntity.XDEBZ_Gre ) then return end
		self:illusionBreak( data.HitPos + data.HitNormal*5 )
	end
	function ENT:Think() if !SERVER then return end
	if !self.XDEBZ_Hit then self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*50000 ) end end
	function ENT:OnTakeDamage( dmginfo ) if !self.XDEBZ_Hit then self:illusionBreak( self:GetPos() ) end end
	function ENT:OnTakeDamage( dmg ) end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "illusion_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "illusion" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.03
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-5,5),math.random(-5,5),math.random(-2,2)))
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
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()+ Vector(math.random(-5,5),math.random(-5,5),math.random(-2,2)) )
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
						particle2:SetColor( 255, 255, 255 )
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
	effects.Register( EFFECT, "illusion_effect" )
end