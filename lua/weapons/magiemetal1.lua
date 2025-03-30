AddCSLuaFile()

SWEP.PrintName 		      = "Metal 1" 
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

SWEP.Category             = "Metal"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 35
config.dmg2 = 50  -- dmg de .. à ..

config.hitbox = 100
config.zone = 150

SWEP.Cooldown = 0.2

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

-- !!!!!!!!!! https://steamcommunity.com/sharedfiles/filedetails/?id=711546112 !!!!!!!!!!!!

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end


-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		if SERVER then

			local own = self:GetOwner()
			local ang = Angle(0, own:EyeAngles().Yaw, 0)
			local pos = own:GetShootPos() - Vector(0,0,5) + ang:Forward() * 6,10
			local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

			local metalone = ents.Create( "metal1" )
			metalone:SetPos( pos )
			metalone:SetAngles( ang ) 
			metalone:SetOwner( own )
			metalone:Spawn() 
			metalone:Activate() 
			own:DeleteOnRemove( metalone )
			metalone:GetPhysicsObject():SetVelocity( dir )
			metalone:SetPhysicsAttacker( own )
			
			metalone:EmitSound("physics/metal/metal_barrel_impact_hard5.wav", 65, math.Rand(130,160), 0.8)

		end

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
	local toy = {
		"models/nuns - small weapons pack/models/mace/mace.mdl",
		"models/nuns - small weapons pack/models/demon wind shuriken/demon wind shuriken b/demon wind shuriken b.mdl",
		"models/nuns - small weapons pack/models/hiraishin kunai/hiraishin kunai i/hiraishin kunai i.mdl",
		"models/nuns - small weapons pack/models/demon wind shuriken/demon wind shuriken a/demon wind shuriken a.mdl"
	} 
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "metal1"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.Effect = false  ENT.Hit = false  ENT.Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( toy[ math.random( #toy ) ] )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:GetPhysicsObject():EnableGravity( false )
		local idx = "lumiere1"..self:EntIndex()
		timer.Create(idx,0.01,1,function()
			if IsValid(self) then
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetScale(1)
				effectdata:SetEntity(self)
				ParticleEffectAttach( "[*]_dash", 1, self, 1 )
			end
		end)
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
		self.Hit = true
	end
	function ENT:Think() if !SERVER then return end
		if !self.Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*3000 ) 
		end 

		local own = self.Owner

		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) then
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0.2 )
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
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end  
		end
	end
	scripted_ents.Register( ENT, "metal1" )
end