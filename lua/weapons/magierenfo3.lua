AddCSLuaFile()

SWEP.PrintName 		      = "Renforcement 3" 
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
config.dmg1 = 350 -- dgt touche entre .. et ..
config.dmg2 = 350
config.zone = 500
config.push = 300
config.hitbox = 300

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )


--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "fist" )
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

function SWEP:PrimaryAttack(right)

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		local anim = "fists_left"
		if ( right ) then anim = "fists_right" end
		if ( self:GetCombo() >= 2 ) then
			anim = "fists_uppercut"
		end

		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )

		self:EmitSound( SwingSound )

		self:UpdateNextIdle()

		local own = self:GetOwner()
		local ang = Angle(0, own:EyeAngles().Yaw, 0)
		local pos = own:GetShootPos() - Vector(0,0,5) + ang:Forward() * 10,10
		local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

		local fist = ents.Create( "superfist" )
		fist:SetPos( pos )
		fist:SetOwner( own )
		fist:Spawn() 
		fist:Activate()
		own:DeleteOnRemove( fist )
		fist:GetPhysicsObject():SetVelocity( dir/10 )
		fist:SetPhysicsAttacker( own )

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Deploy()

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

end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "superfist"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/blocks/cube05x6x05.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetTrigger( true )
		self:SetAngles(Angle(self.Owner:GetAngles().x ,self.Owner:GetAngles().y,0))
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 0.8 )
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		end 

		local own = self.Owner

		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) then
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then
			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end
			local ex = EffectData()
			ex:SetOrigin(self:WorldSpaceCenter())
			util.Effect("wall",ex) 
	
			local physExplo = ents.Create( "env_physexplosion" )
			physExplo:SetPos( self:GetPos() )
			physExplo:SetKeyValue( "magnitude", config.push )
			physExplo:SetKeyValue( "radius", config.zone* 3)
			physExplo:SetKeyValue( "spawnflags", "2" )
			physExplo:Spawn()
			physExplo:Fire( "Explode", "", 0 )
	
			self.Shake = ents.Create( "env_shake" )
			self.Shake:SetPos( self:GetPos() )
			self.Shake:SetKeyValue( "amplitude", "4" )
			self.Shake:SetKeyValue( "radius", config.zone*3 )
			self.Shake:SetKeyValue( "duration", "2" )
			self.Shake:SetKeyValue( "frequency", "255" )
			self.Shake:SetKeyValue( "spawnflags", "4" )
			self.Shake:Spawn()
			self.Shake:Activate()
			self.Shake:Fire( "StartShake", "", 0 )

			sound.Play( "ambient/explosions/explode_2.wav",  self:GetPos() , 80, 120 , 0.5) 
		end
	end
	if CLIENT then
		function ENT:Draw()
			
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "superfist_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "superfist" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.06
				
					local particle = self.Emitter:Add( "poing2", ent:WorldSpaceCenter() )
					if particle then
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.8,1.2 ) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 10 )
						particle:SetStartSize( 0 )
						particle:SetEndSize( 2000 )
						particle:SetAngles( Angle( math.random(0,360), math.random(0,360), 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 0 )
						particle:SetColor( 160, 160, 160 )
						particle:SetGravity( Vector( 0, 0, 50 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				
				for i=1,3 do
					local particle = self.Emitter:Add( "poing4", ent:WorldSpaceCenter() )
					if particle then
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.8,1.2) )
						particle:SetStartAlpha( 20 )
						particle:SetEndAlpha( 2 )
						particle:SetStartSize( 0 )
						particle:SetEndSize( 1500 )
						particle:SetAngles( Angle( math.random(0,360), math.random(0,360), 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 0 )
						particle:SetColor( 255, 255, 255 )
						particle:SetGravity( Vector( 0, 0, 50 ) )
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
	effects.Register( EFFECT, "superfist_effect" )
end