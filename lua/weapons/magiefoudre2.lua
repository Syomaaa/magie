if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Foudre 2"
SWEP.Author = "SNZ Lucmodzzz"
SWEP.Purpose = "Dash de foudre qui fait des dégâts"
SWEP.Instructions = "Clic gauche pour faire un dash/slash de foudre."

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Foudre"

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Primary.Ammo = "none"

SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.Slot = 0
SWEP.SlotPos = 5

SWEP.Cooldown = 3
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

function SWEP:Initialize()
    self:SetHoldType("magic")
end

SWEP.MaxDashDistance = 1000

if SERVER then
    function SWEP:CreateDashParticles(position, direction)
        local particlePosition = position + Vector(0, 0, 50)
        local ent = ents.Create("info_particle_system")
        
        if not IsValid(ent) then return end
        
        ent:SetKeyValue("effect_name", "[14]_lightning_sphere_trail_2")
        
        local angle = direction:Angle()
        ent:SetAngles(angle)
        
        ent:SetPos(particlePosition)
        ent:Spawn()
        ent:Activate()
        ent:Fire("Start", "", 0)
        local RemoveTimer = 1
        ent:Fire("Kill", "", RemoveTimer)
    end
end

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay > CurTime() then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self:GetNextPrimaryFire() > CurTime() then
        return
    end
    
    self.CooldownDelay = CurTime() + self.Cooldown
    self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown .. "s de cooldown !")

    local lookDir = owner:EyeAngles():Forward()

    local tr = owner:GetEyeTrace()
    local destination = tr.HitPos

    local teleportDistance = 500
    local startPos = owner:GetPos() + Vector(0, 0, 50)
    local teleportPosition = startPos + lookDir * teleportDistance

    owner:SetPos(teleportPosition)

    local direction = (destination - startPos):GetNormalized()
    local distance = startPos:Distance(destination)

    local endPosGround = util.TraceLine({
        start = destination,
        endpos = destination - Vector(0, 0, 100),
        mask = MASK_SOLID
    })

    if not endPosGround.Hit then return end

    if distance > self.MaxDashDistance then
        destination = startPos + direction * self.MaxDashDistance
        distance = self.MaxDashDistance
    end

    local stepThreshold = 150
    local numSteps = math.ceil(distance / stepThreshold)

    local coveredPositions = {}

    if tr.Entity:IsValid() and tr.Entity:IsPlayer() then
        for i = 1, numSteps do
            local stepFraction = i / numSteps
            local dashPosition = LerpVector(stepFraction, startPos, destination)

            local tooClose = false
            for _, coveredPos in ipairs(coveredPositions) do
                if dashPosition:Distance(coveredPos) < 50 then
                    tooClose = true
                    break
                end
            end

            if not tooClose then
                local targetPos = tr.Entity:GetPos()
                local distanceToTarget = dashPosition:Distance(targetPos)
                local behindTargetPos = targetPos - direction * -150
                dashPosition = LerpVector(math.min(distanceToTarget / distance, 1), dashPosition, behindTargetPos)

                owner:SetPos(dashPosition)

                owner:SetNWBool("IsDashing", true)
                timer.Simple(0.2, function() 
                    if IsValid(owner) then
                        owner:SetNWBool("IsDashing", false)
                    end
                end)

                self:InflictDamageAroundOwner(owner, dashPosition)
                if SERVER then
                    self:CreateDashParticles(dashPosition, direction)
                end

                table.insert(coveredPositions, dashPosition)

                break
            end
        end
    else
        for i = 1, numSteps do
            local stepFraction = i / numSteps
            local dashPosition = LerpVector(stepFraction, startPos, destination)

            owner:SetPos(dashPosition)

            owner:SetNWBool("IsDashing", true)
            timer.Simple(0.2, function()
                if IsValid(owner) then
                    owner:SetNWBool("IsDashing", false)
                end
            end)

            self:InflictDamageAroundOwner(owner, dashPosition)
            if SERVER then
                self:CreateDashParticles(dashPosition, direction)
            end

            table.insert(coveredPositions, dashPosition)
        end
    end
    self.CooldownDelay = CurTime() + self.Cooldown
    self.NextAction = CurTime() + self.ActionDelay
end

function SWEP:InflictDamageAroundOwner(owner, destination)
    local entities = ents.FindInSphere(destination, 100)

    for _, entity in ipairs(entities) do
        if IsValid(entity) and entity ~= owner and (entity:IsPlayer() or entity:IsNPC()) then
            local damageInfo = DamageInfo()
            damageInfo:SetAttacker(owner)
            damageInfo:SetInflictor(self)
            damageInfo:SetDamage(75)
            entity:TakeDamage(75, owner, self) 
        end
    end
end

function SWEP:SecondaryAttack() 
end