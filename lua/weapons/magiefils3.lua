game.AddParticles("particles/firemagic01.pcf")
PrecacheParticleSystem("asplode_hoodoo_debris")
AddCSLuaFile()

SWEP.Spawnable = true 
SWEP.AdminOnly = false 

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false 
SWEP.DrawCrosshair = true
SWEP.Category = "Fils"
SWEP.PrintName = "Fils 3"

SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 54
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.ViewModelFlip = false 
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip =-1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.HoldType             = "magic"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

function SWEP:PrimaryAttack() 
    if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

        local ply = self:GetOwner()

        local coef = 1
        local plyPos = ply:GetPos()
        timer.Create("filsEffect/" .. math.random(0, 100000) * 10, .1, 10, function()
            ParticleEffect("[13]_spider_bloom", plyPos + ply:GetForward() * 100 * coef, Angle(0, 0, 0))
            if SERVER then
                local dmgVectors = {}
                dmgVectors[#dmgVectors + 1] =  plyPos + ply:GetForward() * 100 * coef
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamage(75)
                dmgInfo:SetAttacker(ply)
                dmgInfo:SetInflictor(self)
                dmgInfo:SetDamageType(DMG_SONIC)
                
                for _, vector in ipairs(dmgVectors) do
                    for __, ent in ipairs(ents.FindInSphere(vector, 300)) do
                        if ent:IsPlayer() and ent != ply then
                            if ( ent != self.Owner and (ent:IsNPC() or ent:IsPlayer() or type(ent) == "NextBot" or string.find(ent:GetClass(),"prop")) )then
                                ent:TakeDamageInfo(dmgInfo)
                            end
                        end
                    end
                end
                table.Empty(dmgVectors)
            end
            coef = coef + 1
        end)
        
    self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
    self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end