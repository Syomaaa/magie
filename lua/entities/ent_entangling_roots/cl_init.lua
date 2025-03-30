ENT.Spawnable = true
ENT.AdminOnly = true

include('shared.lua')

game.AddParticles( "particles/wow_entangling_roots.pcf" )

function ENT:Initialize()

	if self:IsValid() == false then return end
	
	self:CreateParticleEffect( "dirt", 1, { 0, ent, Vector(0, 0, 0) } )
	
end