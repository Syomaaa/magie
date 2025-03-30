if CLIENT then
    SWEP.PrintName = "Stellaire 3"
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

SWEP.CooldownTime = 10
SWEP.LastAttackTime = 0
SWEP.Cooldown = 13
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local RemoveTimer = 3 -- Temps que le swep reste (10 coup par secondes)
local DamageTicks = 3 -- Damage par coup (ducoup y'a plusieurs coups.)
local MaxDistance = 2000 -- Distance max pour lancer l'attaque.
local AttractionForce = 500 -- La force d'attraction ducoup
local HitboxSize = 500

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
    if CLIENT then return end
    
    local ply = self:GetOwner()

    local function AttackLoop()
        local curTime = CurTime()
        
        if curTime - self.LastAttackTime >= self.CooldownTime then
            local trace = ply:GetEyeTrace()

            local maxPlacementDistance = MaxDistance
            if ply:GetPos():DistToSqr(trace.HitPos) > maxPlacementDistance * maxPlacementDistance then
                return
            end

            local position = trace.HitPos
            position.z = position.z - -75

            local initialPosition = position
            local finalPosition = position + Vector(0, 0, 500)
            local duration = RemoveTimer
            local smoothingFactor = 2

            local ent = ents.Create("info_particle_system")
            ent:SetKeyValue("effect_name", "glan_blackroll2")
            ent:SetPos(position)
            ent:Spawn()
            ent:Activate()
            ent:Fire("Start", "", 0)
            ent:Fire("Kill", "", RemoveTimer)

            local ent2 = ents.Create("info_particle_system")
            ent2:SetKeyValue("effect_name", "[23]_water_prison")
            ent2:SetPos(position)
            ent2:Spawn()
            ent2:Activate()
            ent2:Fire("Start", "", 0)
            ent2:Fire("Kill", "", RemoveTimer)

            local function AttractEntities()
                local entities = ents.FindInSphere(position, HitboxSize)
                for _, ent in ipairs(entities) do
                    if IsValid(ent) and ent ~= ply and (ent:IsPlayer() or ent:IsNPC() or type(ent) == "NextBot") then
                        local direction = (position - ent:GetPos()):GetNormalized()
                        local force = direction * AttractionForce
                        local phys = ent:GetPhysicsObject()
                        if IsValid(phys) then
                            if ent:IsPlayer() or ent:IsNPC() or type(ent) == "NextBot" then
                                local initialVelocity = ent:GetVelocity() or Vector(0, 0, 0)
                                local resistForce = initialVelocity * -1
                                ent:SetVelocity(force + resistForce)
                                ent:TakeDamage(DamageTicks, ply, ply)
                            else
                                phys:ApplyForceCenter(force * phys:GetMass())
                            end
                        end
                    end
                end
            end

            timer.Simple(duration, function()
                if IsValid(ent) then
                    ent:Remove()
                end
                if IsValid(ent2) then
                    ent2:Remove()
                end
            end)

            timer.Create("AttractionTimer", 0.1, 30, AttractEntities)

            ply:EmitSound("ambient/levels/citadel/portal_beam_shoot1.wav", 75, 100, 1, CHAN_WEAPON)

            self.LastAttackTime = curTime

            local startTime = CurTime()

            hook.Add("Think", "MoveParticle", function()
                local elapsedTime = CurTime() - startTime
                if IsValid(ent) and elapsedTime <= duration then
                    local progress = elapsedTime / duration
                    position.z = Lerp(progress^smoothingFactor, initialPosition.z, finalPosition.z)
                    ent:SetPos(position)

                    AttractEntities()

                    if IsValid(ent2) then
                        ent2:SetPos(position)
                    end
                else
                    hook.Remove("Think", "MoveParticle")
                end
            end)

            timer.Simple(duration, function()
                local expelForce = Vector(0, 0, 1)
                local entities = ents.FindInSphere(position, HitboxSize)
                for _, ent in ipairs(entities) do
                    if IsValid(ent) and ent:GetClass() ~= "player" and not ent:IsNPC() and type(ent) ~= "NextBot" then
                        local phys = ent:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:ApplyForceCenter(expelForce * phys:GetMass())
                        end
                    end
                end
            end)
        end
    end

    hook.Add("Think", "PrimaryAttackThink", function()
        if not IsValid(ply) or not ply:Alive() or not ply:KeyDown(IN_ATTACK) then
            hook.Remove("Think", "PrimaryAttackThink")
            return
        end

        AttackLoop()
    end)
    self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
	self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true
end

function SWEP:Initialize()
    self:SetHoldType("magic")
    self.LastAttackTime = 0
end

SWEP.CooldownTime1 = 15

local RemoveTimer = 3
local DamageTicks = 35
local MaxDistance = 2000
local AttractionForce = 1250
local HitboxSize = 500

function SWEP:SecondaryAttack()
    if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
    if CLIENT then return end
    
    local ply = self:GetOwner()

    local function AttackLoop()
        local curTime = CurTime()
        
        if curTime - self.LastAttackTime >= self.CooldownTime1 then
            local trace = ply:GetEyeTrace()

            local maxPlacementDistance = MaxDistance
            if ply:GetPos():DistToSqr(trace.HitPos) > maxPlacementDistance * maxPlacementDistance then
                return
            end

            local position = trace.HitPos

            local particlePosition = position + Vector(0, 0, 100)
            local ent = ents.Create("info_particle_system")
            ent:SetKeyValue("effect_name", "glan_blackroll2")
            ent:SetPos(particlePosition)
            ent:Spawn()
            ent:Activate()
            ent:Fire("Start", "", 0)
            ent:Fire("Kill", "", RemoveTimer)
			
			local ent2 = ents.Create("info_particle_system")
			ent2:SetKeyValue("effect_name", "[23]_water_prison")
			ent2:SetPos(particlePosition)
			ent2:Spawn()
			ent2:Activate()
			ent2:Fire("Start", "", 0)
			ent2:Fire("Kill", "", RemoveTimer)

            local function InHitbox(ent)
                local entPos = ent:GetPos()
                return entPos:DistToSqr(position) <= HitboxSize * HitboxSize
            end

			local function AttractPlayers()
				local entities = ents.FindInSphere(position, HitboxSize)
				for _, ent in ipairs(entities) do
					if IsValid(ent) and ent ~= ply and (ent:IsPlayer() or ent:IsNPC() or type(ent) == "NextBot") then 
						local distance = position:Distance(ent:GetPos())
						local attractionFactor = 1 - math.min(1, distance / HitboxSize)
						local direction = (position - ent:GetPos()):GetNormalized()
						local force = direction * (-AttractionForce) * attractionFactor
						ent:SetVelocity(force)
                        ent:TakeDamage(DamageTicks, ply, ply)
					end
				end
			end

            timer.Create("AttractionTimer", 0.1, 30, AttractPlayers)

            timer.Simple(RemoveTimer, function()
                if IsValid(ent) then
                    ent:Remove()
                end
            end)

            ply:EmitSound("ambient/levels/citadel/portal_beam_shoot1.wav", 75, 100, 1, CHAN_WEAPON)

            self.LastAttackTime = curTime
        end
    end

    hook.Add("Think", "SecondaryAttackThink", function()
        if not IsValid(ply) or not ply:Alive() or not ply:KeyDown(IN_ATTACK2) then
            hook.Remove("Think", "SecondaryAttackThink")
            return
        end

        AttackLoop()
    end)
    self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
	self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true
end