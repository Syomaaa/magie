AddCSLuaFile()

SWEP.PrintName 		      = "Renforcement 4" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 54
SWEP.UseHands = true
SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel   	= ""
SWEP.AutoSwitchTo 	      = false 
SWEP.AutoSwitchFrom       = true 
SWEP.DrawAmmo             = false 
SWEP.Base                 = "weapon_base" 
SWEP.Slot 			      = 2
SWEP.SlotPos              = 1 
SWEP.HoldType             = "fist"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Renforcement"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 40 -- dgt touche entre .. et ..
config.dmg2 = 40
config.zone = 300
config.push = 0  -- hit de lattaque zone ...
config.slow = 1 -- nombre de fois que la vitesse est divisée en attaquant

SWEP.Cooldown = 1

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )


--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "fist" )
	self.inUse = false
end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Int", 2, "Combo" )

end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )

end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	return true
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Deploy()
	self.Nextatck = 0

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
	vm:SetPlaybackRate( speed )

	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:UpdateNextIdle()

	if ( SERVER ) then
		self:SetCombo( 0 )
	end

	return true

end

function SWEP:Think()

	if SERVER then
		if self.Owner:KeyDown(IN_ATTACK) then  if !SERVER then return end
			if self.Nextatck < CurTime() then
			
				local own = self:GetOwner()

				if !self.inUse then
					own:SetRunSpeed( own:GetRunSpeed()/config.slow)
					own:SetWalkSpeed(own:GetWalkSpeed()/config.slow)
					self.inUse = true
				end
				
				self.Nextatck = CurTime() + 0.1
				

				local anim = "fists_left"
				if ( right ) then anim = "fists_right" end
				if ( self:GetCombo() >= 2 ) then
					anim = "fists_uppercut"
				end

				local vm = self.Owner:GetViewModel()
				vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )

				self:EmitSound( SwingSound )

				self:UpdateNextIdle()

				local ang = Angle(0, own:EyeAngles().Yaw, 0)
				local pos = own:GetShootPos() - Vector(0,0,math.random(-10,30)) + ang:Forward() * 25+ ang:Right()*(math.random(-20,20)),10
				local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*600
				
				local fist = ents.Create( "combofist" )
				fist:SetPos( pos )
				fist:SetOwner( own )
				fist:Spawn() 
				fist:Activate()
				own:DeleteOnRemove( fist )
				fist:GetPhysicsObject():SetVelocity( dir/10 )
				fist:SetPhysicsAttacker( own )
				local vm = self.Owner:GetViewModel()
				vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				self:EmitSound( SwingSound )
			
				self:UpdateNextIdle()
				self:EmitSound( SwingSound )
			end
		end
		if self.Owner:KeyReleased(IN_ATTACK) then
			if self.inUse then
				local own = self:GetOwner()
				own:SetRunSpeed( own:GetRunSpeed()*config.slow)
				own:SetWalkSpeed(own:GetWalkSpeed()*config.slow)
				self.inUse = false
			end
		end
	end

	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()

	if ( idletime > 0 && CurTime() > idletime ) then

		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )

		self:UpdateNextIdle()

	end

	local meleetime = self:GetNextMeleeAttack()

	if ( meleetime > 0 && CurTime() > meleetime ) then

		self:DealDamage()

		self:SetNextMeleeAttack( 0 )

	end

	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then

		self:SetCombo( 0 )

	end
	return true
end

function SWEP:Holster()
	if self.inUse then
		local own = self:GetOwner()
		own:SetRunSpeed( own:GetRunSpeed()*config.slow)
		own:SetWalkSpeed(own:GetWalkSpeed()*config.slow)
		self.inUse = false
	end
	return true
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "Fist"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/right_boxing_glove.mdl" )
		self:SetMaterial( "models/boxing_gloves_blue" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale(2,0.1)
		self:SetTrigger(true)
		self:SetAngles(Angle(self.Owner:GetAngles().x,self.Owner:GetAngles().y+90,self.Owner:GetAngles().z+305))
		self:SetColor(Color(255,255,255,160))
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 0.3 )
		util.SpriteTrail( self, 0, Color( 140, 140, 255 ), false, 20, 0.1, 4, 1 / ( 15 + 1 ) * 0.5, "trails/plasma" )
	end
	function ENT:FistBreak( ppp )
		if self.XDEBZ_Hit or !isvector( ppp ) then return end local own = self.Owner
		self.XDEBZ_Hit = true
		
		for k,v in pairs(ents.FindInSphere(ppp ,config.zone)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
				dmginfo:SetDamagePosition( ppp )
				v:AddEFlags("-2147483648" )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
				v:RemoveEFlags("-2147483648" )
			end
		end

		local physExplo = ents.Create( "env_physexplosion" )
		physExplo:SetPos( self:GetPos() )
		physExplo:SetKeyValue( "magnitude", config.push )
		physExplo:SetKeyValue( "radius", config.zone* 3)
		physExplo:SetKeyValue( "spawnflags", "2" )
		physExplo:Spawn()
		physExplo:Fire( "Explode", "", 0 )

		util.ScreenShake( self.Owner:GetPos(), 2, 7, 1, 200)
	
		self:EmitSound( HitSound,   100, 100) 
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.1 )
	end
	function ENT:StartTouch( ent )
		if self.XDEBZ_Hit or ent:GetClass() == self:GetClass() or ent.XDEBZ_Gre then return end  
		local own = self.Owner
		if IsValid( own ) and own == ent then return end 
		self:FistBreak( self:GetPos() )
	end
	function ENT:PhysicsCollide( data, phys )
		if self.XDEBZ_Hit then return end  local own = self.Owner
		if IsValid( data.HitEntity ) and ( data.HitEntity:GetClass() == self:GetClass() or ( IsValid( own ) and own == data.HitEntity ) or data.HitEntity.XDEBZ_Gre ) then return end
		self:FistBreak( data.HitPos + data.HitNormal*5 )
	end
	function ENT:Think() self:NextThink( CurTime() ) if !SERVER then return end
		self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*300 ) 
		return true
	end
	function ENT:OnRemove()
		
	end
	function ENT:OnTakeDamage( dmginfo ) if !self.XDEBZ_Hit then self:FistBreak( self:GetPos() ) end end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "combofist_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "combofist" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.15
				
					local particle = self.Emitter:Add( "poing2", ent:WorldSpaceCenter() )
					if particle then
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.4,0.8 ) )
						particle:SetStartAlpha( 180 )
						particle:SetEndAlpha( 20 )
						particle:SetStartSize( 10 )
						particle:SetEndSize( 50 )
						particle:SetAngles( Angle( math.random(0,360), math.random(0,360), 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 0.1 )
						particle:SetColor( 200, 200, 200 )
						particle:SetGravity( Vector( 0, 0, 50 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				

					local particle = self.Emitter:Add( "poing3", ent:WorldSpaceCenter() )
					if particle then
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.4,0.8) )
						particle:SetStartAlpha( 80 )
						particle:SetEndAlpha( 2 )
						particle:SetStartSize( 10 )
						particle:SetEndSize( 40 )
						particle:SetAngles( Angle( math.random(0,360), math.random(0,360), 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 0.1 )
						particle:SetColor( 200, 200, 255 )
						particle:SetGravity( Vector( 0, 0, 50 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end

			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()
		
	end
	effects.Register( EFFECT, "combofist_effect" )
end