AddCSLuaFile()

SWEP.PrintName           = "Féerique 4"
SWEP.Author              = "Brounix"
SWEP.Instructions        = ""
SWEP.Contact             = ""
SWEP.AdminSpawnable      = true
SWEP.Spawnable           = true
SWEP.ViewModelFlip       = false
SWEP.ViewModelFOV        = 85
SWEP.ViewModel           = ""
SWEP.WorldModel          = ""
SWEP.AutoSwitchTo        = false
SWEP.AutoSwitchFrom      = true
SWEP.DrawAmmo            = false
SWEP.Base                = "weapon_base"
SWEP.Slot                = 2
SWEP.SlotPos             = 1
SWEP.HoldType            = "magic"
SWEP.DrawCrosshair       = true
SWEP.Weight              = 0

SWEP.Category            = "Féerique"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "None"

SWEP.Secondary.ClipSize     = 0
SWEP.Secondary.DefaultClip  = 0
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 20
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

config.dmg1 = 500
config.dmg2 = 500
config.zone = 500

config.tmpfreeze = 1.5

config.intervalDmgPoi = 0.5 -- interval entre chaque dgt poison
config.dmgPoi1 = 10 -- dgt poison entre .. et ..
config.dmgPoi2 = 10
config.nb = 10 --nb de fois que le poison touche

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
    self:SetHoldType("magic")
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
    local own = self:GetOwner()

    if self.NextAction > CurTime() then return end
    if self.CooldownDelay < CurTime() then
        if not SERVER then return end
        
        local entsInRadius = ents.FindInSphere(own:GetPos(), config.zone)

        own:EmitSound("ambient/gas/steam_loop1.wav", 50, 200, 0.1)
        for _, tar in ipairs(entsInRadius) do
            if IsValid(tar) and tar != own and (tar:IsPlayer() or tar:IsNPC() or type(tar) == "NextBot") then
                local feerique4 = ents.Create("feerique4")
                feerique4:SetOwner(own)
                feerique4:SetPos(tar:GetPos())
                feerique4:SetAngles(Angle(0, own:GetAngles().yaw, 0))
                feerique4:Spawn()
                feerique4:Activate()

                local dmginfo = DamageInfo()
                dmginfo:SetDamageType(DMG_ACID)
                dmginfo:SetDamage(config.dmg1)
                dmginfo:SetDamagePosition(tar:GetPos())
                dmginfo:SetAttacker(own)
                dmginfo:SetInflictor(own)
                tar:TakeDamageInfo(dmginfo)

                if tar:IsPlayer() then
                    tar:SetMoveType(MOVETYPE_NONE)
                    tar:Freeze(true)
                    timer.Simple(config.tmpfreeze, function()
                        if IsValid(tar) then
                            tar:SetMoveType(MOVETYPE_WALK)
                            tar:Freeze(false)
                        end
                    end)
                end
                if tar:IsNPC() then
                    tar:SetCondition(67)
                    timer.Simple(config.tmpfreeze, function()
                        if IsValid(tar) then
                            tar:SetCondition(68)
                        end
                    end)
                end
            end
        end

        timer.Simple(2, function()
            own:StopSound("ambient/gas/steam_loop1.wav", 50, 200, 0.1)
        end)

        self.CooldownDelay = CurTime() + self.Cooldown
        self.NextAction = CurTime() + self.ActionDelay
    else
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown .. "s de cooldown !")
    end
end

local function PoisonDmg(ent, num, attacker)

    local valent = ent:EntIndex()

    if !timer.Exists("DMGPOISON"..tostring(valent)) then
        timer.Create("DMGPOISON"..tostring(valent), config.intervalDmgPoi, num, function()
            if IsValid(ent) then
                ent:TakeDamage(math.random(config.dmgPoi1, config.dmgPoi2), attacker, DMG_ACID)   
            else
                timer.Remove("DMGPOISON"..tostring(valent))
            end
        end)
    end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
    return false
end

if true then
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_anim"
    ENT.PrintName = "Feerique4"
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
            local phys = self:GetPhysicsObject()
            if phys:IsValid() then
                phys:Wake()
                phys:EnableGravity(false)
            end
            local idx = "feeerique" .. self:EntIndex()
            timer.Create(idx, 0.01, 1, function()
                if IsValid(self) then
                    local effectdata = EffectData()
                    effectdata:SetOrigin(self:GetPos())
                    effectdata:SetScale(1)
                    effectdata:SetEntity(self)
                    ParticleEffectAttach("[11]_insect_jump", 1, self, 1)
                else
                    timer.Remove(idx)
                end
            end)
            local idx2 = "feeerique4" .. self:EntIndex()
            timer.Create(idx2, 0.01, 1, function()
                if IsValid(self) then
                    local effectdata = EffectData()
                    effectdata:SetOrigin(self:GetPos())
                    effectdata:SetScale(1)
                    effectdata:SetEntity(self)
                    ParticleEffectAttach("[11]_jump_bloom", 1, self, 1)
                else
                    timer.Remove(idx2)
                end
            end)

            for _, v in ipairs(ents.FindInSphere(self:GetPos(), config.zone)) do
                if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC()) then
                    timer.Simple(1, function()
                        if IsValid(v) then
                            local dmginfo = DamageInfo()
                            dmginfo:SetDamageType(DMG_ACID)
                            dmginfo:SetDamage(0)
                            dmginfo:SetDamagePosition(self:GetPos())
                            dmginfo:SetAttacker(self.Owner)
                            dmginfo:SetInflictor(self.Owner)
							PoisonDmg(v, config.nb, own)
                            v:TakeDamageInfo(dmginfo)
                            if IsValid(v) and v != self.Owner and (v:IsPlayer()) then
                                v:SetMoveType(MOVETYPE_NONE)
                                v:Freeze(true)
                                timer.Simple(config.tmpfreeze, function()
                                    if IsValid(v) then
                                        v:SetMoveType(MOVETYPE_WALK)
                                        v:Freeze(false)
                                    end
                                end)
                            end
                            if IsValid(v) and v:IsNPC() and v != self.Owner then
                                v:SetCondition(67)
                                timer.Simple(config.tmpfreeze, function()
                                    if IsValid(v) then
                                        v:SetCondition(68)
                                    end
                                end)
                            end
                        end
                    end)
                end
            end

            SafeRemoveEntityDelayed(self, 3)
        end
    end

    if CLIENT then
        function ENT:Draw()
            if not self.Effect then
                self.Effect = true
                self:DrawShadow(false)
            end
        end
    end

    scripted_ents.Register(ENT, "feerique4")
end