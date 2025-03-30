AddCSLuaFile()

SWEP.PrintName 		      = "Temps 4" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 85
SWEP.ViewModel      = ""
SWEP.WorldModel   	= ""
SWEP.AutoSwitchTo 	      = false 
SWEP.AutoSwitchFrom       = true 
SWEP.DrawAmmo             = false 
SWEP.Base                 = "weapon_base" 
SWEP.Slot 			      = 2
SWEP.SlotPos              = 1 
SWEP.HoldType             = "normal"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Temps"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 20
config.dmg2 = 20  -- dmg de .. à ..
config.tmp = 3
SWEP.laserTime = 3
SWEP.laser = false

SWEP.Cooldown = 13
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

local function LaserOn(own)
    local eyePos = own:EyePos()
    local eyeForward = own:EyeAngles():Forward()
    local tr = util.TraceLine({
        start = eyePos,
        endpos = eyePos + eyeForward * 5000,
        mask = MASK_NPCWORLDSTATIC, 
    })

    local pos = tr.HitPos + tr.HitNormal*8
    local effectdata = EffectData()
    effectdata:SetStart(pos)
    effectdata:SetOrigin(eyePos + eyeForward * 100)
    util.Effect("laser_ultralaser", effectdata)
    if SERVER then
        local tr = util.TraceHull({
            start = eyePos,
            endpos = eyePos + eyeForward * 5000,
            filter = function(ent)
                if ent == own then return end

                if ent:IsValid() then
                    ent:TakeDamage(math.random(config.dmg1, config.dmg2), own, self)
                    if ent:IsValid() then
                        return false
                    end
                end
            end,
            mins = Vector(-20, -20, -20),
            maxs = Vector(20, 20, 20),
            mask = MASK_SHOT_HULL
        })
    end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then 
    local own = self.Owner


        self.laser = true
        own:EmitSound("ambient/machines/electric_machine.wav", 75, 70,0.1)

        timer.Simple(config.tmp,function()
            if (IsValid(own) or own:Alive()) and IsValid(self) then 
                self.laser = false
                own:StopSound("ambient/machines/electric_machine.wav")
            end
        end)

        self.CooldownDelay = CurTime() + self.Cooldown
        self.NextAction = CurTime() + self.ActionDelay
    else		
        self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
    end
    return true
end

function SWEP:Think()
    local own = self.Owner

	if !IsValid(own) or !own:Alive() or !IsValid(self) then 
        own:StopSound("ambient/machines/electric_machine.wav")
        return 
    end

    if self.laser == true then
        LaserOn(own)
    end

    self:NextThink(CurTime())
    return true
end
-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	self.laser = false
	self.Owner:StopSound("ambient/machines/electric_machine.wav")
	return true
end