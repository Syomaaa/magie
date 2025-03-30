if CLIENT then
    SWEP.PrintName = "Stellaire 2"
    SWEP.Slot = 0
    SWEP.SlotPos = 10
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
end

SWEP.Base = "weapon_base"
SWEP.Category = "Stellaire"

SWEP.Author = "{SNZ} Lucmodzzz/Uki"
SWEP.Instructions = "Clic gauche pour créer un trou noir qui attire les joueurs"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType("magic")
end

SWEP.CooldownTime = 5
SWEP.LastAttackTime = 0
SWEP.Cooldown = 10
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local RemoveTimer = 1 -- Temps que le swep reste (donc le temps qu'elle prend pour arrivé au sol)
local DamageTicks = 150
local HitboxSize = 350 -- Taille de la hitbox pour l'application des dégâts

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
    if CLIENT then return end
    
    local ply = self:GetOwner()

    local maxDistance = 2500

    local trace = ply:GetEyeTrace()
    local hitPos = trace.HitPos

    if ply:GetPos():DistToSqr(hitPos) <= maxDistance^2 then
        local function AttackLoop()
            local curTime = CurTime()
            
            if curTime - self.LastAttackTime >= self.CooldownTime then
                local offsetX = math.random(2000, -2000)
                local offsetY = math.random() > 0.5 and 2000 or -2000
                local startPos = hitPos + Vector(offsetX, offsetY, 1250)
                local endPos = ply:GetEyeTrace().HitPos + Vector(0, 0, 500)

                local totalDamage = DamageTicks
                local numDamageTicks = 9
                local damageInterval = 0.20
                local currentDamage = totalDamage / numDamageTicks

                local function ApplyDamage()
                    local entities = ents.FindInSphere(hitPos, HitboxSize)
                    for _, ent in ipairs(entities) do
                        if IsValid(ent) and ent ~= ply and (ent:IsPlayer() or ent:IsNPC()) then
                            ent:TakeDamage(currentDamage, ply, ply)
                        end
                    end
                end

                local timerName = "DamageTimer_" .. tostring(math.random(1, 999999))
                local damageTimerCount = 0
                timer.Create(timerName, damageInterval, numDamageTicks, function()
                    damageTimerCount = damageTimerCount + 1
                    if damageTimerCount <= numDamageTicks then
                        ApplyDamage()
                    else
                        timer.Remove(timerName)
                    end
                end)

                local ent = ents.Create("info_particle_system")
                ent:SetKeyValue("effect_name", "[10]_spin_dash")
                ent:SetPos(startPos)
                ent:Spawn()
                ent:Activate()
                ent:Fire("Start", "", 0)
                ent:Fire("Kill", "", RemoveTimer)
                
                local ent2 = ents.Create("info_particle_system")
                ent2:SetKeyValue("effect_name", "[10]_spin_dash")
                ent2:SetPos(startPos)
                ent2:Spawn()
                ent2:Activate()
                ent2:Fire("Start", "", 0)
                ent2:Fire("Kill", "", RemoveTimer)

                local hitbox = ents.Create("prop_physics")
                hitbox:SetModel("models/lordtrilobite/starwars/props/planet_skybox_small.mdl")
                hitbox:SetPos(startPos)
                hitbox:SetModelScale(0.25)
                hitbox:SetSolid(SOLID_NONE)
                hitbox:Spawn()

                local asteroidRotation = 0

                local function MoveComet()
                    local elapsedTime = CurTime() - curTime
                    local progress = elapsedTime / RemoveTimer
                    progress = progress * 2
                
                    local newPos = LerpVector(progress, startPos, endPos - Vector(0, 0, 500))

                    ent:SetPos(newPos)
                    hitbox:SetPos(newPos)

                    asteroidRotation = asteroidRotation + 50 * FrameTime()
                    hitbox:SetAngles(Angle(0, asteroidRotation, 0))

                    hitPos = newPos

                    if progress >= 1 then
                        ent:Remove()
                        hitbox:Remove()
                        hook.Remove("Think", "MoveComet")
                    
                        local explosionParticle1 = ents.Create("info_particle_system")
                        explosionParticle1:SetKeyValue("effect_name", "[10]_rengoku_start")
                        explosionParticle1:SetPos(hitPos)
                        explosionParticle1:Spawn()
                        explosionParticle1:Activate()
                        explosionParticle1:Fire("Start", "", 0)
                        explosionParticle1:Fire("Kill", "", 1)
						local explosionParticle2 = ents.Create("info_particle_system")
                    explosionParticle2:SetKeyValue("effect_name", "[10]_rengoku_start")
                    explosionParticle2:SetPos(hitPos)
                    explosionParticle2:Spawn()
                    explosionParticle2:Activate()
                    explosionParticle2:Fire("Start", "", 0)
                    explosionParticle2:Fire("Kill", "", 1)
                
                    sound.Play("weapons/explode1.wav", hitPos, 100, 100, 1)
                
                    local entities = ents.FindInSphere(hitPos, HitboxSize)
                    for _, ent in ipairs(entities) do
                        if IsValid(ent) and ent ~= ply and (ent:IsPlayer() or ent:IsNPC() or type(ent) == "NextBot") then
                            ent:TakeDamage(DamageTicks, ply, ply)
                        end
                    end
                end
            end

            hook.Add("Think", "MoveComet", MoveComet)
            
            local particleAngle = Angle(0, 90, 0)

            local function MoveComet2()
                local elapsedTime = CurTime() - curTime
                local progress = elapsedTime / RemoveTimer
                progress = progress * 2
                
                local newPos = LerpVector(progress, startPos, endPos - Vector(0, 0, 500))
            
                ent2:SetPos(newPos)
                ent2:SetAngles(particleAngle)
            
                if progress >= 1 then
                    ent2:Remove()
                    hook.Remove("Think", "MoveComet2")
                end
            end

            hook.Add("Think", "MoveComet2", MoveComet2)

            ply:EmitSound("ambient/levels/citadel/portal_beam_shoot1.wav", 75, 100, 1, CHAN_WEAPON)

            self.LastAttackTime = curTime
        end
    end

    hook.Add("Think", "PrimaryAttackThink", function()
        if not IsValid(ply) or not ply:Alive() or not ply:KeyDown(IN_ATTACK) then
            hook.Remove("Think", "PrimaryAttackThink")
            return
        end

        AttackLoop()
    end)
end
self.CooldownDelay = CurTime() + self.Cooldown
self.NextAction = CurTime() + self.ActionDelay
else		
self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
end
end

function SWEP:SecondaryAttack()
end