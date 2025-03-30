AddCSLuaFile()

SWEP.PrintName 		      = "Mercure 2" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 85
SWEP.ViewModel     		  = ""
SWEP.WorldModel           = ""
SWEP.AutoSwitchTo 	      = false 
SWEP.AutoSwitchFrom       = true 
SWEP.DrawAmmo             = false 
SWEP.Base                 = "weapon_base" 
SWEP.Slot 			      = 2
SWEP.SlotPos              = 1 
SWEP.HoldType             = "magic"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Mercure"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.tmp = 5
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

SWEP.Cooldown = 10
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
    if SERVER then
        if self.NextAction > CurTime() then return end
        if self.CooldownDelay < CurTime() then

            if IsValid(self.ent) then return end if !SERVER then return end
            self:SetNoDraw(true)
            self.ent = ents.Create("prop_physics")
            self.ent:SetModel("models/bouclierdeux.mdl")
            self.ent:SetPos(self.Owner:GetPos() + (self.Owner:GetForward()* 20) + self.Owner:EyeAngles():Right() * 40 *-0.40 + Vector(0,0,10))
            self.ent:SetAngles(Angle(0,self.Owner:EyeAngles().y+90,self.Owner:EyeAngles().r))
            self.ent:SetParent(self.Owner)
            self.ent:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01)
            self.ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
            self.ent:Spawn()
            self.ent:Activate()
            self.Owner:GodEnable()
            timer.Simple(self.tmp, function()
                if IsValid(self) && self:GetOwner():Alive() then
                    self.Owner:GodDisable()
                end
            end)
            SafeRemoveEntityDelayed( self.ent, self.tmp )

            self.CooldownDelay = CurTime() + self.Cooldown
            self.NextAction = CurTime() + self.ActionDelay
        else
            self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
        end
    end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Think()
    return true
end

function SWEP:Holster()
    return true
end