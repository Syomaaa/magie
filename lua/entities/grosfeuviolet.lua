AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "feuviolet"
ENT.Author = "CeiLciuZ"
ENT.Spawnable = false
ENT.AdminOnly = false


function ENT:Initialize()
	ParticleEffectAttach("dragon_fire_breath", 1, self, 1)

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
	if SERVER then
		for k,v in pairs(ents.FindInSphere( self:GetPos(), 300)) do
            local own = self.Owner
            if IsValid(v) then
                if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
                    v:TakeDamage(350, self:GetOwner())
                    self:Remove()
				end
			end
		end
	end
end

