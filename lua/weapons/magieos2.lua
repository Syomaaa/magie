AddCSLuaFile()

SWEP.PrintName 		      = "OS 2" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 54
SWEP.UseHands = true
SWEP.ViewModel = ""
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

SWEP.Category             = "OS"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 30
config.dmg2 = 30
config.zone = 500
config.nb = 20
config.tmpOut = 0.1
config.push = 1000

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then

		local startpos = self.Owner:EyePos()
		local startangle = self.Owner:EyeAngles():Forward()
		local Ang = self.Owner:GetAngles() + Angle(90,180,0)
		Ang.pitch = -30
		Ang.roll = Ang.roll
		Ang.yaw = Ang.yaw - 180
		local Ang2 = self.Owner:EyeAngles()
		Ang2.pitch = 0
		Ang2.roll = 0
		Ang2.yaw = Ang2.yaw
		local startang = self.Owner:EyeAngles()
		local pos_dist = 200
		local timx = "PicWave" .. self.Owner:EntIndex()
		local owner = self.Owner
		local wep = self
		local osHand = ents.Create("prop_physics")
		osHand:SetModel("models/mailer/wow_props/dragonskeleton_leftarm.mdl")
		osHand:SetModelScale(2,0.1)
		local osHand_num = 0
		timer.Create(timx,config.tmpOut,config.nb,function()
			if(IsValid(osHand) && IsValid(self) && self:GetOwner():Alive()) then
				osHand_num = osHand_num + 1
				local traceworld = {}
				traceworld.start = startpos + Vector(0,0,50) + Ang2:Forward()*pos_dist
				traceworld.endpos = traceworld.start - Vector(0,0,400)
				traceworld.fliter = function(ent) if !ent:IsWorld() then return false end end
				traceworld.mask = MASK_SOLID_BRUSHONLY
				local trw = util.TraceLine(traceworld)

				osHand:SetPos(trw.HitPos + Vector(0,0,-20))
				osHand:SetAngles(Ang)
				osHand:Spawn()
				osHand.IsEarthMagicProp = true
				osHand:EmitSound("Boulder.ImpactHard")
				undo.AddEntity( osHand )

				osHand:SetOwner(self.Owner)
				osHand.RockOwner = self.Owner
				osHand:GetPhysicsObject():EnableMotion(false)

				local plyang = owner:GetAngles()
				plyang.pitch = -90
				plyang.roll = plyang.roll
				plyang.yaw = plyang.yaw
				local DustAngle = plyang
				local BigDust = EffectData()
				BigDust:SetOrigin(trw.HitPos)
				BigDust:SetNormal(DustAngle:Forward())
				BigDust:SetScale(100)
				util.Effect("ThumperDust",BigDust)
				util.ScreenShake( self.Owner:GetPos(), 2, 7, 2, 400 )

				for k,v in pairs(ents.FindInSphere(trw.HitPos,config.zone)) do
					if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( trw.HitPos )
						dmginfo:SetAttacker( owner )
						dmginfo:SetInflictor( (IsValid(wep) and wep or owner) )
						v:TakeDamageInfo(dmginfo)
					end
				end

				timer.Create("pic_up" .. osHand:EntIndex(),0.01,13,function()
					if(IsValid(self) && IsValid(osHand) && self:GetOwner():Alive()) then
						osHand:SetPos(osHand:GetPos() + Vector(0,0,12) + Ang2:Forward()*5)
					end
				end)
				timer.Simple(0.05,function()
					if IsValid(osHand) then
						timer.Create("pic_down_finish" .. osHand:EntIndex(),0.2,1,function()
							if IsValid(osHand) then
								SafeRemoveEntity(osHand)
							end	
						end)
					end
				end)
				pos_dist = pos_dist + 85
				if osHand_num >= 20 then
					undo.SetPlayer( self.Owner )
					undo.SetCustomUndoText("Undone Thorns")
					undo.Finish()
				end
			end
		end)
		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:SecondaryAttack()
	return false
end

-------------------------------------------------------------------------------------------------------------


function SWEP:Holster()
	return true
end