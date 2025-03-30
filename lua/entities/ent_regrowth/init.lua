
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
   
 	if ( !tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 10 
 	 
 	local ent = ents.Create( "ent_regrowth")
	ent:SetPos(ply:GetEyeTrace().HitPos+Vector(0, 0, 1))
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	return ent 
 	  	 
end

function ENT:Initialize()

	self.Entity:SetModel( "models/mailer/wow_spells/wow_regrowth.mdl" )
	self.Entity:SetSolid(SOLID_NONE)
	self.Entity:PhysicsInit(SOLID_NONE)

end