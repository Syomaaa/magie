if SERVER then
    AddCSLuaFile()
end

if CLIENT then
    SWEP.PrintName = "Stellaire 1"
    SWEP.Slot = 0
    SWEP.SlotPos = 10
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
end


SWEP.Author = "SNZ Uki/Lucmodzzz"
SWEP.Category = "Stellaire"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = ""
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

SWEP.Cooldown = 0.2
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

function SWEP:Initialize()
    self:SetHoldType("magic")
end

SWEP.HitboxSize = 200
local Damage = 50

function SWEP:PrimaryAttack()
    local function AttackLoop()
        if self.NextAction > CurTime() then return end
	    if self.CooldownDelay < CurTime() then if !SERVER then return end
        if not self.Owner:KeyDown(IN_ATTACK) then return end

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
                local particleName = "glan_blackroll2"
                local attractionForce = 15000
                local currentRotation = Angle(0, 0, 0)
                local particlePosition = startPos + Vector(0, 0, 50)
                currentRotation.yaw = currentRotation.yaw + (100 * FrameTime())
                ent:SetAngles(currentRotation)
                ent:SetKeyValue("effect_name", particleName)
                ent:SetPos(particlePosition)
                ent:Spawn()
                ent:Activate()
                ent:Fire("Start", "", 0)

                local particleVelocity = (hitPos - particlePosition):GetNormalized() * 3000

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
                            local impactParticle2 = ents.Create("info_particle_system")
                            if IsValid(impactParticle2) then
                                impactParticle2:SetKeyValue("effect_name", "glan_bomb")
                                local higherPosition = tr.HitPos + Vector(0, 0, 50)
                                impactParticle2:SetPos(higherPosition)
                                impactParticle2:Spawn()
                                impactParticle2:Activate()
                                impactParticle2:Fire("Start", "", 0)
                                timer.Simple(1, function()
                                    if IsValid(impactParticle2) then
                                        impactParticle2:Fire("Kill", "", 0)
                                    end
                                end)
                            end
                            return
                        end

                        particlePosition = particlePosition + particleVelocity * FrameTime()
                        ent:SetPos(particlePosition)

                        if (particlePosition - startPos):Length() >= self.MaxProjectileDistance then
                            removeParticle()
                            hook.Remove("Think", "MoveParticle" .. ent:EntIndex())
                        end

                        local entities = ents.FindInSphere(particlePosition, self.HitboxSize)
                        for _, entity in ipairs(entities) do
                            if IsValid(entity) and entity != self.Owner and (entity:IsPlayer() or entity:IsNPC() or type(entity) == "NextBot") and not entitiesAffected[entity] then
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

        timer.Simple(0.75, AttackLoop)
        self.CooldownDelay = CurTime() + self.Cooldown
	    self.NextAction = CurTime() + self.ActionDelay
	    else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	    end
        return true
    end

    AttackLoop()
end

function SWEP:SecondaryAttack()
end