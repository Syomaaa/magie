AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "fgdgdfgdfg"
ENT.Author = "CeiLciuZ"
ENT.Spawnable = false
ENT.AdminOnly = false


function ENT:Initialize()
    ParticleEffectAttach("flaque", 1, self, 1)
    if SERVER then
        self:SetModel( "models/props_phx/construct/metal_dome360.mdl" )
        self:SetMaterial("models/props_combine/com_shield001a.vtf")
        self:PhysicsInit(SOLID_VPHYSICS) 
        self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
        self:DrawShadow(false)
        self:SetSkin(1) 
    
        self:SetMoveType(MOVETYPE_VPHYSICS)  
        self:SetModelScale(0) 

        timer.Simple(5, function() if not self:IsValid() then return end
            self:Remove() 
        end)
    end
end

function ENT:Draw()
    self:DrawModel()
end



function ENT:Think()

end

