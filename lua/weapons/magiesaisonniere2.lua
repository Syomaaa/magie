AddCSLuaFile()

SWEP.PrintName = "Saisonniere 2"
SWEP.Author = "Brounix"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.AdminSpawnable = true
SWEP.Spawnable = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 85
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true
SWEP.DrawAmmo = false
SWEP.Base = "weapon_base"
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.HoldType = "magic"
SWEP.DrawCrosshair = true
SWEP.Weight = 0

SWEP.Category = "Saisonniere"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "None"

SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

local config = {}

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

config.Cooldown = 0.1 -- coolwon atk pet

config.dmg1 = 25
config.dmg2 = 25
config.tmp = 5     -- temps de l'attack
config.hitbox = 250
config.zone = 300
config.unslow = 2.5  -- temps du slow
config.beforeSlow = 0  -- temps avant slow apres la bulle active
config.slow = 3  -- vitesse divise par ...
config.slowCooldown = 5   -- si tu change le temps de l'attaque change aussi

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
    self:SetHoldType("magic")
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay < CurTime() then if not SERVER then return end

        local saisonniere2 = ents.Create("saisonniere2")
        saisonniere2:SetPos(self.Owner:GetPos())
        saisonniere2:SetOwner(self.Owner)
        saisonniere2:Spawn()

        self.CooldownDelay = CurTime() + self.Cooldown
        self.NextAction = CurTime() + self.ActionDelay
    else
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown .. "s de cooldown !")
    end
end

--------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
    return true
end

function SWEP:Deploy()
    return true
end

function SWEP:SecondaryAttack()
    return false
end

if true then
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "saisonniere2"
    ENT.Spawnable = false
    ENT.AdminOnly = false

    function ENT:Initialize()
        if SERVER then
            self:SetModel("models/maxofs2d/hover_classic.mdl")
            self:PhysicsInit(SOLID_NONE)
            self:SetMoveType(MOVETYPE_NONE)
            self:SetSolid(SOLID_NONE)
            self:SetRenderMode(RENDERMODE_TRANSCOLOR)
            self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
            self:DrawShadow(false)
            local own = self.Owner
            local phys = self:GetPhysicsObject()
            if phys:IsValid() then
                phys:Wake()
                phys:EnableGravity(false)
            end

            local idx = "saisonniere2" .. self:EntIndex()
            timer.Create(idx, 0.01, 1, function()
                if IsValid(self) then
                    local effectdata = EffectData()
                    effectdata:SetOrigin(self:GetPos())
                    effectdata:SetScale(1)
                    effectdata:SetEntity(self)
                    ParticleEffectAttach("[22]_icebarage", 1, self, 1)
                end
            end)

            local idx = "saisonniere2.2" .. self:EntIndex()
            timer.Create(idx, 0.1, config.tmp * 10, function()
                if IsValid(self) then
                    local effectdata = EffectData()
                    effectdata:SetOrigin(self:GetPos())
                    effectdata:SetScale(1)
                    effectdata:SetEntity(self)
                    ParticleEffect("[22]_ice_ambient_add", self:GetPos() + Vector(0, 0, 800), Angle(0, 0, 0), self)
                end
            end)

            SafeRemoveEntityDelayed(self, config.tmp)

            self.cd = 0.3
            self.cdDelay = 0
            self.slowCooldownDelay = 0

            timer.Simple(config.beforeSlow, function()
                if IsValid(self) then
                    self:ApplySlow()
                end
            end)
        end
    end

    function ENT:ApplySlow()
    timer.Create("ApplySlowEffect" .. self:EntIndex(), 0.5, 0, function()
        if IsValid(self) then
            if self.slowCooldownDelay <= CurTime() then
                for k, v in pairs(ents.FindInSphere(self:GetPos(), config.zone)) do
                    if v:IsPlayer() and v ~= self.Owner then
                        if not v._IsAffectedBySaisonniere2 then
                            v._IsAffectedBySaisonniere2 = true
                            v._OriginalRunSpeed = v:GetRunSpeed()
                            v._OriginalWalkSpeed = v:GetWalkSpeed()
                            v._OriginalJumpPower = v:GetJumpPower()
                        end

                        v:SetRunSpeed(v._OriginalRunSpeed / config.slow)
                        v:SetWalkSpeed(v._OriginalWalkSpeed / config.slow)
                        v:SetJumpPower(v._OriginalJumpPower / config.slow)

                        timer.Simple(config.unslow, function()
                            if IsValid(v) then
                                v:SetRunSpeed(v._OriginalRunSpeed)
                                v:SetWalkSpeed(v._OriginalWalkSpeed)
                                v:SetJumpPower(v._OriginalJumpPower)
                                v._IsAffectedBySaisonniere2 = false
                            end
                        end)
                    end
                end
                self.slowCooldownDelay = CurTime() + config.slowCooldown
            end
        end
    end)
end

    function ENT:Think()
        if SERVER then
            if self.cdDelay <= CurTime() then
                for k, v in pairs(ents.FindInSphere(self:GetPos(), config.zone)) do
                    if IsValid(v) and v ~= self.Owner and (v:IsPlayer() or v:IsNPC() or type(v) == "NextBot") then
                        local dmginfo = DamageInfo()
                        dmginfo:SetDamageType(DMG_GENERIC)
                        dmginfo:SetDamage(math.random(config.dmg1, config.dmg2))
                        dmginfo:SetDamagePosition(self:GetPos())
                        v:AddEFlags(-2147483648)
                        dmginfo:SetAttacker(self.Owner)
                        dmginfo:SetInflictor(self.Owner)
                        v:TakeDamageInfo(dmginfo)
                        v:RemoveEFlags(-2147483648)
                    end
                end
                self.cdDelay = CurTime() + self.cd
            end
        end

        local own = self.Owner
        local tra = util.TraceLine({
            start = own:EyePos(),
            endpos = own:EyePos() + own:EyeAngles():Forward() * 1000,
            mask = MASK_NPCWORLDSTATIC,
            filter = {self, own}
        })
        local ptt = tra.HitPos + tra.HitNormal * 30
        if self:GetPos():Distance(ptt) > 150 then
            self:SetPos(self:GetPos() + (ptt - self:GetPos()):GetNormal() * 150)
        end
        self:NextThink(CurTime())
        return true
    end

    function ENT:OnRemove()
        timer.Remove("ApplySlowEffect" .. self:EntIndex())
    end

    if CLIENT then
        function ENT:Draw()
            if not self.Effect then
                self.Effect = true
                self:DrawShadow(false)
            end
        end
    end

    scripted_ents.Register(ENT, "saisonniere2")
	
	if SERVER then
    hook.Add("PlayerSpawn", "Saisonniere2PlayerSpawn", function(ply)
        if ply._IsAffectedBySaisonniere2 then
            ply:SetRunSpeed(ply._OriginalRunSpeed)
            ply:SetWalkSpeed(ply._OriginalWalkSpeed)
            ply:SetJumpPower(ply._OriginalJumpPower)
            ply._IsAffectedBySaisonniere2 = false
        end
    end)
end
end