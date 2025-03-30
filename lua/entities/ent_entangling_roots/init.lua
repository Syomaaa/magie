
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local soundpoolstart = { "spell_dr_revamp_entanglingroots_impact01", "spell_dr_revamp_entanglingroots_impact02", "spell_dr_revamp_entanglingroots_impact03", "spell_dr_revamp_entanglingroots_impact04", "spell_dr_revamp_entanglingroots_impact05" }
local soundpoolend = { "spell_dr_revamp_entanglingroots_statedone01", "spell_dr_revamp_entanglingroots_statedone02", "spell_dr_revamp_entanglingroots_statedone03" }

function ENT:StartSequence()
	self:SetPlaybackRate( 0.1)
	self:ResetSequence( "birth" )
end
function ENT:StartSoundSequence()
	self.Entity:EmitSound(soundpoolend[math.random(3)] .. ".wav", 90, 100, 1, CHAN_AUTO)
end
function ENT:StartSequence2()
	self:SetPlaybackRate( 0.1)
	self:ResetSequence( "death" )
end

function ENT:SpawnFunction( ply, tr )
   
 	if ( !tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 15
 	 
 	local ent = ents.Create( "ent_entangling_roots")
	
	ent:SetPos(ply:GetEyeTrace().HitPos+Vector(0, 0, 1))
	ent:Spawn()
	ent:Activate() 
	ent.Owner = ply
	
	return ent
end

function ENT:Initialize()

	self.Entity:SetModel( "models/mailer/wow_spells/wow_entangling_roots.mdl" )
	self.Entity:SetSolid(SOLID_NONE)
	self.Entity:SetAngles(Angle(0, math.random(360), 0))
	self.Entity:PhysicsInit(SOLID_NONE)
	
	self.Entity:EmitSound(soundpoolstart[math.random(5)] .. ".wav", 90, 100, 1, CHAN_AUTO)
	
	self.Entity:StartSequence()
	
	timer.Simple(3, function() 
		if self:IsValid() == false then return end
		self.Entity:StartSoundSequence() 
	end ) 
	timer.Simple(3, function() 
		if self:IsValid() == false then return end
		self.Entity:StartSequence2() 
	end )

end