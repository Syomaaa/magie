AddCSLuaFile()
SWEP.HoldType = "magic"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Category = "Spirit"
SWEP.PrintName = "Spirit 3"
SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 54
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

function SWEP:SetupDataTables()
end

function SWEP:CanSecondaryAttack()
    return false
end

function SWEP:Initialize()
end

function SWEP:Deploy()
    if SERVER then
        hook.Add("Tick", "CheckEnergyStorm:" .. self.Owner:SteamID64(), function()
            if self.Owner:GetActiveWeapon():GetClass() ~= "weapon_energystorm" then return end

            if self.Owner:KeyPressed(IN_ATTACK) then
                if IsValid(self.storm) then return end
                self.storm = ents.Create("ig_energystorm")
                self.storm:Spawn()
                self.storm:Activate()
                self.storm:SetOwner(self.Owner)
                self.storm:SetPos(self.Owner:EyePos())
            end

            if self.Owner:KeyReleased(IN_ATTACK) and IsValid(self.storm) then
                self.storm:Remove()
                self.storm = nil
            end
        end)
    end
end

function SWEP:Holster(wep)
    if not IsFirstTimePredicted() then return end

    if SERVER then
        hook.Remove("Tick", "CheckEnergyStorm:" .. self.Owner:SteamID64())
    end

    return true
end

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
	    
	    if not IsFirstTimePredicted() then return end

        if SERVER then
            hook.Add("Tick", "CheckEnergyStorm:" .. self.Owner:SteamID64(), function()

                if self.Owner:KeyPressed(IN_ATTACK) and self.CooldownDelay < CurTime() then
                    if IsValid(self.storm) then return end
                    self.storm = ents.Create("ig_energystorm")
                    self.storm:Spawn()
                    self.storm:Activate()
                    self.storm:SetOwner(self.Owner)
                    self.storm:SetPos(self.Owner:EyePos())
                    self.CooldownDelay = CurTime() + self.Cooldown
                    self.NextAction = CurTime() + self.ActionDelay
                elseif self.Owner:KeyPressed(IN_ATTACK) and self.CooldownDelay > CurTime() then
                    self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
                end

                if self.Owner:KeyReleased(IN_ATTACK) and IsValid(self.storm) then
                    self.storm:Remove()
                    self.storm = nil
                    self.CooldownDelay = CurTime() + self.Cooldown
                    self.NextAction = CurTime() + self.ActionDelay
                end
            end)
        end
       
    return true
end