ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Beam"
ENT.Name = "Beam"
ENT.Spawnable = false
ENT.radius = 500

function ENT:GetStormPosition()
    local owner = self:GetOwner()
    if owner:IsValid() then return owner:EyePos() end

    return self:GetPos()
end

function ENT:GetRadius()
    return self.radius
end

if SERVER then return end
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawBeam(tr, startPos, endPos)
    render.DrawBeam(startPos, endPos, 5, 0, 100 * tr.Fraction, self.beamColor)
end

function ENT:Initialize()
    local bounds = Vector(1000, 1000, 1000)
    self:SetRenderBounds(-bounds, bounds)
    self.nextParticles = 0
end

if not ConVarExists("ig_particlescale") then
    CreateConVar("ig_particlescale", "1", FCVAR_ARCHIVE)
end

local color = Color(38, 5, 66)
local smokeColor = Color(104, 26, 150, 255)
local glowSprite = "xyz/effects/infinitygauntlet/glow_hard" --"sprites/physg_glow1"
local Rand = math.Rand
local RandI = math.random
local fullCircle = math.pi * 2
local Sin, Cos = math.sin, math.cos

local function GetSpherePos(radius, rotational, z, pp)
    local phi = pp or Rand(0, fullCircle)
    local theta = z or math.acos(Rand(-1, 1))
    local r = rotational or radius * (Rand(0, 1) ^ (1 / 3))

    return Vector(r * Sin(theta) * Cos(phi), r * Sin(theta) * Sin(phi), r * Cos(theta)), r, theta, phi
end

local function ParticleThink(p)
    if p.ent:IsValid() then
        p.phi = p.phi + .03
        p:SetPos(p.ent:GetStormPosition() + GetSpherePos(p.sphereRadius, p.r, p.theta + math.sin(RealTime() * p.sinM) / 3, p.phi))
    else
        p:SetDieTime(0)

        return
    end

    if p.emitter:IsValid() then
        local part = p.emitter:Add(glowSprite, p:GetPos())
        part:SetRoll(Rand(-.5, .5))
        part:SetDieTime(.1)
        part:SetStartAlpha(255)
        part:SetEndAlpha(255)
        part:SetStartSize(20)
        part:SetEndSize(0)
        part:SetColor(38, 5, 66)
        local smoke = p.emitter:Add("particle/smokesprites_000" .. RandI(1, 9), p:GetPos())
        smoke:SetVelocity(VectorRand() * 150)
        smoke:SetRoll(Rand(-1, 1))
        smoke:SetRollDelta(Rand(-1, 1))
        smoke:SetAirResistance(20)
        smoke:SetStartSize(10)
        smoke:SetEndSize(0)
        smoke:SetStartAlpha(Rand(175, 215))
        smoke:SetEndAlpha(0)
        smoke:SetDieTime(.15)
        smoke:SetColor(smokeColor.r, smokeColor.g, smokeColor.b)
    end

    p:SetNextThink(1)
end

function ENT:DrawLight(pos)
    local light = DynamicLight(self:EntIndex())

    if light then
        light.pos = pos
        light.r = color.r
        light.g = color.g
        light.b = color.b
        light.brightness = 3
        light.decay = 1000
        light.size = 900
        light.dietime = CurTime() + .1
    end
end

function ENT:Draw()
    local pos = self:GetStormPosition()
    self:DrawLight(pos)
    if self.nextParticles > CurTime() then return end
    self.nextParticles = CurTime() + 1.01
    local emitter = ParticleEmitter(pos)

    for i = 0, 10 * GetConVar("ig_particlescale"):GetFloat() do
        local randPos, r, theta, phi = GetSpherePos(self:GetRadius())
        local p = emitter:Add(glowSprite, pos + randPos)
        p.sinM = Rand(1, 6)
        p.ent = self
        p.emitter = emitter
        p.r = r
        p.theta = theta
        p.sphereRadius = self:GetRadius()
        p.phi = phi
        p.creationTime = CurTime()
        p:SetRoll(Rand(-.5, .5))
        p:SetDieTime(5)
        p:SetStartAlpha(255)
        p:SetEndAlpha(255)
        p:SetStartSize(20)
        p:SetEndSize(20)
        p:SetColor(color.r, color.g, color.b)
        p:SetNextThink(1)
        p:SetThinkFunction(ParticleThink)
    end

    timer.Simple(5, function()
        if emitter:IsValid() then
            emitter:Finish()
        end
    end)
end