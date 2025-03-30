if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Transformation 2 Acid"
SWEP.Author = "SNZ Uki/Lucmodzzz"
SWEP.Category = "Transformations"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ShootDistance = 2500
SWEP.MaxProjectileDistance = 5000

function SWEP:Initialize()
    self:SetHoldType("fist")
end

SWEP.HitboxSize = 125
local Damage = 100

function SWEP:PrimaryAttack()
    if not IsValid(self) or not IsValid(self.Owner) then return end
    
    local function AttackLoop()
        if not IsValid(self) or not IsValid(self.Owner) or not self.Owner:Alive() or not self.Owner:KeyDown(IN_ATTACK) then return end
        
        self:SetNextPrimaryFire(CurTime() + 1)
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        
        self.Owner:SetAnimation(PLAYER_ATTACK1)

        local startPos = self.Owner:GetShootPos()
        local endPos = startPos + self.Owner:GetAimVector() * self.ShootDistance
        local tr = util.TraceLine({
            start = startPos,
            endpos = endPos,
            filter = self.Owner
        })

        local hitPos = tr.HitPos

        if SERVER then
            local ent = ents.Create("info_particle_system")
            if IsValid(ent) then
                local particleName = "[8]magic_portal*"
                local attractionForce = -5000
                local currentRotation = Angle(0, 0, 0)
                local particlePosition = startPos + Vector(0, 0, 50)
                currentRotation.yaw = currentRotation.yaw + (100 * FrameTime())
                ent:SetAngles(currentRotation)
                ent:SetKeyValue("effect_name", particleName)
                ent:SetPos(particlePosition)
                ent:Spawn()
                ent:Activate()
                ent:Fire("Start", "", 0)

                local particleVelocity = (hitPos - particlePosition):GetNormalized() * 3500
                local gravity = Vector(0, 0, -600)

                local function removeParticle()
                    if IsValid(ent) then
                        ent:Fire("Kill", "", 0)
                    end
                end

                timer.Simple(self.MaxProjectileDistance / 2000, removeParticle)

                local entitiesAffected = {}

                hook.Add("Think", "MoveParticle" .. ent:EntIndex(), function()
                    if IsValid(ent) then
                        currentRotation.yaw = currentRotation.yaw + (250 * FrameTime())
                        ent:SetAngles(currentRotation)

                        local tr = util.TraceLine({
                            start = particlePosition,
                            endpos = particlePosition + particleVelocity * FrameTime(),
                            mask = MASK_SOLID_BRUSHONLY
                        })

                        sound.Add({
                            name = "explo",
                            channel = CHAN_STATIC,
                            volume = 0.5,
                            level = 85,
                            pitch = {100, 100},
                            sound = "weapons/explode1.wav"
                        })

                        if tr.Hit then
                            removeParticle()
                            hook.Remove("Think", "MoveParticle" .. ent:EntIndex())

                            local impactParticle = ents.Create("info_particle_system")
                            if IsValid(impactParticle) then
                                impactParticle:SetKeyValue("effect_name", "[25]_swamp_ground")
                                impactParticle:SetPos(tr.HitPos)
                                impactParticle:Spawn()
                                impactParticle:Activate()
                                impactParticle:Fire("Start", "", 0.1)
                                timer.Simple(1, function()
                                    if IsValid(impactParticle) then
                                        impactParticle:Fire("Kill", "", 0)
                                    end
                                end)
                                sound.Play("explo", tr.HitPos, 37.5, 100, 1)
                            end

                            local progressiveDamage = 15
                            local poisonDuration = 5
                            local poisonTickRate = 1

                            local startTime = CurTime()
                            timer.Create("PoisonEffect", poisonTickRate, poisonDuration, function()
                                for _, entity in ipairs(ents.FindInSphere(tr.HitPos, 100)) do
                                    if entity:IsPlayer() and entity != self.Owner then
                                        local dmgInfo = DamageInfo()
                                        dmgInfo:SetAttacker(self.Owner)
                                        dmgInfo:SetInflictor(self)
                                        dmgInfo:SetDamage(progressiveDamage)
                                        entity:TakeDamageInfo(dmgInfo)
                                    end
                                end
                            end)

                            return
                        end

                        particleVelocity = particleVelocity + gravity * FrameTime()

                        particlePosition = particlePosition + particleVelocity * FrameTime()
                        ent:SetPos(particlePosition)

                        if (particlePosition - startPos):Length() >= self.MaxProjectileDistance then
                            removeParticle()
                            hook.Remove("Think", "MoveParticle" .. ent:EntIndex())
                        end

                        local entities = ents.FindInSphere(particlePosition, self.HitboxSize)
                        for _, entity in ipairs(entities) do
                            if IsValid(entity) and entity != self.Owner and (entity:IsPlayer() or entity:IsNPC() or (type(entity) == "NextBot")) then
                                entitiesAffected[entity] = true
                                local forceDirection = (particlePosition - entity:GetPos()):GetNormalized()
                                local distanceToBlackHole = (particlePosition - entity:GetPos()):Length()
                                local velocityChange = forceDirection * attractionForce * FrameTime()
                                local verticalForce = Vector(0, 0, -velocityChange.z)
                                entity:SetVelocity(entity:GetVelocity() + velocityChange + verticalForce)

                                local dmgInfo = DamageInfo()
                                dmgInfo:SetAttacker(self.Owner)
                                dmgInfo:SetInflictor(self)
                                dmgInfo:SetDamage(Damage)
                                entity:TakeDamageInfo(dmgInfo)
                            end
                        end
                    else
                        hook.Remove("Think", "MoveParticle" .. ent:EntIndex())
                    end
                end)
            end
        end

        timer.Simple(1, AttackLoop)
    end

    AttackLoop()
end

function SWEP:SecondaryAttack()

end

hook.Add("PlayerShouldTakeDamage", "DisableFallDamage_Transfo2", function(ply, attacker)
    if ply:KeyDown(IN_JUMP) and ply:GetActiveWeapon():GetClass() == "transfo2arme" then
        return false
    end
end)

hook.Add("GetFallDamage", "DisableFallDamage_Transfo2", function(ply, speed)
    if ply:GetActiveWeapon():GetClass() == "transfo2arme" then
        return 0
    end
end)