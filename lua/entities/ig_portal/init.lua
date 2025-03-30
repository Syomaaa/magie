AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.lifeTime = 5
local bounds = Vector(50, 50, .5)

function ENT:Initialize()
    self:PhysicsInit(SOLID_OBB)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_OBB)
    self:DrawShadow(false)
    self:SetNotSolid(true)
    self:SetCollisionBounds(-bounds, bounds)
    self:SetTrigger(true)
    self:SetNWInt("removeTime", CurTime() + self.lifeTime)
    self.nextTeleport = 0
    --[[local ef = EffectData()
	ef:SetOrigin(self:GetPos())
	ef:SetEntity(self)
	ef:SetMagnitude(60)
	util.Effect("TeslaHitboxes",ef,false,true)]]
end

function ENT:Think()
    if self:GetNWInt("removeTime", CurTime() + 500) + 2 <= CurTime() then
        self:Remove()
    end
end

function ENT:StartTouch(ent)
    if self.nextTeleport < CurTime() and self:GetDestination():IsValid() and self:GetNWInt("removeTime", 0) > CurTime() then
        --self.nextTeleport = CurTime()+.5
        self:GetDestination().nextTeleport = CurTime() + .5

        local tr = util.TraceLine{
            start = self:GetDestination():GetPos() + Vector(0, 0, 100),
            endpos = self:GetDestination():GetPos() + Vector(0, 0, -500) + self:GetDestination():GetAngles():Forward() * 15,
            filter = {ent, self:GetDestination()}
        }

        local enterVelocity = ent:GetVelocity()
        ent:SetPos(IG_FindEmptyPositionEntity(ent, tr.HitPos, 200, 5, {ent, self:GetDestination(), self}))

        if ent:IsPlayer() then
            enterVelocity:Rotate(self:GetDestination():GetAngles() - self:GetAngles() + Angle(0, 180, 0))
            ent:SetLocalVelocity(enterVelocity)
        elseif ent:GetPhysicsObject():IsValid() then
            --local exitAngle = (self:GetDestination():GetPos()-self:GetPos()):Angle()+Angle(0,180,0)
            --exitAngle:RotateAroundAxis(exitAngle:Up(),180)
            --enterVelocity:Rotate(exitAngle)
            ent:GetPhysicsObject():SetVelocity(enterVelocity)
        end
    end
end