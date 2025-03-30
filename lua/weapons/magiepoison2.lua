AddCSLuaFile()
include("weapons/ce_bcr_config.lua")

//----------------------------------
// SWEP Info
//----------------------------------
SWEP.Author                 =   "Temporary Solutions"
SWEP.PrintName              =   "Poison 2"
SWEP.Base                   =   "weapon_base"
SWEP.Instructions           =   [[Left-Click: Toggle Cloak
Right-Click: N/A]]
SWEP.Spawnable              =   true
SWEP.AdminSpawnable         =   true
SWEP.AdminOnly 				= 	false
//----------------------------------
// SWEP Models
//----------------------------------
SWEP.ViewModelFlip          =   false
SWEP.UseHands               =   false
SWEP.ViewModel              =   "models/weapons/v_hands.mdl"
SWEP.WorldModel             =   ""
SWEP.HoldType               =   "normal"
//----------------------------------
// SWEP Slot Properties
//----------------------------------
SWEP.AutoSwitchTo           =   true
SWEP.AutoSwithFrom          =   true
SWEP.Slot                   =   5
SWEP.SlotPos                =   123
//----------------------------------
// SWEP Weapon Properties
//----------------------------------
SWEP.DrawAmmo               =   false
SWEP.DrawCrosshair          =   false
SWEP.m_WeaponDeploySpeed 	= 	100
SWEP.OnRemove = onDeathDropRemove
SWEP.OnDrop = onDeathDropRemove

SWEP.Primary.ClipSize       =   0
SWEP.Primary.DefaultClip    =   0
SWEP.Primary.Ammo           =   "none"
SWEP.Primary.Automatic      =   false
 
SWEP.Secondary.ClipSize     =   -1
SWEP.Secondary.DefaultClip  =   -1
SWEP.Secondary.Ammo         =   "none"
SWEP.Secondary.Automatic    =   false


------------------ [ tp reload ] -----------------------
SWEP.Cooldown = 5
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

SWEP.TravelDistance = 5000
--------------------------------------------------------

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	local own = self.Owner

	own:SetRenderMode( RENDERMODE_TRANSCOLOR )
	own:SetColor(Color(255,255,255,0))

	own:Freeze( true )

	local tppoi = ents.Create( "poison_tp" )
	tppoi:SetPos( own:GetPos() )
	tppoi:SetOwner( own )
	tppoi:Spawn() 
	tppoi:Activate()

	local par = ents.Create( "info_particle_system" ) 
	par:SetKeyValue( "effect_name", "[25]_swamp_ground" )
	par:SetKeyValue( "start_active", "1" )
	par:SetPos( own:GetPos() ) 
	par:Spawn() 
	par:Activate() 
	SafeRemoveEntityDelayed(par,1)

	timer.Create("swamp"..tppoi:EntIndex(),0.03,30,function()
		if self:IsValid() and tppoi:IsValid() then
			tppoi:SetPos(tppoi:GetPos()-Vector(0,0,5))
		end
	end)

	timer.Simple(0.1,function()
		local tra = util.TraceLine({
			start = own:EyePos(),
			endpos = own:EyePos() + own:EyeAngles():Forward() * self.TravelDistance,
			mask = MASK_NPCWORLDSTATIC,
			filter = {self, own}
		})

		if tra.Hit then
			if tra.HitNormal.z > 0.7 then
				own:SetPos(tra.HitPos)
			else
				self.Owner:PrintMessage( HUD_PRINTCENTER, "Visez le Sol !" )
			end
		else 
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Visez le Sol !" )
		end

	end)

	timer.Simple(0.3,function()
		if self:IsValid() then

			local par2 = ents.Create( "info_particle_system" ) 
			par2:SetKeyValue( "effect_name", "[25]_swamp_ground" )
			par2:SetKeyValue( "start_active", "1" )
			par2:SetPos( own:GetPos() ) 
			par2:Spawn() 
			par2:Activate() 
			SafeRemoveEntityDelayed(par2,1)

			local tp2 = ents.Create( "poison_tp" )
			tp2:SetPos( own:GetPos()-Vector(0,0,80))
			tp2:SetOwner( own )
			tp2:Spawn() 
			tp2:Activate()
			timer.Create("swamp2"..tp2:EntIndex(),0.03,15,function()
				if self:IsValid() and tp:IsValid() then
					tp2:SetPos(tp2:GetPos()+Vector(0,0,5))
				end
			end)
		end
		timer.Simple(0.5,function()
			if self:IsValid() then
				own:Freeze( false )
				own:SetColor(Color(255,255,255,255))
				own:SetRenderMode( RENDERMODE_NORMAL )
			end
		end)
	end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true
end


if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "poisontp"
	ENT.Spawnable = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( self.Owner:GetModel() )	
		self:SetAngles(self.Owner:GetAngles())	
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetSequence( self.Owner:GetSequence() )
		SafeRemoveEntityDelayed( self,1 )
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
		end
	end
	scripted_ents.Register( ENT, "poison_tp" )
end