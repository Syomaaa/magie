if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Transformation 1 Morsure"
SWEP.Author = "SNZ Lucmodzzz"
SWEP.Category = "Transformations"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Delay = 0.2
SWEP.Hitbox = 250
SWEP.AttackSound = "npc/headcrab_poison/ph_poisonbite1.wav"

function SWEP:Initialize()
    self:SetHoldType("fist")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Delay)

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    owner:SetAnimation(PLAYER_ATTACK1)

    owner:LagCompensation(true)

    local entities = ents.FindInSphere(owner:GetPos(), self.Hitbox)

    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent != owner and (ent:IsPlayer() or ent:IsNPC() or (type(ent) == "NextBot")) then
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(50)
            dmgInfo:SetAttacker(owner)
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamageType(DMG_CLUB)
            if ent.TakeDamageInfo then
                ent:TakeDamageInfo(dmgInfo)
            end
        end
    end

    owner:EmitSound(self.AttackSound, 35, 100, 0.5)
    owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()

end