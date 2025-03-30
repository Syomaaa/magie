AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:PhysicsInit(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self:DrawShadow(false)
end

function ENT:Think()
    local ply = self:GetOwner()

    for k, v in ipairs(ents.FindInSphere(self:GetStormPosition(), self:GetRadius())) do
        if v:IsValid() and v ~= ply and not v:IsWeapon() and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
            local dmg = DamageInfo()
            dmg:SetDamageType(DMG_DISSOLVE)
            dmg:SetAttacker(ply)
            dmg:SetInflictor(self)
			v:TakeDamage(350, self:GetOwner())
            v:TakeDamageInfo(dmg)
			self:Remove()
            local ef = EffectData()
            ef:SetOrigin(v:GetPos() + v:OBBCenter() + VectorRand() * ((v:GetModelRadius() or 50) / 2))
            util.Effect("ig_energystorm_hit", ef, true, true)
            v:EmitSound("xyz/infinitygauntlet/shield_impact.wav")
        end
    end
end