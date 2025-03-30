AddCSLuaFile("poke_ghost_phantomforce.lua")
SWEP.Base = "poke_ghosttype"
--[[------------------------------
Configuration
--------------------------------]]
local config = {}
config.SWEPName = "Ghost - Phantom Force"
config.ActionDelay = 1 -- Time in between each action.
--[[-------------------------------------------------------------------------
Phantom Force
---------------------------------------------------------------------------]]
config.PhantomForceDelay = 0.2 -- How long until you can use it again after attack?
config.PhantomForceDuration = 3 -- How long can you use this for?
config.PhantomForceRadius = 200 -- Radius around the player shadow to deal damage?
config.PhantomForceDamageLow = 50
config.PhantomForceDamageHigh = 100
config.PhantomForceDamageForce = 500000 -- Force applied on damage.

config.PhantomForceSound = "weapons/airboat/airboat_gun_energy1.wav"
config.PhantomForceStartSound = "weapons/underwater_explode4.wav"
config.PhantomForceSoundPitch = 75
--[[-------------------------------------------------------------------------
Messages ( debug )
---------------------------------------------------------------------------]]
config.PrintMessages = false
config.PhantomForceMessage = "Phantom Force!"
--[[----------------------
SWEP
------------------------]]
SWEP.PrintName = config.SWEPName
SWEP.Author = "Project Stadium"
SWEP.Purpose = "discord.me/projectstadium"
SWEP.Category = "Project Stadium"
SWEP.Instructions = "Become the shadow and attack an enemy at will!"
SWEP.HoldType = "fist"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.ShowWorldModel = false
SWEP.ShowViewModel = false
SWEP.UseHands = false
SWEP.ViewModelFOV = 54

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Secondary.ClipSize       = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Automatic      = false
SWEP.Secondary.Ammo           = "none"
--[[-------------------------------------------------------------------------
Default SWEP functions
---------------------------------------------------------------------------]]
function SWEP:Think()
	local owner = self:GetOwner()
	if self.PhantomForceEnabled then
		if self.NextFX < CurTime() then
			local shadow = EffectData()
			shadow:SetOrigin(self:GetOwner():GetPos())
			shadow:SetNormal(Vector(0,0,1))
			shadow:SetScale(55)
			util.Effect("fx_poke_shadow",shadow)

			self.NextFX = CurTime() + self.FXDelay
		end
	end
end

function SWEP:PrimaryAttack() 
	if SERVER then self:PhantomForceStart() end
end
function SWEP:SecondaryAttack() 
end