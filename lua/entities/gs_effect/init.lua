AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local timer_Simple = timer.Simple

function ENT:Initialize()
   self:SetModel("models/mha_props/glace_sol.mdl")
   self:PhysicsInit(SOLID_VPHYSICS)
   self:SetMoveType(MOVETYPE_VPHYSICS)
   self:SetSolid(SOLID_NONE)
   self:DrawShadow(false)
   self:SetTrigger(true)
   self:UseTriggerBounds(false)

   local phys = self:GetPhysicsObject()
    if ( !IsValid( phys ) ) then return end
    phys:Wake()
    phys:EnableGravity(false)
    phys:SetMass(1000)

    timer_Simple(2, function()
        self:Remove()
    end)
end