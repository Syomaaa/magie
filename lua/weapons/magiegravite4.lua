SWEP.PrintName          = "Gravité 4" 
SWEP.Author             = "Brounix" 
SWEP.Instructions       = "" 
SWEP.Contact            = "" 
SWEP.AdminSpawnable     = true 
SWEP.Spawnable          = true 
SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 85
SWEP.ViewModel          = ""
SWEP.WorldModel         = ""
SWEP.AutoSwitchTo       = false 
SWEP.AutoSwitchFrom     = true 
SWEP.DrawAmmo           = false 
SWEP.Base               = "weapon_base" 
SWEP.Slot               = 2
SWEP.SlotPos            = 1 
SWEP.HoldType           = "magic"
SWEP.DrawCrosshair      = true 
SWEP.Weight             = 0 

SWEP.Category           = "Gravité"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "None"

SWEP.Secondary.ClipSize     = 0
SWEP.Secondary.DefaultClip  = 0
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"

SWEP.Cooldown = 20

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 30
config.dmg2 = 35    -- degat des pierres

config.tmp = 5    -- temps dans les airs
config.zone = 500

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
    self:SetHoldType("magic")
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay < CurTime() then
        if not SERVER then return end
        
        local own = self:GetOwner()
        local entsInRadius = ents.FindInSphere(own:GetPos(), config.zone)

        for _, tar in ipairs(entsInRadius) do
            if IsValid(tar) and tar != own and (tar:IsPlayer() or tar:IsNPC() or type(tar) == "NextBot") then
                self.enemy = tar

                if tar:IsPlayer() then
                    local weapon = tar:GetWeapon("keys")
                    if IsValid(weapon) then
                        tar:SelectWeapon(weapon)
                    end
                end

                tar:SetVelocity(tar:GetUp() * 800)

                timer.Simple(1, function() 
                    if IsValid(tar) and tar != own then
                        tar:SetMoveType(MOVETYPE_NONE)

                        timer.Create("grav4" .. own:EntIndex(), 0.2, 15, function()
                            if IsValid(tar) then
                                local spawnPos = tar:GetPos() + Vector(math.random(-100, 250), math.random(-100, 250), 0)

                                local prop = ents.Create("gravite4")
                                prop:SetPos(spawnPos)
                                prop:SetOwner(own)
                                prop:Spawn()
                            
                                local phys = prop:GetPhysicsObject()
                                phys:SetVelocity((tar:GetPos() - prop:GetPos()):GetNormalized() * 1000)
                            end
                        end)
                    end
                end)

                timer.Simple(config.tmp, function() 
                    if IsValid(tar) and tar != own then
                        if tar:IsPlayer() then
                            tar:SetMoveType(MOVETYPE_WALK)
                        end 
                        if tar:IsNPC() then
                            tar:SetMoveType(MOVETYPE_STEP)
                        end
                    end
                    self.enemy = nil
                end)
            end
        end

        self.CooldownDelay = CurTime() + self.Cooldown
        self.NextAction = CurTime() + self.ActionDelay
    else
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown .. "s de cooldown !")
    end
end

function SWEP:Think()
    if self.enemy then
        if self.enemy:IsPlayer() then
            local weapon = self.enemy:GetWeapon("keys")
            if IsValid(weapon) then
                self.enemy:SelectWeapon(weapon)
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------

if true then
    local ENT = {}
    ENT.Base = "base_anim"
    ENT.PrintName = "gravite4"
    ENT.Spawnable = false
    ENT.RenderGroup = RENDERGROUP_BOTH
    ENT.XDEBZ_Broken = false  
    ENT.XDEBZ_FreezeTab = {}  
    ENT.XDEBZ_FreezeTic = 0  
    ENT.XDEBZ_Lap = 1  
    ENT.XDEBZ_Gre = 1
    function ENT:Initialize()
        self:DrawShadow(false)
        if not SERVER then return end
        self:SetModel("models/azsuna/mossyrock/mossyrock.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetModelScale(math.Rand(3,5), 0.1)
        self:SetColor(Color(100,100,100))
        self:SetAngles(Angle(math.random(0,360), math.random(0,360), math.random(0,360)))
        self:GetPhysicsObject():Wake()
        SafeRemoveEntityDelayed(self, config.tmp - 3)
        self.touch = true
    end
    function ENT:Think()
        if SERVER then
            for _, v in ipairs(ents.FindInSphere(self:GetPos(), 400)) do
                if IsValid(v) and IsValid(self) and v != self and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type(v) == "NextBot") and self.touch then
                    local dmginfo = DamageInfo()
                    dmginfo:SetDamageType(DMG_GENERIC)
                    dmginfo:SetDamage(math.random(config.dmg1, config.dmg2))
                    dmginfo:SetDamagePosition(self:GetPos())
                    dmginfo:SetAttacker(self.Owner)
                    dmginfo:SetInflictor(self.Owner)
                    v:TakeDamageInfo(dmginfo)
                    self:GetPhysicsObject():EnableMotion(false)
                    self:EmitSound("physics/concrete/concrete_break"..math.random(2,3)..".wav", 75, 60, 1)
                    self.touch = false
                end
            end
        end
        self:NextThink(CurTime() + 0.2)
        return true
    end
    if CLIENT then
        function ENT:Draw()
            render.SuppressEngineLighting(true)
            self:DrawModel()
            render.SuppressEngineLighting(false)
        end
    end
    scripted_ents.Register(ENT, "gravite4")
end