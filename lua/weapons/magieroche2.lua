AddCSLuaFile()

SWEP.PrintName 		      = "Roche 2" 
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

SWEP.Category             = "Roche"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 11.5
SWEP.ActionDelay = 1
SWEP.NextAction = 0
SWEP.CooldownDelay = 0
config.tmpfreeze = 1.5

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
   
	self:SetHoldType( "magic" )
end

function SWEP:CheckAttaque( attaque )
	if self.Owner:GetNWBool(tostring(attaque), false) == true then
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	self.Owner.HasShield = false
	self.ShieldIsValid = false
	self.NextUseShield = CurTime() + 1
	self.Owner.HasShield = true
	local pos_tab = {
	Vector(185,0,-140),
	Vector(160,70,-140),
	Vector(90,100,-140),
	Vector(19,75,-140),
	Vector(-20,10,-140),
	Vector(5,-70,-140),
	Vector(75,-100,-140),
	Vector(150,-75,-140)
	}
	local pos_ang = {
	Angle(40,0,0),
	Angle(40,40,0),
	Angle(40,90,0),
	Angle(40,130,0),
	Angle(40,170,0),
	Angle(40,230,0),
	Angle(40,270,0),
	Angle(40,310,0)
	}
	for i=1,8 do
	local spike = ents.Create("prop_dynamic")
	spike:SetModel("models/rock/cluster_05.mdl")
    spike:SetPos(self.Owner:GetPos() + pos_tab[i] - Vector(80,0,0))
	spike:SetAngles(pos_ang[i])
	spike:Spawn()
	spike.IsEarthMagicProp = true
	spike.IsShield = true
	spike.Owner = self.Owner
	spike:EmitSound("Boulder.ImpactHard")
	undo.AddEntity( spike )
	if !game.SinglePlayer() then
	sound.Play( "Boulder.ImpactHard" , spike:GetPos() + Vector(0,0,45), 100, 100, 1 )
	end
	spike.RockOwner = self.Owner
	spike:GetPhysicsObject():EnableMotion(false)
	local plyang = self.Owner:GetAngles()
	plyang.pitch = -90
	plyang.roll = plyang.roll
	plyang.yaw = plyang.yaw
	local DustAngle = plyang
	local BigDust = EffectData()
	BigDust:SetOrigin(spike:GetPos() + Vector(0,0,170))
	BigDust:SetNormal(DustAngle:Forward())
	BigDust:SetScale(100)
	util.Effect("ThumperDust",BigDust)
	util.ScreenShake( self.Owner:GetPos(), 2, 7, 1, 400 )
	timer.Create("spike_up_shield" .. spike:EntIndex(),0.01,8,function()
	if IsValid(spike) then
	spike:SetPos(spike:GetPos() + Vector(0,0,12))
    end	
	end)
	timer.Simple(1.2,function()
	timer.Create("spike_down" .. spike:EntIndex(),0.01,8,function()
	if IsValid(spike) then
	spike:SetPos(spike:GetPos() - Vector(0,0,12))
	end	
	end)
	timer.Create("spike_down_finish" .. spike:EntIndex(),0.5,1,function()
	if IsValid(spike) then
	spike:Remove()
	end	
	end)
	end)
	end
	for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(),300)) do
	if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
	local dmginfo = DamageInfo()
    dmginfo:SetDamageType( DMG_GENERIC  )
	dmginfo:SetDamage( math.random(200,200) )
	dmginfo:SetDamagePosition( self.Owner:GetPos() )
	dmginfo:SetDamageForce((self.Owner:GetPos() - v:GetPos())*-100 + Vector(0,0,20*1000))
	dmginfo:SetAttacker( self.Owner )
	dmginfo:SetInflictor( self )
	v:TakeDamageInfo(dmginfo)
	if IsValid(v) and v != self.Owner and (v:IsPlayer())  then
		v:SetMoveType(MOVETYPE_NONE)
		v:Freeze(true)
		timer.Simple(config.tmpfreeze,function()
			if IsValid(v) then
				v:SetMoveType(MOVETYPE_WALK)
				v:Freeze(false)
			end
		end)
	end
	if IsValid(v) and v:IsNPC() and v != self.Owner then
		v:SetCondition( 67 )
		timer.Simple(config.tmpfreeze,function()
			if IsValid(v) then
				v:SetCondition( 68 )
			end
		end)
	end
	end
	end
	self.ShieldIsValid = true
	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as 11.5s de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end