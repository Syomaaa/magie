SWEP.PrintName 				= "Ténèbres 2"
SWEP.Slot 					= 1
SWEP.SlotPos 				= 0
SWEP.DrawAmmo 				= false
SWEP.DrawCrosshair 			= true

SWEP.Author					= "tomlap77"
SWEP.Instructions			= "N/A"
SWEP.Contact				= "N/A"
SWEP.Purpose				= ""
SWEP.Category				= "Ténèbres"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.HoldType 				= "normal"
SWEP.ViewModel 				= "models/weapons/c_arms.mdl"
SWEP.WorldModel 			= ""
SWEP.UseHands 				= true

SWEP.Primary.Delay			= 0.4
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "RPG_Round"

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0


function SWEP:Initialize()
	self:SetHoldType("magic")
end
 
function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		if SERVER then

			local zeub = ents.Create("prop_dynamic")
			self.Owner.sypzeub = zeub
			self:TakePrimaryAmmo(150)
			self.Owner:GodEnable()
			timer.Simple(0.2, function() 
				zeub:SetModel("models/alters/blindness/blindness_sphere.mdl")
				zeub:SetModelScale(0.6)
				zeub:SetPos(self.Owner:GetPos())
				zeub:SetAngles(Angle(0,0,0))

			end)
			
			timer.Simple(5, function() 
				if IsValid(zeub) then 
					zeub:Remove() 
				end 
				self.Owner:GodDisable()
				self.Owner.sypzeub = nil
				config.switch = true
			end)
		end
		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
		else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
end	
  
function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end