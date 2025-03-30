AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local ents_Create = ents.Create
local timer_Simple = timer.Simple

function SWEP:Initialize()
    local ply = self:GetOwner()
    self:SetHoldType("magic")
end

function SWEP:PrimaryAttack()
    if not (IsValid(self)) then return end
    local ply = self:GetOwner()
    local ct = CurTime()
    if ct < self.NextFire then ply:PrintMessage(HUD_PRINTCENTER, "Tu as ".. self.Cooldown .. "s de cooldown !") return end

    self.NextFire = ct + self.Cooldown
    if ply:IsOnGround() then
        self:SpawnIcespike(4)
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:SpawnIcespike(size)
    local ply = self:GetOwner()
    local pos = ply:GetShootPos()   
    local aim = ply:GetAimVector() * 70

    local fre = ents_Create("gf_effect_dmg")
    fre:SetPos(ply:GetPos() + ply:GetForward() * 150)
    fre:SetModelScale(10, 0.2)
    fre:SetAngles(Angle(0,ply:EyeAngles().y + 75,0))
    fre:SetOwner(ply)
    fre:Spawn()
    timer_Simple(0.2, function()
        fre:Activate()
    end)
    
    timer_Simple(0.1, function()
        local fre1 = ents_Create("gf_effect_dmg")
        fre1:SetPos(fre:GetPos() + ply:GetForward() * 50)
        fre1:SetModelScale(fre:GetModelScale(), 1)
        fre1:SetAngles(Angle(0,ply:EyeAngles().y + 75,0))
        fre1:SetOwner(ply)
        fre1:Spawn()
        timer_Simple(0.2, function()
            fre1:Activate()
        end)
    end)

    timer_Simple(0.2, function()
        local fre2 = ents_Create("gf_effect_dmg")
        fre2:SetPos(fre:GetPos() + ply:GetForward() * 100)
        fre2:SetModelScale(fre:GetModelScale(), 0.2)
        fre2:SetAngles(Angle(0,ply:EyeAngles().y + 75,0))
        fre2:SetOwner(ply)
        fre2:Spawn()
        timer_Simple(0.2, function()
            fre2:Activate()
        end)
    end)

    timer_Simple(0.3, function()
        local fre3 = ents_Create("gf_effect_dmg")
        fre3:SetPos(fre:GetPos() + ply:GetForward() * 200)
        fre3:SetModelScale(fre:GetModelScale(), 0.2)
        fre3:SetAngles(Angle(0,ply:EyeAngles().y + 75,0))
        fre3:SetOwner(ply)
        fre3:Spawn()
        timer_Simple(0.2, function()
            fre3:Activate()
        end)
    end)

    timer_Simple(0.4, function()
        local fre4 = ents_Create("gf_effect_dmg")
        fre4:SetPos(fre:GetPos() + ply:GetForward() * 325)
        fre4:SetModelScale(fre:GetModelScale(), 0.2)
        fre4:SetAngles(Angle(0,ply:EyeAngles().y + 75,0))
        fre4:SetOwner(ply)
        fre4:Spawn()
        timer_Simple(0.2, function()
            fre4:Activate()
        end)
    end)
end