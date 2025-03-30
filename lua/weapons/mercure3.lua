local JY = {}
JY.Name             = "Mercure 3"       // Nom de l'arme
JY.Category         = "Mercure"         // nom de la catégorie

JY.Debug            = false              // Pour t'aidé a config la zone

JY.MaxDistance      = 2500                // La distance max pour l'attaque. Met -1 pour aucune limite
JY.RayonDetection   = 100                // Le rayon
JY.Cooldown         = 15                // Cooldown en seconde
JY.Duration         = 2                 // Durée de l'attaque en seconde
JY.Damage           = 350               // Dégat
JY.Model            = "models/mercure/dome_argent.mdl"   // Le modèle

SWEP.PrintName = JY.Name                // Variable useless je sais mais spécial Uki histoire qu'il ce perde pas ^^
SWEP.Category = JY.Category

SWEP.Slot = 3
SWEP.SlotPos = 50
SWEP.DrawAmmo = true
SWEP.Instructions = ""
SWEP.Author = "JustYumi"
SWEP.DrawCrosshair	= true

SWEP.ViewModel = "" 
SWEP.WorldModel	= ""

SWEP.AdminOnly = true
SWEP.Spawnable = true

SWEP.Primary = {Ammo="none",ClipSize=-1,DefaultClip=-1,Automatic=false}
SWEP.Secondary = SWEP.Primary

local function grows(ent, add, max, time)
    if !IsValid(ent) then return end
    if ent:GetModelScale() > max then return end
    timer.Simple(time, function()
        if !IsValid(ent) then return end
        ent:SetModelScale(ent:GetModelScale() + add)
        grows(ent, add, max, time)
    end)
end

local function rotate(ent, angle, time)
    if !IsValid(ent) then return end
    timer.Simple(time, function()
        if !IsValid(ent) then return end
        ent:SetAngles(ent:GetAngles() + angle)
        rotate(ent, angle, time)
    end)
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    if (self:GetOwner()["JY_CD_".. JY.Name] || 0) > CurTime() then
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as ".. JY.Cooldown .."s de cooldown !")
        return
    end

    local trace = self:GetOwner():GetEyeTrace()
    
    if JY.MaxDistance != -1 && self:GetOwner():GetPos():Distance(trace.HitPos) > JY.MaxDistance then return end

    local entityFind = ents.FindInSphere(trace.HitPos, JY.RayonDetection)
    local entityClosest
    local entityRepulse = {}

    for key, ent in ipairs(entityFind) do
        if !IsValid(ent) || !(ent:IsPlayer() || ent:IsNPC()) then continue end
        if ent == self:GetOwner() then continue end
        entityClosest = IsValid(entityClosest) && (trace.HitPos:Distance(entityClosest:GetPos()) < trace.HitPos:Distance(ent:GetPos()) && entityClosest || ent) || ent
        entityRepulse[ent:EntIndex()] = ent
    end

    if !IsValid(entityClosest) then return end

    entityRepulse[entityClosest:EntIndex()] = nil
    entityClosest:EmitSound(Sound("ambient/levels/outland/ol01_rock_crash.wav"))

    local ent = ents.Create("prop_dynamic")
    ent:SetModelScale(0)
    ent:SetModel(JY.Model)
    ent:SetColor(Color(96, 96, 96))
    ent:SetPos(entityClosest:GetPos())

    grows(ent, 1, .5, .03)
    rotate(ent, Angle(0,10,0), .1)

    local dmg = DamageInfo()
    dmg:SetDamage(JY.Damage)
    dmg:SetAttacker(self:GetOwner())
    dmg:SetDamageForce(Vector(0,0,0))
    entityClosest:TakeDamageInfo(dmg)

    if entityClosest:IsPlayer() then
        entityClosest:Freeze(true)
    end

    self:GetOwner()["JY_CD_".. JY.Name] = CurTime() + JY.Cooldown

    for _, ply in pairs(entityRepulse) do
        ply:SetVelocity((ply:GetPos() - entityClosest:GetPos()):GetNormalized() * 200 + Vector(0,0,400))
        ply:TakeDamage(JY.Damage, self:GetOwner())
    end

    timer.Simple(JY.Duration * .9, function()
        ent:SetModelScale(0, JY.Duration * .1)
    end)

    timer.Simple(JY.Duration * .9, function()
        if !IsValid(entityClosest) then return end
        entityClosest:EmitSound(Sound("ambient/levels/launch/debris02.wav"))
    end)

    timer.Simple(JY.Duration, function()
        if entityClosest:IsPlayer() then
            entityClosest:Freeze(false)
        end
        if IsValid(entityClosest) then
            entityClosest:EmitSound(Sound("bms_ambience/object_physics/rock_hit5.wav"))
        end
        SafeRemoveEntity(ent)
    end)
end

if JY.Debug then
    hook.Add("PostDrawTranslucentRenderables", "JY_".. JY.Name, function()
        if !IsValid(LocalPlayer():GetActiveWeapon()) || LocalPlayer():GetActiveWeapon():GetPrintName() != JY.Name then return end
        if JY.MaxDistance != -1 && LocalPlayer():GetPos():Distance(LocalPlayer():GetEyeTrace().HitPos) > JY.MaxDistance then return end
        render.DrawWireframeSphere(LocalPlayer():GetEyeTrace().HitPos, JY.RayonDetection, 15, 15, Color(math.sin(CurTime()*2)*127+128,math.sin(CurTime()*2+2)*127+128,math.sin(CurTime()*2+4)*127+128), true)
    end)
else
    hook.Remove("PostDrawTranslucentRenderables", "JY_".. SWEP.PrintName)
end

function SWEP:Initialize() self:SetHoldType("magic") end

function SWEP:OnDrop() self:Remove() end

function SWEP:SecondaryAttack() end