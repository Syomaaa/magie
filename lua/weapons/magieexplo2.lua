AddCSLuaFile()

SWEP.PrintName 		      = "Explosion 2" 
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
SWEP.HoldType             = "magic"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Explosion"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 0
config.dmg2 = 0
config.tmp = 2
config.dmgexplo1 = 85
config.dmgexplo2 = 90

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		config.switch = true

		local own = self:GetOwner()
		local pos = own:GetPos()

		local FireStorm = ents.Create("env_smokestack")
		FireStorm:SetKeyValue("smokematerial", "effects/fire_cloud2.vmt")
		FireStorm:SetKeyValue("rendercolor", "255 160 20" )
		FireStorm:SetKeyValue("targetname","FireStorm")
		FireStorm:SetKeyValue("basespread","100")
		FireStorm:SetKeyValue("spreadspeed","100")
		FireStorm:SetKeyValue("speed","500")
		FireStorm:SetKeyValue("startsize","50")
		FireStorm:SetKeyValue("endzide","100")
		FireStorm:SetKeyValue("rate","200")
		FireStorm:SetKeyValue("jetlength","600")
		FireStorm:SetKeyValue("twist","600")
		FireStorm:SetParent(own)
		FireStorm:SetPos(pos)
		FireStorm:Spawn()
		FireStorm:Fire("turnon","",0.3)
		FireStorm:Fire("Kill","",config.tmp)

		timer.Create("zone_dmg".. FireStorm:EntIndex(),0.1,config.tmp*10,function()
			if (IsValid(FireStorm) && IsValid(self) && own:Alive()) then
				for k,v in pairs(ents.FindInSphere(FireStorm:GetPos(),300)) do
					if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_BLAST  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( FireStorm:GetPos() )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
		end)

		timer.Create("explosions".. FireStorm:EntIndex(),0.5,config.tmp*2,function()
			if (IsValid(FireStorm) && IsValid(self) && own:Alive()) then
				local po = own:GetPos() + Vector(math.random(-120,120),math.random(-120,120),math.random(0,300))
				own:EmitSound( "ambient/explosions/exp1.wav" , 100, 100,1)
				for k,v in pairs(ents.FindInSphere(po,500)) do
					if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmg = DamageInfo()
						dmg:SetDamageType( DMG_BLAST  )
						dmg:SetDamage( math.random(config.dmgexplo1,config.dmgexplo2) )
						dmg:SetDamagePosition( po )
						dmg:SetAttacker( own )
						dmg:SetInflictor( own )
						v:TakeDamageInfo(dmg)
					end
				end
				local ex = EffectData()
				ex:SetOrigin(po)
				util.Effect("cinematic_explosion2",ex) 
			end
		end)

		timer.Simple(config.tmp, function()
			config.switch = true
		end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

function SWEP:PrimaryAttack()
	if CLIENT then return end
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay < CurTime() then if !SERVER then return end

	local shot = ents.Create("explosionstyle")
	shot:SetPos(self.Owner:GetPos() + Vector(0,0,10))
	shot:SetOwner(self.Owner)
	shot:SetAngles(self.Owner:GetAngles())
	shot:Spawn()
	shot:GetPhysicsObject():EnableMotion(true)

	local phys = shot:GetPhysicsObject()
	phys:EnableGravity(false)

	phys:SetVelocity( shot:GetForward() * 2000 )

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
	self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	if config.switch == false then
		return false
	else
		return true
	end
end
