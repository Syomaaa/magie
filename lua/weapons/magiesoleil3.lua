SWEP.PrintName = "Soleil 3"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Author			= "Brounix"
SWEP.Instructions	= ""
SWEP.Contact		= "N/A"
SWEP.Purpose		= ""
SWEP.Category		= "Soleil"

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.Primary.Cone				= 0
SWEP.Primary.ClipSize			= 0
SWEP.Primary.DefaultClip		= 0
SWEP.Primary.Automatic   		= false
SWEP.Primary.Ammo         		= "none"

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 350
config.dmg2 = 350 -- dmg de .. à ..
config.zone = 300

function SWEP:Initialize()
    self:SetHoldType( "magic" )
end

function SWEP:OnDrop()
	return false
end

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
		if SERVER then

				local own = self.Owner

				local f = Angle(-0,self.Owner:GetAngles().y,0):Forward()

				local entsoleil3 = ents.Create("soleil3")
				entsoleil3:SetPos(self.Owner:GetPos()+f*100)
				entsoleil3:SetOwner(self.Owner)
				entsoleil3:Spawn()

				for k,v in pairs(ents.FindInSphere(self.Owner:GetPos()+f*300 ,config.zone)) do
					if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_SHOCK )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( self:GetPos()  )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end  

				timer.Create("Lorazi_soleil_3"..entsoleil3:EntIndex(), 0.05, 200, function ()
	                if entsoleil3:IsValid() then
	                    entsoleil3:SetPos(entsoleil3:GetPos()+f*35)
	                end
	            end)
		end
		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end


function SWEP:Reload()
end

function SWEP:SecondaryAttack()
end 

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "Soleil3"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/XQM/Rails/gumball_1.mdl")
			self:PhysicsInit(SOLID_NONE)      -- Make us work with physics,
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetCollisionGroup( COLLISION_GROUP_WEAPON ) 
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
			end
			SafeRemoveEntityDelayed(self,2)
			local idx = "soleil3"..self:EntIndex()
			timer.Create(idx,0.03,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffect("[3]_blue_sky",self:GetPos() + Vector(math.random(-100,100),math.random(-100,100),math.random(0,20)),Angle(0,0,0), self )

				else
					timer.Remove(idx)
				end
			end)
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true

				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "soleil3" )
end