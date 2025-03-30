AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local ents_Create = ents.Create
local ents_FindInSphere = ents.FindInSphere
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
        local gs = ents_Create("gs_effect")
        gs:SetPos(ply:GetPos())
        gs:Spawn()

        for k, v in ipairs(ents_FindInSphere(ply:GetPos(), 500)) do
            if (IsValid(v) and v != ply and (v:IsPlayer() or v:IsNPC() or v:IsNextBot())) then
                local fre = ents_Create("gf_effect")
                fre:SetPos(v:GetPos())
                fre:SetModelScale(fre:GetModelScale() * 10, 0.2)
                fre:Spawn()
                v:TakeDamage(500, ply, ply)
            end
        end
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end