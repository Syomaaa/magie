SWEP.PrintName 		      = "Etoile 1" 
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

SWEP.Category             = "Etoile"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 50
config.dmg2 = 50  -- dmg de .. à ..

config.hitbox = 150
config.zone = 200

SWEP.Cooldown = 0.5

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

SWEP.Cooldown3 = 10
SWEP.ActionDelay3 = 0.2
SWEP.NextAction3 = 0
SWEP.CooldownDelay3 = 0

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
			local ang = Angle(own:EyeAngles().x, own:EyeAngles().y, math.random(20,160))
			local pos = own:GetShootPos() - Vector(0,0,25) + ang:Forward() * 10,10
			local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

			local etoile1 = ents.Create( "etoile1" )
			etoile1:SetPos( pos )
			etoile1:SetAngles( ang ) 
			etoile1:SetOwner( own )
			etoile1:Spawn() 
			etoile1:Activate() 
			own:DeleteOnRemove( etoile1 )
			etoile1:GetPhysicsObject():SetVelocity( dir )
			etoile1:SetPhysicsAttacker( own )

		end

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

function SWEP:Reload()
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	if self.NextAction3 > CurTime() then return end
    if self.CooldownDelay3 < CurTime() then if !SERVER then return end

   self.Owner:SetVelocity(self.Owner:GetForward() * 500 )

   self.CooldownDelay3 = CurTime() + self.Cooldown3
   self.NextAction3 = CurTime() + self.ActionDelay3
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown3 .."s de cooldown !" )
	end
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "etoile1"
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
			local idx = "etoile"..self:EntIndex()
			timer.Create(idx,0.01,0,function()
				if IsValid(self) then
					ParticleEffect( "[1]_light_flash", self:GetPos()+Vector(math.random(-150,150),math.random(-150,150),math.random(-150,150)),Angle(0,0,0), self )
					self:EmitSound("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav", 60, 160, 0.6)
				else
					timer.Remove(idx)
				end
			end)
			SafeRemoveEntityDelayed(self,3)
		end
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think() if !SERVER then return end
	
		self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*3000 ) 

		local own = self.Owner

		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
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
	scripted_ents.Register( ENT, "etoile1" )
end