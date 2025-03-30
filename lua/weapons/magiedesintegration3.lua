game.AddParticles("particles/firemagic01.pcf")
PrecacheParticleSystem("asplode_hoodoo_debris")

if SERVER then
    AddCSLuaFile()
end

SWEP.Spawnable = true 
SWEP.AdminOnly = false 

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false 
SWEP.DrawCrosshair = true
SWEP.Category = "Désintégration"
SWEP.PrintName = "Désintégration 3"

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
SWEP.HoldType = "magic"

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {
    intervalDmgPoi = 0.5, -- interval entre chaque dgt poison
    dmgPoi1 = 35, -- dgt poison entre .. et ..
    dmgPoi2 = 35,
    nb = 1 -- nb de fois que le poison touche
}

local function PoisonDmg(ent, num, attacker)
    local timerName = "DMGPOISON" .. ent:EntIndex()
    
    if not timer.Exists(timerName) then
        timer.Create(timerName, config.intervalDmgPoi, num, function()
            if IsValid(ent) then
                ent:TakeDamage(math.random(config.dmgPoi1, config.dmgPoi2), attacker, DMG_ACID)
            else
                timer.Remove(timerName)
            end
        end)
    end
end

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay < CurTime() then
        if not SERVER then return end

        local ply = self:GetOwner()
        local plyPos = ply:GetPos()
        local coef = 1

        timer.Create("desintegrationEffect/" .. math.random(0, 100000) * 10, 0.1, 10, function()
            local effectPos = plyPos + ply:GetForward() * 100 * coef
            ParticleEffect("dskart_deathsplosion_ash", effectPos, Angle(0, 0, 0))
            
            if SERVER then
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamage(75)
                dmgInfo:SetAttacker(ply)
                dmgInfo:SetInflictor(self)
                dmgInfo:SetDamageType(DMG_DISSOLVE)
                
                for _, ent in ipairs(ents.FindInSphere(effectPos, 300)) do
                    if ent:IsPlayer() and ent ~= ply then
                        ent:TakeDamageInfo(dmgInfo)
                        PoisonDmg(ent, config.nb, ply)
                    end
                end
            end
            
            coef = coef + 1
        end)

        self.CooldownDelay = CurTime() + self.Cooldown
        self.NextAction = CurTime() + self.ActionDelay
    else
            self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown .. "s de cooldown !")
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Initialize()
    self:SetHoldType("magic")
end