AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local timer_Simple = timer.Simple

function ENT:Initialize()
	local ply = self:GetOwner()
	self:SetModel("models/hunter/misc/sphere175x175.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	timer_Simple(0, function()
		ParticleEffectAttach("[12]_wind", 1, self, 1)
	end)

	timer_Simple(60, function()
		if IsValid(self) then
			self:Remove()
		end
	end)
end