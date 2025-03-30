AddCSLuaFile()
SWEP.HoldType = "magic"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Category = "Téléportation"
SWEP.PrintName = "Téléportation 2"
SWEP.UseHands = true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 54
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0

if not ConVarExists("ig_particlescale") then
    CreateConVar("ig_particlescale", "1", FCVAR_ARCHIVE)
end

local function PositionEmptyEntity(ent, pos, filter)
    return not util.TraceEntity({
        start = pos,
        endpos = pos,
        filter = filter and filter or ent
    }, ent).Hit
end

function IG_FindEmptyPositionEntity(ent, pos, distance, step, filter)
    if PositionEmptyEntity(ent, pos) then return pos end

    for j = step, distance, step do
        for i = -1, 1, 2 do
            local offset = j * i
            if PositionEmptyEntity(ent, pos + Vector(offset, 0, 0), filter) and PositionEmptyEntity(ent, pos + Vector(offset, 0, 0), filter) then return pos + Vector(offset, 0, 0) end
            if PositionEmptyEntity(ent, pos + Vector(0, offset, 0), filter) and PositionEmptyEntity(ent, pos + Vector(0, offset, 0), filter) then return pos + Vector(0, offset, 0) end
            if PositionEmptyEntity(ent, pos + Vector(0, 0, offset), filter) and PositionEmptyEntity(ent, pos + Vector(0, 0, offset), filter) then return pos + Vector(0, 0, offset) end
        end
    end

    return pos
end

local portalPairs = {}

local function CreateWormhole(entrancePos, entranceFacePos, exitPos)
    local dest = ents.Create("ig_portal")
    dest:SetPos(exitPos + Vector(0, 0, 40))
    dest:Spawn()
    dest:Activate()
    
    local entrance = ents.Create("ig_portal")
    entrance:SetPos(entrancePos + Vector(0, 0, -20))
    local entranceAngle = (entranceFacePos - entrance:GetPos()):GetNormalized():Angle()
    entranceAngle:RotateAroundAxis(entranceAngle:Up(), 0)
    entranceAngle.r = 90
    entrance:SetAngles(entranceAngle)
    entrance:Spawn()
    entrance:Activate()
    entranceAngle:RotateAroundAxis(entranceAngle:Right(), 0)
    dest:SetAngles(entranceAngle)
    dest:SetDestination(entrance)
    entrance:SetDestination(dest)
    
    table.insert(portalPairs, {entrance, dest})
end

function SWEP:SetupDataTables()
end

function SWEP:CanSecondaryAttack()
    return false
end

function SWEP:Initialize()
    self:SetHoldType("magic")
end

function SWEP:Deploy()
end

function SWEP:Holster(wep)
    if not IsFirstTimePredicted() then return end
    return true
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end

    if SERVER then
        self.ss_waypoint = self.Owner:GetEyeTrace().HitPos
    end
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    if self.Primary.Delay > CurTime() then return end

    if SERVER then
        if self.ss_waypoint then
            local tr = self.Owner:GetEyeTrace()
            CreateWormhole(tr.HitPos + Vector(0, 0, 70), tr.HitPos, self.ss_waypoint)
        else
            self.Owner:ChatPrint("Pas de point de départ : Appuyez sur CLIC GAUCHE")
        end
    end

    self.Primary.Delay = CurTime() + 5
end

function SWEP:Reload()
    if SERVER then
        for _, pair in ipairs(portalPairs) do
            for _, portal in ipairs(pair) do
                if IsValid(portal) then
                    portal:Remove()
                end
            end
        end
        portalPairs = {}
        self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as fermer tous tes portails! Tu dois attendre 5 secondes avant de les réouvrir" )
    end
end