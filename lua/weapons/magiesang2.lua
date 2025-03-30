SWEP.PrintName 		      = "Sanguinaire 2" 
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

SWEP.Category             = "Sanguinaire"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 200
config.dmg2 = 200  -- dmg de .. à ..

config.hitbox = 300
config.zone = 300

SWEP.Cooldown = 10

config.addVie = 100 -- vie en plus par touché
config.delVie = 0 -- vie en moins par attaque

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

		if SERVER then

			local own = self:GetOwner()
			local ang = Angle(0, own:EyeAngles().Yaw, 0)
			local pos = own:GetShootPos() - Vector(0,0,25) + ang:Forward() * 10,10
			local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

			local sanguinaire2 = ents.Create( "sanguinaire2" )
			sanguinaire2:SetPos( pos )
			sanguinaire2:SetAngles( ang ) 
			sanguinaire2:SetOwner( own )
			sanguinaire2:Spawn() 
			sanguinaire2:Activate() 
			own:DeleteOnRemove( sanguinaire2 )
			sanguinaire2:GetPhysicsObject():SetVelocity( dir )
			sanguinaire2:SetPhysicsAttacker( own )
			sanguinaire2:EmitSound("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav", 60, 160, 0.6)

			if self.Owner:Health()-config.delVie<=0 then
				self.Owner:Kill()
			end

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

function SWEP:OnDrop()
	return false
end

function SWEP:Holster()
	return true
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "Sanguinaire2"
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
			self.cd = 0
			self.Owner:SetHealth(self.Owner:Health()-config.delVie)
			local idx = "sanguinaire2"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "[16]_slash_chaos", 1, self, 1 )
				else
					timer.Remove(idx)
				end
			end)
			SafeRemoveEntityDelayed(self,3)
		end
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.1 )
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
					if v:IsPlayer() and v != own and self.Owner:Health()+config.addVie<self.Owner:GetMaxHealth() then
						self.Owner:SetHealth(self.Owner:Health()+config.addVie)
					end
					if v:IsNPC() and v != own and self.Owner:Health()+config.addVie<self.Owner:GetMaxHealth() then
						self.Owner:SetHealth(self.Owner:Health()+config.addVie)
					end
				end
			end  
		end
	end

	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*3000 ) 
		end 

		local own = self.Owner

        for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0.2 )
			end
		end  
		self:NextThink( CurTime() ) return true
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "sanguinaire2" )
end