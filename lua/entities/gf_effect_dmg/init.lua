AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local timer_Simple = timer.Simple
local sound_Add = sound.Add

sound_Add( {
    name = "ice_spikemha",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 75,
    pitch = {100, 100},
    sound = "weapons/ice_spike.wav"
} )

function ENT:Initialize()
   self:SetModel("models/mha_props/glace_3.mdl")
   self:PhysicsInit(SOLID_VPHYSICS)
   self:SetMoveType(MOVETYPE_NONE)
   self:SetSolid(SOLID_NONE)
   self:SetRenderMode( RENDERMODE_TRANSCOLOR )
   self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
   self:DrawShadow(false)
   self:SetTrigger(true)
   self:UseTriggerBounds(false)
   timer_Simple(0, function()
        self:EmitSound("ice_spikemha")
    end)

    timer_Simple(2, function()
        self:StopSound("ice_spikemha")
        self:Remove()
    end)
end

function ENT:StartTouch(ent)
    if (IsValid(ent) and ent != self:GetOwner() and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()))  then        
        ent:TakeDamage(50, self:GetOwner(), self:GetOwner())
    else
        return
    end
end