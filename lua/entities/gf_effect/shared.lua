AddCSLuaFile()

ENT.Type           = "anim"
ENT.Base           = "base_gmodentity"

ENT.Spawnable      = true
ENT.AdminSpawnable = false

ENT.PrintName      = "gf_effect"
ENT.Author         = "Kuro"
ENT.AutomaticFrameAdvance = true

function ENT.SetAutomaticFrameAdvance(byUsingAnim)
	self.AutomaticFrameAdvance = byUsingAnim
end  
