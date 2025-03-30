AddCSLuaFile()

SWEP.Author = "tomlap77"
SWEP.Instructions = ""
SWEP.PrintName = "Ancien Mercure 3"
SWEP.Category =  "Mercure"
SWEP.Slot = 3
SWEP.SlotPos = 50
SWEP.DrawAmmo = true
SWEP.DrawCrosshair	= true
SWEP.ViewModel = "" 
SWEP.WorldModel	= ""
SWEP.UseHands = false
SWEP.AdminOnly = true
SWEP.Spawnable = true


SWEP.Primary = {
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

SWEP.Secondary = {
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

function SWEP:Initialize()
	self:SetHoldType("magic")
end

function SWEP:PrimaryAttack()

	local trace = self.Owner:GetEyeTrace()
	local Cible = self.Owner:GetEyeTrace().Entity
	local dis = self:GetPos():DistToSqr(Cible:GetPos())
		
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:ShootEffects(trace)	
	
	if not trace.Hit then return end
	
	if SERVER then  
		if dis < (750*750) then
			Cible:Freeze(true)
			Cible:GodEnable()
			Cible:EmitSound("Boulder.ImpactHard")
					
					

					
			local zeub = ents.Create("prop_dynamic")
			Cible.sypzeub = zeub
			
			local LeffetTropStyle = EffectData()
				LeffetTropStyle:SetOrigin( Cible:GetPos() + Vector(0, 0, 35) )
				util.Effect( "fumeenaruto", LeffetTropStyle, true, true )
			timer.Simple(0.2, function() 
			
				zeub:SetModel("models/mercure/dome_argent.mdl") -- props a modif
				zeub:SetModelScale(4)
				zeub:SetPos(Cible:GetPos())
				zeub:SetAngles(Angle(0,0,0))
				timer.Simple(0.5, function()
					zeub:SetModelScale( zeub:GetModelScale() / 6.4, 4.2 )
				end)
			end)

			
			timer.Simple(4.7, function() if IsValid(zeub) then zeub:Remove() end Cible.sypzeub = nil end)
			timer.Create("syphonfreeze" .. self.Owner:SteamID(), 4.7, 1, function()
			
			
				Cible:Freeze(false)
				Cible:SetHealth(Cible:Health() / 1.5)
				Cible:EmitSound("Boulder.ImpactHard")
				
				timer.Simple(1.5, function()
					Cible:GodDisable()
				end)
			end)

		end
	end
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ShootEffects(trace)
	local effectdata = EffectData()
	effectdata:SetOrigin(trace.HitPos)
	effectdata:SetStart(self.Owner:GetShootPos())
	effectdata:SetAttachment(1)
	effectdata:SetEntity(self.Weapon)
	util.Effect("ToolTracer", effectdata)
end

function SWEP:SecondaryAttack() 
	return true
end

hook.Add("PlayerDeath", "syphonfreeze", function(ply)
	if not timer.Exists("syphonfreeze" .. ply:SteamID()) then return end
	
	if ply.sypice and IsValid(ply.sypice) then
		ply.sypice:Remove()
		ply.sypice = nil
	end
	
	ply:Freeze(false)
	timer.Remove("syphonfreeze" .. ply:SteamID())
end)