if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Transformation 3 Morsure"
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
SWEP.Hitbox = 150
SWEP.AttackSound = "npc/headcrab_poison/ph_poisonbite3.wav"

function SWEP:Initialize()
    self:SetHoldType("fist")
end

local function ApplyPoisonDamage(ent, target)
    local progressiveDamage = 15
    local poisonDuration = 5
    local poisonTickRate = 1

    if IsValid(target) and target:IsPlayer() and target.TakeDamage then
        if not target.HasHantenguAura then
            target.HasHantenguAura = true

            local startPos = target:GetPos() + Vector(0, 0, 0)
            local particle = ents.Create("info_particle_system")
            particle:SetKeyValue("effect_name", "[8]_hantengu_aura")
            particle:SetPos(startPos)
            particle:Spawn()
            particle:Activate()
            particle:Fire("Start", "", 0)
            
            timer.Simple(poisonDuration, function()
                if IsValid(particle) then
                    particle:Fire("Kill", "", 0)
                end
                target.HasHantenguAura = false
            end)
        end

        timer.Create("PoisonEffect_" .. target:EntIndex(), poisonTickRate, poisonDuration, function()
            if IsValid(target) then
                target:TakeDamage(progressiveDamage, ent:GetOwner(), ent)
            end
        end)
    end
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

            if ent:IsPlayer() then
                ApplyPoisonDamage(self, ent)
            end
        end
    end

    owner:EmitSound(self.AttackSound, 35, 100, 0.5)
    owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
    if SERVER then
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local trace = owner:GetEyeTrace()

        if trace.Hit and trace.HitNormal:Dot(owner:GetForward()) < -0.5 then
            local wallNormal = trace.HitNormal
            local wallDir = wallNormal:Cross(Vector(0, 0, 1)):GetNormalized()
            local climbDir = wallDir:Cross(wallNormal):GetNormalized()

            local maxClimbDistance = 50

            local distanceToWall = trace.StartPos:Distance(trace.HitPos)

            if distanceToWall <= maxClimbDistance then
                local originalGravity = owner:GetGravity()

                local climbSpeed = 25

                local climbDuration = 2.5

                local maxClimbHeight = 200

                local climbHeight = math.min(climbSpeed * climbDuration, maxClimbHeight)

                local climbOffset = climbDir * climbHeight
                local climbPosition = owner:GetPos() + climbOffset

                local tr = util.TraceHull({
                    start = owner:GetPos(),
                    endpos = climbPosition,
                    filter = owner,
                    mins = owner:OBBMins(),
                    maxs = owner:OBBMaxs()
                })

                if not tr.Hit then
                    owner:SetGroundEntity(NULL)
                    owner:SetPos(climbPosition)

                    timer.Simple(climbDuration, function()
                        if IsValid(owner) then
                            owner:SetGravity(originalGravity)
                        end
                    end)
                end
            end
        end
    end
end

hook.Add("EntityTakeDamage", "NoFallDamage", function(target, dmginfo)
    if target:IsPlayer() and dmginfo:IsFallDamage() then
        if target:GetActiveWeapon():IsValid() and target:GetActiveWeapon():GetClass() == "transfo3arme" then
            dmginfo:SetDamage(0)
        end
    end
end)