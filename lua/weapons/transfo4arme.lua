if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Transformation 4 Glider"
SWEP.Author = "SNZ Lucmodzzz"
SWEP.Instructions = "E pour planer, et clique gauche pour lancer des tornades."
SWEP.Category = "Transformations"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true
SWEP.DrawAmmo = false

SWEP.NextAction = 0
SWEP.CooldownDelay5 = 0
SWEP.ActionDelay = 1
SWEP.Cooldown5 = 3

function SWEP:Initialize()
    self:SetHoldType("normal")
    self.HasLanded = true
end

function SWEP:PrimaryAttack()
    self:FifthSpellLove()
end

function SWEP:FifthSpellLove()
    if IsValid(self) and self:GetOwner():Alive() then
        if self.NextAction > CurTime() then return end
        if self.CooldownDelay5 < CurTime() then if not SERVER then return end

            -- if not self.Owner:IsOnGround() then return false end

            local own = self.Owner

            self:SetNextSecondaryFire(CurTime() + 1)
            self:SetNextPrimaryFire(CurTime() + 1)

            timer.Simple(0, function()
                local saut = ents.Create("wind_jump")
                if not IsValid(saut) then return end
                saut:SetPos(self:GetPos() + Vector(0,0,100))
                saut:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                saut:SetOwner(own)
                saut:Spawn()
                saut:Activate()
                own:DeleteOnRemove(saut)
                saut:SetPhysicsAttacker(own)
                SafeRemoveEntityDelayed(saut, 0.2)
            end)

            self.Owner:SetVelocity(own:GetForward() * -600 + Vector(0, 0, 400))

            timer.Simple(0.01, function()
                if not IsValid(self) or not IsValid(self.Owner) then return end
            end)

            if SERVER then
                own:EmitSound("ambient/wind/wind_snippet5.wav", 60, 160, 0.6)
            end

            timer.Simple(0.5, function()
                if not IsValid(own) or not IsValid(self) then return end

                own:SetMoveType(MOVETYPE_NONE)
                self.Owner:SetVelocity(own:GetForward() * -400 + Vector(0, 0, -200))

                local dir = own:EyeAngles():Forward() * 1000000 + VectorRand():GetNormal() * 50

                local function create_love_projectile(offset)
                    local test = ents.Create("wind_tornado")
                    if not IsValid(test) then return end
                    test:SetPos(self:GetPos() + offset)
                    test:SetAngles(own:GetAngles())
                    test:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                    test:Spawn()
                    test:Activate()
                    test:SetOwner(own)
                    test:GetPhysicsObject():SetVelocity(dir)
                    own:DeleteOnRemove(test)
                    test:SetPhysicsAttacker(own)

                    timer.Create("tornado_damage_timer" .. test:EntIndex(), 0.1, 1, function()
                        if IsValid(test) then
                            local entities = ents.FindInSphere(test:GetPos(), 500)
                            for _, ent in ipairs(entities) do
                                if IsValid(ent) and ent != owner and (ent:IsPlayer() or ent:IsNPC() or (type(ent) == "NextBot")) then
                                    if ent ~= own then 
                                        local dmginfo = DamageInfo()
                                        dmginfo:SetDamage(250)
                                        dmginfo:SetDamageType(DMG_GENERIC) 
                                        dmginfo:SetAttacker(own)
                                        dmginfo:SetInflictor(test)
                                        dmginfo:SetDamagePosition(ent:GetPos())
                                        ent:TakeDamageInfo(dmginfo)
                                    end
                                end
                            end
                        end
                    end)

                    SafeRemoveEntityDelayed(test, 1)
                end

                create_love_projectile(Vector(0, 0, 0))
                create_love_projectile(own:GetRight() * 100)
                create_love_projectile(own:GetRight() * -100)
            end)

            timer.Simple(0.5, function()
                if IsValid(self) and IsValid(self:GetOwner()) and self:GetOwner():Alive() then
                    own:SetMoveType(MOVETYPE_WALK)
                elseif IsValid(own) and own:IsPlayer() and own:Alive() then
                    own:SetMoveType(MOVETYPE_WALK)
                end
                config.canSwitch = true
            end)

            self.CooldownDelay5 = CurTime() + self.Cooldown5
            self.NextAction = CurTime() + self.ActionDelay
        else
            self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown5 .. "s de cooldown pour la tornade !")
        end
    end
    return true
end

local teleportingPlayer = nil
local teleportOffset = Vector(0, 0, 150) 
local teleportRadius = 200

function SWEP:SecondaryAttack()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if teleportingPlayer == nil then
        local pos = owner:GetPos()
        local playersInSphere = ents.FindInSphere(pos, teleportRadius)
        local nearestPlayer = nil
        local nearestDistance = math.huge

        for _, ent in ipairs(playersInSphere) do
            if ent:IsPlayer() and ent ~= owner then
                local distance = pos:DistToSqr(ent:GetPos())
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = ent
                end
            end
        end

        if IsValid(nearestPlayer) then
            teleportingPlayer = nearestPlayer
            local teleportPos = owner:GetPos() + teleportOffset
            teleportingPlayer:SetPos(teleportPos)
        end
    end
end

function SWEP:Think()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if owner:KeyDown(IN_USE) then
        if not self.IsGliding then
            self.IsGliding = true
            owner:SetGravity(0.1)
            if self.HasLanded then
                owner:SetVelocity(Vector(0, 0, 100))
                self.HasLanded = false
            end
        end
    else
        if self.IsGliding then
            self.IsGliding = false
            owner:SetGravity(1)
        end
    end

    if IsValid(teleportingPlayer) then
        if owner:KeyDown(IN_ATTACK2) then
            local pos = owner:GetPos() + teleportOffset
            teleportingPlayer:SetPos(pos)
        else
            teleportingPlayer = nil 
        end
    end
end

function SWEP:Holster()
    if SERVER then
        local owner = self:GetOwner()
        owner:SetGravity(1)
    end
    return true
end

function SWEP:OnRemove()
    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:SetGravity(1)
        end
    end
end

function SWEP:Deploy()
    self.IsGliding = false
    return true
end

hook.Add("PlayerShouldTakeDamage", "DisableFallDamage_Transfo4", function(ply, attacker)
    local activeWeapon = ply:GetActiveWeapon()
    if IsValid(activeWeapon) and activeWeapon:GetClass() == "transfo4arme" then
        if ply:HasGodMode() then
            return false
        end
    end
end)

hook.Add("GetFallDamage", "DisableFallDamage_Transfo4", function(ply, speed)
    local activeWeapon = ply:GetActiveWeapon()
    if IsValid(activeWeapon) and activeWeapon:GetClass() == "transfo4arme" then
        return 0
    end
end)

hook.Add("OnPlayerHitGround", "ResetGlideBoost", function(ply, inWater, onFloater, speed)
    local activeWeapon = ply:GetActiveWeapon()
    if IsValid(activeWeapon) and activeWeapon:GetClass() == "transfo4arme" then
        activeWeapon.HasLanded = true
    end
end)

hook.Add("PlayerSwitchWeapon", "ResetGlideOnSwitch", function(ply, oldWeapon, newWeapon)
    if IsValid(oldWeapon) and oldWeapon:GetClass() == "transfo4arme" then
        ply:SetGravity(1)
        oldWeapon.IsGliding = false
    end
end)

hook.Add("PlayerDroppedWeapon", "ResetGlideOnDrop", function(ply, weapon)
    if IsValid(weapon) and weapon:GetClass() == "transfo4arme" then
        ply:SetGravity(1)
        weapon.IsGliding = false
    end
end)