AddCSLuaFile()

SWEP.PrintName = "Mercure 4"
SWEP.Author = "tomlap77"
SWEP.Instructions = ""
SWEP.Category = "Mercure"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel = ""
SWEP.Base = "weapon_base"
SWEP.Slot = 2
SWEP.SlotPos = 3
SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawCrosshair = true

SWEP.Cooldown = 20
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

function SWEP:PrimaryAttack()
	if SERVER then
	    
		if self.NextAction > CurTime() then return end
	    if self.CooldownDelay < CurTime() then if !SERVER then return end

		local trace = {}
		local mark = self.Owner:GetEyeTrace()
		trace.start = mark.HitPos
		trace.endpos = mark.HitPos + Vector(0,0,-99999)
		check = util.TraceLine(trace)
		timer.Create("firestorma" .. self.Owner:Nick(), 0.01, 15, function()
			local air = check.HitPos - Vector(math.random(-300,300),math.random(-300,300),-300)
			local attack = ents.Create("ent_mercure")
			attack:SetPos(air)
			attack:SetOwner(self:GetOwner())
			attack:Spawn()	
			attack:EmitSound( "weapons/debris1.wav" , 100, 100,0.3)
		end)
		function ENT:Think() if !SERVER then return end
        if !self.XDEBZ_Hit then
            self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*20000 ) 
        end 
        end
	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
	self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Initialize()

	self:SetHoldType( "magic" )

end