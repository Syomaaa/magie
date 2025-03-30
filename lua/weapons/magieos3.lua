AddCSLuaFile()

SWEP.PrintName 		      = "OS 3" 
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

config.dmg1 = 350 
config.dmg2 = 350    -- degat
config.zone = 300

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

    --if !self.Owner:IsOnGround() then return false end

		local pos = self.Owner:GetEyeTrace().HitPos

		timer.Simple(0.1,function()
			if IsValid(self) then
				local pos_tab = {
					Vector(185,0,-140),
					Vector(160,70,-140),
					Vector(90,100,-140),
					Vector(19,75,-140),
					Vector(-20,10,-140),
					Vector(5,-70,-140),
					Vector(75,-100,-140),
					Vector(150,-75,-140),
					
					Vector(185*2,0,-140),
					Vector(160*2,70*2,-140),
					Vector(90*2,100*2,-140),
					Vector(19*2,75*2,-140),
					Vector(-20*2,10*2,-140),
					Vector(5*2,-70*2,-140),
					Vector(75*2,-100*2,-140),
					Vector(150*2,-75*2,-140),

					Vector(185*4,0,-140),
					Vector(160*4,70*4,-140),
					Vector(90*4,100*4,-140),
					Vector(19*4,75*4,-140),
					Vector(-20*4,10*4,-140),
					Vector(5*4,-70*4,-140),
					Vector(75*4,-100*4,-140),
					Vector(150*4,-75*4,-140)
				}
				local pos_ang = {
					Angle(40,0,0),
					Angle(40,40,0),
					Angle(40,90,0),
					Angle(40,130,0),
					Angle(40,170,0),
					Angle(40,230,0),
					Angle(40,270,0),
					Angle(40,310,0),
					Angle(40,0,0),
					Angle(40,40,0),
					Angle(40,90,0),
					Angle(40,130,0),
					Angle(40,170,0),
					Angle(40,230,0),
					Angle(40,270,0),
					Angle(40,310,0),
					Angle(40,0,0),
					Angle(40,40,0),
					Angle(40,90,0),
					Angle(40,130,0),
					Angle(40,170,0),
					Angle(40,230,0),
					Angle(40,270,0),
					Angle(40,310,0)
				}

				for i=1,24 do
					if self.Owner:Alive() and IsValid(self) then
						local spike = ents.Create("bone3")

                        spike:EmitSound( "ambient/materials/rock5.wav" ,70,150,0.6) 

						if i <=8 then
							spike:SetPos( pos + pos_tab[i] - Vector(80,0,70))
						elseif i <=16 then
							spike:SetPos( pos + pos_tab[i] - Vector(160,0,70))
							spike:SetModelScale(1.5,0)
						else
							spike:SetPos( pos + pos_tab[i] - Vector(320,0,70))
							spike:SetModelScale(2,0)
						end
						spike:SetAngles(pos_ang[i])
						spike:Spawn()

						spike.IsEarthMagicProp = true
						spike.IsShield = true
						spike.Owner = self.Owner

						spike.RockOwner = self.Owner

						local plyang = self.Owner:GetAngles()
						plyang.pitch = -90
						plyang.roll = plyang.roll
						plyang.yaw = plyang.yaw

						local DustAngle = plyang
						local BigDust = EffectData()
						BigDust:SetOrigin(spike:GetPos() + Vector(0,0,250))
						BigDust:SetNormal(DustAngle:Forward())
						BigDust:SetScale(100)
						util.Effect("ThumperDust",BigDust)
						util.ScreenShake( pos, 2, 7, 1, 400 )

						timer.Create("spike_up_shield" .. spike:EntIndex(),0.01,15,function()
							if IsValid(spike) then
								spike:SetPos(spike:GetPos() + Vector(0,0,11))
							end	
						end)
						timer.Simple(1.5,function()
							timer.Create("spike_down" .. spike:EntIndex(),0.01,25,function()
								if IsValid(spike) then
									spike:SetPos(spike:GetPos() - Vector(0,0,10))
								end	
							end)
							timer.Create("spike_down_finish" .. spike:EntIndex(),1,1,function()
								if IsValid(spike) then
									SafeRemoveEntity(spike)
								end	
							end)
						end)
					end
				end
				for k,v in pairs(ents.FindInSphere(pos,config.zone)) do
					if IsValid(v) and v != self.Owner then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( pos )
						dmginfo:SetAttacker( self.Owner )
						dmginfo:SetInflictor( self )
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
		end)
		
		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as ".. self.Cooldown .." de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "bone2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  ENT.Tars = {}  ENT.NextAtk = 0 ENT.Nexttik = 0
	ENT.Effect = false  ENT.Gre = 1  ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/naruto modelpack/models/bones/bones.mdl" )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetPos( self:GetPos() ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR)
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "bone3" )
end