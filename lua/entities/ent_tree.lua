AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"

function ENT:Initialize()


          self:SetModel("models/jaketree2.mdl")
          self:PhysicsInit(SOLID_NONE)
     	self:SetMoveType(MOVETYPE_NONE)
     	self:SetSolid(SOLID_NONE)

          local phys = self:GetPhysicsObject()

          if phys:IsValid() then

          	phys:Wake()
               phys:SetMass(50)

          end

end

function ENT:Draw()

     self:DrawModel()

end