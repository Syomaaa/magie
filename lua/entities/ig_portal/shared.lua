ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Wormhole"
ENT.Name = "Wormhole"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Destination")
end

hook.Add("EntityFireBullets", "IG_Portals", function(ent, data)
    for k, v in ipairs(ents.FindByClass("ig_portal")) do
        if v:GetDestination():IsValid() then
            v:SetNotSolid(false)
            local tr = util.QuickTrace(data.Src, data.Dir * 16000, ent)
            v:SetNotSolid(true)

            if tr.Entity == v then
                data.Src = v:GetDestination():GetPos() + (tr.HitPos - v:GetPos())

                return true
            end
        end
    end
end)

if SERVER then return end
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    self.size = 0
    self.nextParticles = 0
end

local lightningMat = Material("particle/bendibeam")
local RandF, RandI = math.Rand, math.random
local portalSmokeColor = Color(0, 31, 45)
local portalSmokeColorInner = Color(77, 77, 77)
local fullCircle = math.pi * 2
local Sin, Cos = math.sin, math.cos
local maxSize = 30
local circleX = Vector(-1, 0, 0)
local circleY = Vector(0, -1, 0)

local function MeshCircle(data)
    local pos = data.position
    local size = data.size
    local segments = data.segments
    local rotation = data.rotation
    local portalEffects = data.portalEffects
    local particleAmountInBetween = 3 * GetConVar("ig_particlescale"):GetFloat()

    if data.material then
        render.SetMaterial(data.material)
    else
        render.SetColorMaterial()
    end

    mesh.Begin(MATERIAL_POLYGON, segments)
    mesh.Color(255, 255, 255, 255)
    local emitter

    if portalEffects then
        emitter = ParticleEmitter(pos)
    end

    local lastVertex

    for i = 0, segments do
        local rad = fullCircle * (i / segments)
        local p = ((circleX * (Sin(rad) * 2) * (size) + (circleY * (Cos(rad) * 2) * (maxSize))))

        if rotation then
            p:Rotate(rotation)
        end

        local vertexPos = pos + p
        mesh.Position(vertexPos)
        mesh.AdvanceVertex()

        if portalEffects and lastVertex then
            local innerEffects = size < maxSize - 10
            local color = innerEffects and portalSmokeColorInner or portalSmokeColor

            for i = 0, particleAmountInBetween do
                local p = emitter:Add("particle/smokesprites_000" .. RandI(1, 9), vertexPos + VectorRand() * 4 + (lastVertex - vertexPos) * i / particleAmountInBetween + rotation:Up() * 5)
                p:SetRoll(RandF(-1, 1))
                p:SetRollDelta(RandF(-1, 1))
                p:SetStartSize(16)
                p:SetEndSize(0)
                p:SetStartAlpha(255)
                p:SetEndAlpha(0)
                p:SetDieTime(.5)
                p:SetColor(color.r, color.g, color.b)
            end
            --TODO: Add lighting?
        end

        lastVertex = vertexPos
    end

    if emitter then
        emitter:Finish()
    end

    mesh.End()
end

local function Portal(innerRenderFunction, meshFunction, ...)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS) --Compare pixels always.
    render.SetStencilPassOperation(STENCIL_REPLACE) --Enables the mesh to replace world pixels.
    render.SetStencilFailOperation(STENCIL_KEEP) --Leave failed pixels untouched
    render.SetStencilZFailOperation(STENCIL_KEEP) --Leave failed pixels untouched
    render.SetStencilWriteMask(1) --Sets the upcoming value for mesh pixels to 1
    render.SetStencilTestMask(1) --Set the value to test meshes against
    render.SetStencilReferenceValue(1) --Sets pixels value to 1
    meshFunction(...)
    render.SetStencilCompareFunction(STENCIL_EQUAL) --Limits the drawing area to the mesh set
    --The world/default is set to 1
    --It removes all world/default pixels and replaces them with the mesh, as the mesh is set to 1.
    render.ClearBuffersObeyStencil(0, 0, 0, 0, true) --Clears the mesh/selected/rendertarget pixels with black.
    --Begin drawing inside the render target/mesh.
    innerRenderFunction()
    render.SetStencilEnable(false)
end

local portalBlackness = Material("xyz/effects/infinitygauntlet/blackgoop")

function ENT:Draw()
    local portalAngle = self:GetAngles()

    if self:GetNWInt("removeTime", CurTime() + 500) <= CurTime() then
        self.size = Lerp(3 * FrameTime(), self.size, 0)
    else
        self.size = Lerp(1.5 * FrameTime(), self.size, maxSize)
    end

    if self.size < 3 then return end
    local startPosition = self:GetPos()
    render.SetColorMaterial()
    local backAng = Angle(portalAngle)
    backAng:RotateAroundAxis(portalAngle:Forward(), 90)

    Portal(function() end, MeshCircle, {
        position = startPosition + backAng:Up() * .5,
        rotation = backAng,
        size = self.size,
        segments = 10
    })

    Portal(function()
        render.SetColorModulation(.5, .4, 1, 255)
        render.SuppressEngineLighting(true)
        render.SetModelLighting(BOX_TOP, 5, 5, 5)
        render.SetMaterial(portalBlackness)
        local m = Matrix()
        local s = 200 / startPosition:Distance(EyePos())
        m:SetScale(Vector(s, s, s))
        local t = -s / 2
        m:SetTranslation(Vector(t, t, 0))
        portalBlackness:SetMatrix("$basetexturetransform", m)
        render.DrawQuadEasy(startPosition, portalAngle:Up(), 200, 200, Color(255, 255, 255), 0)
        render.SuppressEngineLighting(false)
        render.SetColorModulation(1, 1, 1, 255)
    end, MeshCircle, {
        position = startPosition,
        rotation = portalAngle,
        size = self.size,
        segments = 10,
        portalEffects = self.nextParticles < CurTime()
    })

    if self.nextParticles < CurTime() then
        self.nextParticles = CurTime() + .02
    end
    --local mins,maxs = self:GetCollisionBounds()
    --render.DrawBox(self:GetPos(),self:GetAngles(),mins,maxs,Color(255,255,255,150),true)
end