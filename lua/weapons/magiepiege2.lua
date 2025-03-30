AddCSLuaFile()

SWEP.PrintName 		      = "Piège 2" 
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

SWEP.Category             = "Piège"

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
config.dmg1 = 200 
config.dmg2 = 200    -- degat en continue de zone
config.tmp = 15    -- temps du piege
config.stunt = 1.5  -- temps du stunt
config.zone = 200

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

			local own = self:GetOwner()
			local pos = own:GetEyeTrace().HitPos
			local ang = Angle(0,own:GetAngles().y,0)

			local piege_zone = ents.Create( "piege2" ) 
			piege_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			piege_zone:SetPos( pos + ang) 
			piege_zone.Owner = own
			piege_zone:Spawn() 
			piege_zone:Activate() 
			own:DeleteOnRemove( piege_zone )
			piege_zone:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )


		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,150,255,255 ) )
		self:SetModelScale( 0, 0 )
		self:SetModelScale( config.zone/83.3, 0.7 ) 
		local own = self.Owner
		config.alp = 255
		timer.Create("alpha"..self:EntIndex(),0.1,25.5,function()
			if IsValid(self) && config.alp > 10 then
				config.alp = config.alp - 10
				self:SetColor( Color( 255,150,255,config.alp ) )
			end
		end)
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_SHOCK  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( v:GetPos() )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
					SafeRemoveEntityDelayed( self,0.3)
					self:SetColor( Color( 255,150,255,255 ) )
				end
				if v:IsPlayer() and v != own then
					v:Freeze( true )
					timer.Simple(0.2,function()
						if IsValid(self) then
							local piege_zone = ents.Create( "piege_zone2" ) 
							piege_zone.Owner = own
							piege_zone:SetPos( v:GetPos()+ Vector(0,0,100))
							piege_zone:Spawn() 
							piege_zone:Activate() 
						end
					end)
					timer.Simple(config.stunt, function()
						if IsValid(v) then 
							v:Freeze( false )
						end
					end)			
				end
				
				if v:IsNPC() and v != own then	
					if SERVER then
						v:SetCondition( 67 )
						timer.Simple(0.2,function()
							if IsValid(self) then
								local piege_zone = ents.Create( "piege_zone2" ) 
								piege_zone.Owner = own
								piege_zone:SetPos( v:GetPos() + Vector(0,0,100))
								piege_zone:Spawn() 
								piege_zone:Activate() 
							end
						end)
						timer.Simple(config.stunt, function()
							if IsValid(v) then 
								v:SetCondition( 68 )
							end
						end)
					end
				end

			end
		end
		self:NextThink( CurTime() + 0.5 ) 
		return true
	end
	scripted_ents.Register( ENT, "piege2" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/jutsu/petitetornade.mdl" )
		self:SetMaterial( "models/shiny" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( false )
		self:SetAngles(Angle(0,0,180))
		self:SetModelScale(2,0.3)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 200,200,255,150 ) )
		local own = self.Owner
		SafeRemoveEntityDelayed( self, config.stunt )
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			self:SetAngles(self:GetAngles()+ Angle(0,5,0))
		end
		self:NextThink( CurTime() + 0.05 ) 
		return true
	end
	scripted_ents.Register( ENT, "piege_zone2" )
end