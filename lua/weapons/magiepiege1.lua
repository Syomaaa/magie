AddCSLuaFile()

SWEP.PrintName 		      = "Piège 1" 
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

SWEP.Cooldown = 1.5
SWEP.Cooldown2 = 1.5

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0

SWEP.CooldownDelay = 0
SWEP.CooldownDelay2 = 0

local config = {}
config.dmg1 = 10 
config.dmg2 = 20    -- degat en continue de piege eau
config.tmp = 15     -- temps du piege
config.zone = 150
config.explo = 120   -- magnitude de la zone de explo plus elever = plus puissant

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

			local piege_zone = ents.Create( "piege1" ) 
			piege_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			piege_zone:SetPos(pos + ang) 
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

function SWEP:SecondaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay2 < CurTime() then if !SERVER then return end

			local own = self:GetOwner()
			local pos = own:GetEyeTrace().HitPos
			local ang = Angle(0,own:GetAngles().y,0)

			local piege_zone = ents.Create( "piege1.2" ) 
			piege_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			piege_zone:SetPos( pos + ang) 
			piege_zone.Owner = own
			piege_zone:Spawn() 
			piege_zone:Activate() 
			own:DeleteOnRemove( piege_zone )
			piege_zone:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )


		self.CooldownDelay2 = CurTime() + self.Cooldown2
		self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .."s de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 200,220,250,255 ) )
		self:SetModelScale( 0, 0 )
		self:SetModelScale( config.zone/83.3, 0.7 ) 
		local own = self.Owner
		config.alp = 255
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					explo = ents.Create("env_explosion")
					explo:SetKeyValue("iMagnitude",config.explo)
					explo:SetPos(self:GetPos())
					explo:Spawn()
					explo:Fire("Explode",0,0)
					config.alp = 255
					SafeRemoveEntity(self)
				end
			end
			if IsValid(self) && config.alp > 10 then
				config.alp = config.alp - 10
				self:SetColor( Color( 200,220,250,config.alp ) )
			end
		end
		self:NextThink( CurTime() + 0.1 ) 
		return true
	end
	scripted_ents.Register( ENT, "piege1" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "piege1.2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 10,220,220,255 ) )
		self:SetModelScale( 0, 0 )
		self:SetModelScale( config.zone/83.3, 0.7 ) 
		local own = self.Owner
		config.alp2 = 255
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:AddEFlags("-2147483648" )
					v:TakeDamageInfo(dmginfo)
					v:RemoveEFlags("-2147483648" )
					config.alp2 = 255
					local watterEff = EffectData()
					watterEff:SetOrigin(self:GetPos())
					watterEff:SetScale(1000)
					util.Effect("watersplash",watterEff) 
				end
			end
			if IsValid(self) && config.alp2 > 10 then
				config.alp2 = config.alp2 - 10
				self:SetColor( Color( 10,220,220,config.alp2 ) )
			end
		end
		self:NextThink( CurTime() + 0.1 ) 
		return true
	end
	scripted_ents.Register( ENT, "piege1.2" )
end