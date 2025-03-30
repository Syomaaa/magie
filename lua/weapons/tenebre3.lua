AddCSLuaFile()

SWEP.PrintName 		      = "Ténèbres 3" 
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

SWEP.Category             = "Ténèbres"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.XDEBZ_KeepFire = 0  SWEP.XDEBZ_Gre = 1
SWEP.XDEBZ_BridNum = 0  SWEP.XDEBZ_BridPos = Vector( 0, 0, 0 )  SWEP.XDEBZ_BridTab = {}
SWEP.XDEBZ_BridAng = Angle( 0, 0, 0 )  SWEP.XDEBZ_BridNext = 0  SWEP.XDEBZ_BridLas = nil

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 350
config.dmg2 = 350
config.hp = 1000     -- plus il en a plus il dur longtemps et a de vie

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then

		local own = self:GetOwner()
		local pos = own:GetEyeTrace().HitPos
		local ang = Angle(0,own:GetAngles().y,0)
		local trace = self:GetOwner():GetEyeTrace()

		pos = pos + (ang*300)

		local iceten = ents.Create( "bridgten" ) self.XDEBZ_BridAng = Angle( ang.pitch, ang.yaw, 0 )
		iceten:SetAngles( self.XDEBZ_BridAng ) iceten:SetPos( pos + ang) iceten.Owner = own
		iceten:Spawn() iceten:Activate() own:DeleteOnRemove( iceten )
		self.XDEBZ_BridNum = self.XDEBZ_BridNum - 1  self.XDEBZ_BridNext = CurTime() + 0.1
		table.insert( self.XDEBZ_BridTab, iceten )
		for k,v in pairs(ents.FindInSphere(pos + ang,300)) do
			if IsValid(v) and v != own then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_GENERIC  )
			dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
			dmginfo:SetDamagePosition( pos )
			dmginfo:SetAttacker( own )
			dmginfo:SetInflictor( own )
			v:TakeDamageInfo(dmginfo)
			end
			end
		if IsValid( self.XDEBZ_BridLas ) then iceten:DeleteOnRemove( self.XDEBZ_BridLas ) iceten.XDEBZ_Connect = self.XDEBZ_BridLas end self.XDEBZ_BridLas = iceten

		

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "bridgten"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/kevin the cube/kevin the cube.mdl" )
		self:SetSolid( SOLID_VPHYSICS ) self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( true )
		self:SetModelScale(2)
		self:UseTriggerBounds( true, 0 )
		local own = self.Owner
		self:SetAngles(Angle(0,own:EyeAngles().Yaw + 90,0))
		self:SetMaxHealth( config.hp ) self:SetHealth( self:GetMaxHealth() )
	end
	function ENT:StartTouch( ent )
		if ent:GetClass() == self:GetClass() or ent:GetNWBool( "XDEBZ_Iced" ) or ent.XDEBZ_Gre or self.XDEBZ_Broken then return end  local own = self.Owner
		self.XDEBZ_FreezeTab[ ent:EntIndex() ] = ent
	end
	function ENT:EndTouch( ent )
		if !IsValid( ent ) or ent:GetClass() == self:GetClass() or self.XDEBZ_Broken then return end  local own = self.Owner
		self.XDEBZ_FreezeTab[ ent:EntIndex() ] = nil
	end
	function ENT:OnRemove() if !SERVER or self.XDEBZ_Broken then return end self.XDEBZ_Broken = true
		local own = self.Owner
		self:StopSound( "" ) self:EmitSound( "" ) self:SetHealth( 0 )
	end
	function ENT:Think() if !SERVER or self.XDEBZ_Broken then return end local hp = self:Health()/self:GetMaxHealth()
		self.XDEBZ_Lap = Lerp( 0.2, self.XDEBZ_Lap, hp )
		local cc = self:GetColor()  self:SetColor( Color( cc.r, cc.g, cc.b, 55 +self.XDEBZ_Lap*200 ) )  local own = self.Owner
		if self:IsOnFire() then self:Extinguish() end if self.XDEBZ_FreezeTic < CurTime() then self.XDEBZ_FreezeTic = CurTime() + 1
			for k, v in pairs( self.XDEBZ_FreezeTab ) do
				if !IsValid( v ) or v.XDEBZ_Broken or v:GetNWBool( "XDEBZ_Iced" ) or v.XDEBZ_Gre then table.remove( self.XDEBZ_FreezeTab, k ) continue end
			end
			self:SetHealth( math.max( 1, self:Health() - 250 ) ) if self:Health() <= 1 then self:TakeDamage( 1000 ) end
		end
		self:NextThink( CurTime() + 0.1 ) return true
	end
	function ENT:OnTakeDamage( dmg ) if self.XDEBZ_Broken then return end
		if IsValid( dmg:GetInflictor() ) and dmg:GetInflictor():GetClass() == self:GetClass() then return end
		if self:Health() <= dmg:GetDamage() then self:Remove() if IsValid( self.XDEBZ_Connect ) then self:DontDeleteOnRemove( self.XDEBZ_Connect ) end
		else self:SetHealth( math.max( 1, self:Health() - dmg:GetDamage() ) )
		self:StopSound( "" ) self:EmitSound( "" ) end
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "bridgten" )
end