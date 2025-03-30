
SWEP.PrintName = "Mana Zone Passif"
SWEP.Category = "Mana Zone Passif"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Author = "kake"
SWEP.Contact = "Deadlock-roleplay.net"
SWEP.Purpose = "'Omni shield from Mass Effect"


SWEP.HoldType			= "fist"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay = 1.1
SWEP.Primary.Ammo       = "none"

SWEP.Primary.ClipSize  = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic  = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = ""
SWEP.ViewModel = ""
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}

config.tmp = 10

config.cooldown = 70

function SWEP:Initialize()
	self:SetHoldType( "fist" )
	self.god = false
	self.delay = 0
	self.tmp = 0
	self.sec = 0
end

function SWEP:Think()
    if not IsValid(self) then return end
    if not SERVER then return end

    local own = self.Owner

    if own:KeyPressed(IN_ATTACK) and own:Alive() and not self.god and self.delay < CurTime() then
        own:GodEnable()
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Mana Zone Passif Actif !")
        self.god = true
        self.tmp = CurTime() + config.tmp

        self.countdownEndTime = CurTime() + config.tmp
        self.delay = CurTime() + config.cooldown
    end

    if own:KeyPressed(IN_ATTACK) and own:Alive() and not self.god and self.delay > CurTime() then
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Mana Zone passif désactivé, tu as " .. config.cooldown - config.tmp .. "s de cooldown !")
    end

    if self.god and self.tmp < CurTime() then
        self.god = false
        own:GodDisable()
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Mana Zone passif désactivé, tu as " .. config.cooldown - config.tmp .. "s de cooldown !")
    end

    if self.countdownEndTime and self.countdownEndTime > CurTime() and self.tmp > CurTime() then
        self.remainingTime = math.max(0, math.floor(self.countdownEndTime - CurTime()))
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Mana Zone Passif Actif : " .. self.remainingTime .. "s")
    end
end



function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end


function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	if SERVER then
        if self.god then
            timer.Simple(self.remainingTime,function()
                if self.Owner:Alive() then
                    self.Owner:GodDisable()
                    self.god = false
                end
            end)
        end
	end
	return true
end

function SWEP:OnDrop()
	if SERVER then
		self.Owner:GodDisable()
	end
end

function SWEP:OnRemove()
	if SERVER then
		self.Owner:GodDisable()
	end
end