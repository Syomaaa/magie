AddCSLuaFile()

SWEP.PrintName 		      = "Astral 4" 
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

SWEP.Category             = "Astral"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 60
config.dmg2 = 60

config.dmgexplo1 = 500
config.dmgexplo2 = 500

config.tmp = 5

config.hitbox = 250
config.zone = 300

SWEP.Cooldown = 20

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

SWEP.cooldownDelayDash = 0
SWEP.cooldownDash = 10

--------------------------------------------------------------------------------------------------------------

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

	self:SetNextPrimaryFire(CurTime()+0.2)

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

	for k,v in pairs(ents.FindInSphere(self:GetPos() + self:GetForward()*75 ,175)) do
		if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_GENERIC  )
			dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
			dmginfo:SetDamagePosition( self:GetPos()  )
			dmginfo:SetAttacker( self.Owner )
			dmginfo:SetInflictor( self.Owner )
			v:TakeDamageInfo(dmginfo)

			self:EmitSound(HitSound)
		end
	end  

    return true

end

function SWEP:SecondaryAttack(right)

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
		local pos = own:GetShootPos() - Vector(0,0,25) + ang:Forward() * 10,10
		local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

		local fist = ents.Create( "astral4" )
		fist:SetPos( pos )
		fist:SetOwner( own )
		fist:SetAngles(ang)
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

function SWEP:Deploy()

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
	vm:SetPlaybackRate( speed )

	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:UpdateNextIdle()

	self.trail = ents.Create("astral4fist")
	self.trail:SetPos(self:GetPos())
	self.trail:SetAngles(self:GetAngles())
	self.trail:SetParent(self.Owner)
	self.trail:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.trail:Spawn() 
	self.trail:Activate()
	self.Owner:DeleteOnRemove( self.trail)

	if ( SERVER ) then
		self:SetCombo( 0 )
	end

	return true

end

function SWEP:Holster()
	SafeRemoveEntity(self.trail)
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


		self:SetNextMeleeAttack( 0 )

	end

	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then

		self:SetCombo( 0 )

	end

	if self.Owner:KeyDown( IN_USE ) and self.Owner:IsOnGround() and not self.Owner:KeyDown( IN_ATTACK ) and CurTime() >= self.cooldownDelayDash then
		if IsValid(self) then
			self.Owner:SetVelocity(self.Owner:GetForward() * 1000 )
			self.cooldownDelayDash = CurTime() + self.cooldownDash
		end
	end
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "astral4"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end

			ParticleEffect("aes_spawer2",self:GetPos(),Angle(0,0,0))

			ParticleEffectAttach( "aes_roll_price", 1, self, 1 )

			ParticleEffectAttach( "aes_big", 1, self, 1 )
			

			SafeRemoveEntityDelayed(self,2)
		end
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think() if !SERVER then return end
		local own = self.Owner

		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  

		self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then

			ParticleEffect("aes_remove",self:GetPos(),Angle(0,0,0))

			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
                if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmgexplo1,config.dmgexplo2) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end  
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "astral4" )
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_gmodentity"
	ENT.PrintName = "astral4fist"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
			end

			ParticleEffectAttach( "aes_tage", 1, self, 1 )

		end
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawShadow( false )
		end
	end
	scripted_ents.Register( ENT, "astral4fist" )
end