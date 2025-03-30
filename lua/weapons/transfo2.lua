if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Transformation 2"
SWEP.Author = "SNZ Lucmodzzz"
SWEP.Category = "Transformations"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Secondary.ClipSize = -1

SWEP.Primary.DefaultClip = -1
SWEP.Secondary.DefaultClip = -1

SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

SWEP.CanTransform = true
SWEP.TransformationModel = "models/echo/ark/toad_pm.mdl"
SWEP.TransformationSpeedBoost = 2
SWEP.TransformationJumpBoost = 1.5
SWEP.WeaponToGive = "transfo2arme"

SWEP.Cooldown = 10
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local TransformationTime = 60

SWEP.IsJumpingAfterTransformation = false

function SWEP:Initialize()
    self:SetHoldType("fist")
end

local function PlayParticleEffect(player, effectName, duration)
    local ent = ents.Create("info_particle_system")
    ent:SetKeyValue("effect_name", effectName)
    ent:SetPos(player:GetPos())
    ent:Spawn()
    ent:Activate()
    ent:Fire("Start", "", 0)
    ent:Fire("Kill", "", duration)
end

local function AdjustModelScale(player, targetScale, duration, onComplete)
    local initialScale = player:GetModelScale()
    local scaleStep = (targetScale - initialScale) / (duration / 0.1)
    local currentStep = 0
    
    timer.Create("AdjustModelScaleTimer_" .. player:EntIndex(), 0.1, duration / 0.1, function()
        if not IsValid(player) then return end
        currentStep = currentStep + 1
        player:SetModelScale(initialScale + scaleStep * currentStep, 0)
        
        if currentStep >= duration / 0.1 then
            if onComplete then onComplete() end
            PlayParticleEffect(player, "[7]_pushwave", 2)
        end
    end)
end

SWEP.CooldownTime = 10
SWEP.LastTransformationTime = 0

local GeneralCooldown = 12

local PlayerLastTransformationTimes = {}

function SWEP:CanTransformNow()
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end

    local currentTime = CurTime()
    local lastTransformationTime = PlayerLastTransformationTimes[owner:SteamID()] or 0
    
    return currentTime >= lastTransformationTime + GeneralCooldown and currentTime >= self.LastTransformationTime + self.CooldownTime
end

function SWEP:SetCooldown()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.LastTransformationTime = CurTime()
    PlayerLastTransformationTimes[owner:SteamID()] = CurTime()
end

local function SafeSetModel(player, model)
    local originalSetModel = FindMetaTable("Player").SetModel
    FindMetaTable("Player").SetModel = SetMDL

    player:SetModel(model)

    FindMetaTable("Player").SetModel = originalSetModel
end

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
    if CLIENT then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    if owner.IsTransformed then
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu es déjà transformé")
        return
    end
    
    if self.CanTransform and self:CanTransformNow() then
        owner.IsTransformed = true 
        
        owner.PreviousModel = owner:GetModel()
        owner.PreviousWalkSpeed = owner:GetWalkSpeed()
        owner.PreviousRunSpeed = owner:GetRunSpeed()
        owner.PreviousJumpPower = owner:GetJumpPower()
        owner.PreviousModelScale = owner:GetModelScale()
        
        owner.PreviousWeapons = {}
        for _, weapon in pairs(owner:GetWeapons()) do
            if weapon ~= self then
                table.insert(owner.PreviousWeapons, weapon:GetClass())
                owner:StripWeapon(weapon:GetClass())
            end
        end
        
        AdjustModelScale(owner, 0.1, 2, function()
            if not IsValid(owner) then return end
            
            SafeSetModel(owner, self.TransformationModel)
            owner:SetModelScale(1, 0)
            owner:SetWalkSpeed(owner.PreviousWalkSpeed * self.TransformationSpeedBoost)
            owner:SetJumpPower(owner.PreviousJumpPower * self.TransformationJumpBoost)
            owner:SetRunSpeed(owner.PreviousRunSpeed * self.TransformationSpeedBoost)
            
            owner:Give(self.WeaponToGive)
            
            local newWeapon = owner:GetWeapon(self.WeaponToGive)
            if IsValid(newWeapon) then
                owner:SelectWeapon(newWeapon:GetClass())
            end
    
            self.CanTransform = false
            self.IsJumpingAfterTransformation = true
            
            timer.Simple(TransformationTime, function()
                if IsValid(self) and IsValid(owner) and not owner:IsBot() and not self.CanTransform then
                    self:CancelTransformation(owner)
                end
            end)
        end)
        
        self:SetCooldown()
    elseif not self.CanTransform then
        self:CancelTransformation(owner)
    end
    self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not self.CanTransform then
        self:CancelTransformation(owner)
    end
end

function SWEP:Reload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not self.CanTransform then
        self:CancelTransformation(owner)
    end
end

function SWEP:CancelTransformation(owner)
    if not IsValid(owner) then return end

    SafeSetModel(owner, owner.PreviousModel)
    owner:SetWalkSpeed(owner.PreviousWalkSpeed)
    owner:SetJumpPower(owner.PreviousJumpPower)
    owner:SetRunSpeed(owner.PreviousRunSpeed)
    
    for _, weapon in pairs(owner:GetWeapons()) do
        if weapon ~= self then
            owner:StripWeapon(weapon:GetClass())
        end
    end
    
    for _, weaponClass in ipairs(owner.PreviousWeapons) do
        owner:Give(weaponClass)
    end
    
    self.CanTransform = true
    self.IsJumpingAfterTransformation = false
    
    timer.Simple(1, function()
        owner.IsTransformed = false 
    
        self:SetCooldown()
    end)
end

hook.Add("PlayerShouldTakeDamage", "PreventFallDamageAfterTransformation2", function(player, attacker)
    if IsValid(player) and player:IsPlayer() then
        local weapon = player:GetActiveWeapon()
        if IsValid(weapon) and (weapon:GetClass() == "weapon_transformation1" or weapon:GetClass() == "weapon_transformation2") and weapon.IsJumpingAfterTransformation then
            return false
        end
    end
end)

hook.Add("PlayerDeath", "ResetPlayerModelOnDeath2", function(player)
    if IsValid(player) and player.PreviousModel then
        player:SetModel(player.PreviousModel)
        player:SetModelScale(player.PreviousModelScale or 1, 0)
        player.IsTransformed = false 
    end
end)