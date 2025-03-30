AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:Initialize()
    local own = self:GetOwner()
    self:SetHoldType("fist")
    self.sprint = false
end

function SWEP:Think()

    local own = self.Owner

    if own:KeyDown( IN_ATTACK2 ) and own:Alive() and !self.sprint then

		own:SetRunSpeed(own:GetRunSpeed()*1.8)
		own:SetWalkSpeed(own:GetWalkSpeed()*1.8)
		own:SetJumpPower(own:GetJumpPower()*1.2)

		self.sprint = true
	end

	if( own:KeyReleased( IN_ATTACK2 )) and self.sprint then
		self.sprint = false
		own:SetRunSpeed( own:GetRunSpeed()/1.8)
		own:SetWalkSpeed(own:GetWalkSpeed()/1.8)
		own:SetJumpPower(own:GetJumpPower()/1.2)
	end
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Deploy()
	local own = self.Owner
	self.eff = ents.Create( "lumiere_effect" ) 
	self.eff:SetPos( own:GetPos() ) 
	self.eff:SetParent(own)
	self.eff:Spawn() 
	self.eff:Activate() 
	own:DeleteOnRemove( self.eff )
end

function SWEP:Holster()
    SafeRemoveEntity(self.eff)
	return true
end
