AddCSLuaFile()
include("weapons/ce_bcr_config.lua")

//----------------------------------
// SWEP Info
//----------------------------------
SWEP.Author                 =   "Temporary Solutions"
SWEP.PrintName              =   "Ombre 2"
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
SWEP.Cooldown = 2
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

SWEP.TravelDistance = 5000
--------------------------------------------------------

--[[
	Hey me, don't forget if you're going to copy paste this for the other 3 sweps you need to:
	Change cloakconfig.MaxCharge3
	Edit SWEP:Equip, The Timers, and HudDraw
	And change ce_bc2_3
]]--

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end


local function Cloak(ply)
	local plyVelocity = ply:GetVelocity()
    local plyWeapon = ply:GetActiveWeapon()
    local col = ply:GetColor()
    ply:SetNWBool("HideHUD", true)

    local untilVelAlpha = math.max(0, plyVelocity:Length() - cloakconfig.CloakUntilVel) 	-- Keeps player completly cloaked until they meet a set velocity.
    local approachAlpha = math.Approach(col.a, untilVelAlpha, 500 * FrameTime()) 	-- Gradually get to the alpha (Instead of snapping to it).
    approachAlpha = math.max(approachAlpha, cloakconfig.MinimumVisibility) 	-- If the alpha is being set below the set minimum, just use the minimum.

    --[[
    	This is a fix for most weapons not going invisible unless the
    	alpha is 0. I don't think I can fix this as
    	it probably has to do with the weapon's models or textures.
    --]]
    local wepAlpha = 0
    
    if untilVelAlpha >= 70 then
    	wepAlpha = untilVelAlpha
   	else
   		wepAlpha = 0
   	end

   	if cloakconfig.CloakEffectOn ~= "" then
   		local effectpos = ply:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin(effectpos)
		effectdata:SetNormal(Vector(0, 0, 0))
		util.Effect(cloakconfig.CloakEffectOn, effectdata)
	end


	ply:RemoveAllDecals()
	ply:DrawShadow(false)
	ply:SetDSP(cloakconfig.DistortSound)

	if cloakconfig.CloakType == "Transparent" then
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		ply:SetColor(Color(255, 255, 255, approachAlpha))
		plyWeapon:SetRenderMode(RENDERMODE_TRANSALPHA)
		plyWeapon:SetColor(Color(255, 255, 255, wepAlpha))
	elseif cloakconfig.CloakType == "Material" then
		ply:SetMaterial(cloakconfig.CloakMaterial, true)
		plyWeapon:SetMaterial(cloakconfig.CloakMaterial, true)
	end

	if SERVER then
		if approachAlpha < cloakconfig.MinimumNPCVisibility then
			ply:SetNoTarget(true)
		else
			ply:SetNoTarget(false)
		end
	end
end



local function Uncloak(ply, forced, debug, holdcharge)
	if forced and cloakconfig.ForceDisableSound ~= "" and ply.CloakActive then
	elseif cloakconfig.DisableSound ~= ""  and debug ~= "Equip" and ply.CloakActive then
	end
	ply:SetNWBool("HideHUD", false)
	ply.CloakActive = false
	ply:SetDSP(0)
    ply:DrawShadow(true)
    ply:SetRenderMode(RENDERMODE_NORMAL)
    ply:SetColor(Color(255, 255, 255, 255))
    ply:SetMaterial("")

    if SERVER then
    	ply:SetNoTarget(false)
    end

    if not holdcharge then
   		ply:SetNWFloat("CloakCharge", cloakconfig.MaxCharge3)
   	end

    timer.Simple(cloakconfig.ToggleTime, function()
		ply.AllowedToggle = true
	end)

    if cloakconfig.CloakEffectOff != "" then
   		local effectpos = ply:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin(effectpos)
		effectdata:SetNormal(Vector(0, 0, 0))
		util.Effect(cloakconfig.CloakEffectOff, effectdata)
	end

    for k, v in pairs(ply:GetWeapons()) do 	-- Uncloaks previously cloaked weapons
    	if IsValid(v) then
    		v:SetRenderMode(RENDERMODE_NORMAL)
   	 		v:SetColor(Color(255, 255, 255, 255))
   	 	end
   	end
end



local DontSpam = 0
function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if ply.CloakActive == nil then
		ply.CloakActive = false
	elseif ply.AllowedToggle == nil then
		ply.AllowedToggle = true
	end

	if DontSpam < CurTime() then
		if SERVER then
			if not ply.CloakActive and ply.AllowedToggle then
				ply.CloakActive = true
				ply.AllowedToggle = false
				if cloakconfig.EnableSound != "" then
   				end
			elseif ply.CloakActive then
				if cloakconfig.CloakMode == "Charge" then
					Uncloak(ply, false, "Primary", true)
				else
					Uncloak(ply, false, "Primary")
				end
			else
				if cloakconfig.ToggleFailureSound != "" then
				end
			end
		end
		DontSpam = CurTime() + 0.5
	end
end



function SWEP:CanSecondaryAttack()	
	return false
end



function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
end



function SWEP:Equip()
	local ply = self.Owner

	--(Removes Other Cloaks)--
	if ply:HasWeapon("cloaking-1") then
		ply:StripWeapon("cloaking-1")
	elseif ply:HasWeapon("cloaking-2") then
		ply:StripWeapon("cloaking-2")
	elseif ply:HasWeapon("cloaking-infinite") then
		ply:StripWeapon("cloaking-infinite")
	end

	Uncloak(ply, false, "Equip")

	if cloakconfig.CloakMode == "Rechage" then
		self.Owner.CloakCharge = cloakconfig.MaxCharge3
	end
end


---------------------------------------------------------------------------------------------------


function SWEP:Reload()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	local own = self.Owner

	own:SetRenderMode( RENDERMODE_TRANSCOLOR )
	own:SetColor(Color(255,255,255,0))

	own:Freeze( true )

	local tp = ents.Create( "ombre_tp" )
	tp:SetPos( own:GetPos() )
	tp:SetOwner( own )
	tp:Spawn() 
	tp:Activate()

	local par = ents.Create( "info_particle_system" ) 
	par:SetKeyValue( "effect_name", "[3]_dark_tornado_ground_add" )
	par:SetKeyValue( "start_active", "1" )
	par:SetPos( own:GetPos() ) 
	par:Spawn() 
	par:Activate() 
	SafeRemoveEntityDelayed(par,1)

	timer.Create("shadow"..tp:EntIndex(),0.03,30,function()
		if self:IsValid() and tp:IsValid() then
			tp:SetPos(tp:GetPos()-Vector(0,0,5))
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
			par2:SetKeyValue( "effect_name", "[3]_dark_tornado_ground_add" )
			par2:SetKeyValue( "start_active", "1" )
			par2:SetPos( own:GetPos() ) 
			par2:Spawn() 
			par2:Activate() 
			SafeRemoveEntityDelayed(par2,1)

			local tp2 = ents.Create( "ombre_tp" )
			tp2:SetPos( own:GetPos()-Vector(0,0,80))
			tp2:SetOwner( own )
			tp2:Spawn() 
			tp2:Activate()
			timer.Create("shadow2"..tp2:EntIndex(),0.03,15,function()
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
	ENT.PrintName = "ombretp"
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
	scripted_ents.Register( ENT, "ombre_tp" )
end


---------------------------------------------------------------------------------------------------



hook.Add("PlayerPostThink", "ce_bc2_3_ThinkHook", function(ply)
	if ply.CloakActive then
		Cloak(ply)
	end

	if not ply.LastCharge then
		ply.LastCharge = CurTime()
	end

	if SERVER and ply:HasWeapon("cloaking-3") then
		if cloakconfig.CloakMode == "Charge" and cloakconfig.MaxCharge3 != 0 then
			if ply.LastCharge + (1 * cloakconfig.ChargeLossMultiplier) <= CurTime() and ply:GetNWFloat("CloakCharge") > 0 and ply.CloakActive then 	-- Depletes Charge
				ply:SetNWFloat("CloakCharge", ply:GetNWFloat("CloakCharge") - 1)
				ply.LastCharge = CurTime()
			elseif ply.LastCharge + (1 * cloakconfig.ChargeGainMultiplier) <= CurTime() and ply:GetNWFloat("CloakCharge") < cloakconfig.MaxCharge3 and !ply.CloakActive and !ply.CloakPause then 	-- Adds Charge
				ply:SetNWFloat("CloakCharge", ply:GetNWFloat("CloakCharge") + 1)
				ply.LastCharge = CurTime()
			elseif ply.CloakActive and ply:GetNWFloat("CloakCharge") == 0 then	-- Uncloaks when out of charge
				Uncloak(ply, true, "Charge", true)
			end
		end
	end

	-- Its like charge, without the recharge
	if ply:HasWeapon("cloaking-3") then
		if cloakconfig.CloakMode == "Timer" and cloakconfig.MaxCharge3 != 0 then
			if ply.LastCharge + 1 <= CurTime() and ply:GetNWFloat("CloakCharge") > 0 and ply.CloakActive then
				ply:SetNWFloat("CloakCharge", ply:GetNWFloat("CloakCharge") - 1)
				ply.LastCharge = CurTime()
			elseif ply.CloakActive and ply:GetNWFloat("CloakCharge") == 0 then
				Uncloak(ply, true, "Timer")
				ply:SetNWFloat("CloakCharge", cloakconfig.MaxCharge3)
			end
		end
	end
		-- Copy pasted as an attempted bugfix for some weapons being a pain in the ass
	local plyVelocity = ply:GetVelocity()
    local plyWeapon = ply:GetActiveWeapon()
    local col = ply:GetColor()

    local untilVelAlpha = math.max(0, plyVelocity:Length() - cloakconfig.CloakUntilVel) 	-- Keeps player completly cloaked until they meet a set velocity.
    local approachAlpha = math.Approach(col.a, untilVelAlpha, 500 * FrameTime()) 	-- Gradually get to the alpha (Instead of snapping to it).
    approachAlpha = math.max(approachAlpha, cloakconfig.MinimumVisibility) 	-- If the alpha is being set below the set minimum, just use the minimum.

    --[[
    	This is a fix for most weapons not going invisible unless the
    	alpha is 0. I don't think I can fix this as
    	it probably has to do with the weapon's models or textures.
    --]]
    local wepAlpha = 0
    
    if untilVelAlpha >= 70 then
    	wepAlpha = untilVelAlpha
   	else
   		wepAlpha = 0
   	end

   	if cloakconfig.CloakType == "Transparent" and ply.CloakActive then
		plyWeapon:SetRenderMode(RENDERMODE_TRANSALPHA)
		plyWeapon:SetColor(Color(255, 255, 255, wepAlpha))
	elseif cloakconfig.CloakType == "Material" and ply.CloakActive then
		plyWeapon:SetMaterial(cloakconfig.CloakMaterial, true)
	end
end)



hook.Add("EntityFireBullets", "ce_bc2_3_UncloakOnFire", function(ent, bullet)
	if IsValid(ent) and ent:IsPlayer() and ent.CloakActive then
		if cloakconfig.CloakFireMode == 1 then
			Uncloak(ent, true, "Fired")
		elseif cloakconfig.CloakFireMode == 2 then
			if cloakconfig.CloakMode == "Charge" then
				ent:SetNWFloat("CloakCharge", ent:GetNWFloat("CloakCharge") - cloakconfig.LoseChargeAmountFire)
			elseif cloakconfig.CloakMode == "Timer" then
				print("Yeah you probably shouldn't set a charge option if you're using the timer mode.\nDefaulting to Option 1")
				GetConVar("bc2_CloakFireMode"):SetInt(1)
				Uncloak(ent, true, "Fired2")
			end
		elseif cloakconfig.CloakFireMode == 3 and ent:Alive() then
			Uncloak(ent, true, "Fired3", true)
			ent.AllowedToggle = false
			ent.CloakPause = true
			timer.Simple(cloakconfig.TempDisableTimeFire, function()
				if IsValid(ent) and not ent.DidSomethingStupid then
					ent.CloakActive = true
				end
			ent.AllowedToggle = true
			ent.DidSomethingStupid = false
			ent.CloakPause = false
			end)
		end
	end
end)



hook.Add("EntityTakeDamage", "ce_bc2_3_UncloakOnDamage", function(ent, dmginfo)
	if IsValid(ent) and ent:IsPlayer() and ent.CloakActive then
		if cloakconfig.CloakDamageMode == 1 then
			Uncloak(ent, true, "Damage")
		elseif cloakconfig.CloakDamageMode == 2 then
			if cloakconfig.CloakMode == "Charge" then
				ent:SetNWFloat("CloakCharge", ent:GetNWFloat("CloakCharge") - cloakconfig.LoseChargeAmountHurt)
			elseif cloakconfig.CloakMode == "Timer" then
				print("Yeah you probably shouldn't set a charge option if you're using the timer mode.\nDefaulting to Option 1")
				GetConVar("bc2_CloakDamageMode"):SetInt(1)
				Uncloak(ent, true, "Damage2")
			end
		elseif cloakconfig.CloakDamageMode == 3 and ent:Alive() then
			Uncloak(ent, true, "Damage3", true)
			ent.AllowedToggle = false
			ent.CloakPause = true
			timer.Simple(cloakconfig.TempDisableTimeHurt, function()
				if IsValid(ent) and not ent.DidSomethingStupid then
					ent.CloakActive = true
				end
			ent.AllowedToggle = true
			ent.DidSomethingStupid = false
			ent.CloakPause = false
			end)
		end
	end
end)

hook.Add("PlayerFootstep", "ce_bc2_3_SilentSteps", function(ply, pos, foot, sound, volume, rf)
    if ply.CloakActive then
    	ply:EmitSound(sound, 20, nil, cloakconfig.FootstepVolume, 4)
   		return true
	else
    	return false
 	end
end)

hook.Add("HUDDrawTargetID", "ce_bc2_3_HidePlayerID", function()
	if CLIENT then
    	local gplytr = util.GetPlayerTrace(LocalPlayer())
    	local ent = util.TraceLine(gplytr).Entity
    	local col = 255
    	if IsValid(ent) then
    		col = ent:GetColor()
    	end

    	if ent:IsPlayer() and IsValid(ent) then
    		if cloakconfig.CloakType == "Transparent" and ent.CloakActive and col.a < cloakconfig.MinimumIDVisibility then
        		return false
        	elseif cloakconfig.CloakType == "Material" and ent.CloakActive then
           		return false
           	else
           		return
        	end
        end
	end
end)



hook.Add("HUDPaint", "ce_bc2_1_DrawThings", function()
	local ply = LocalPlayer()
	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) then

		local activeweapon = ply:GetActiveWeapon():GetClass()

		if ply.CloakActive and cloakconfig.CloakOverlay ~= "" then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(Material(cloakconfig.CloakOverlay))
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH())
		end

		if ply:HasWeapon("cloaking-3") and GetConVar("bc2_ShowCloakCharge"):GetBool() and (activeweapon == "cloaking-3" or ply:GetNWFloat("CloakCharge") != cloakconfig.MaxCharge3) and cloakconfig.MaxCharge3 != 0 then
			draw.SimpleText(ply:GetNWFloat("CloakCharge"), "DermaLarge", ScrW()/2 - 25, 900, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
end)



hook.Add("HUDShouldDraw", "DarkRP_HideDarkPlayerID", function(hudName)
    if hudName ~= "DarkRP_EntityDisplay" then return end

    local playersToDraw = {}
    for _,ply in pairs(player.GetAll()) do
        if IsValid(ply) and not ply:GetNWBool("HideHUD") then
            table.insert(playersToDraw, ply)
        end
    end
    return true, playersToDraw
end)



hook.Add("PlayerEnteredVehicle", "ce_bc2_3_UncloakEnteringVehicle", function(ply, veh, seat)
	if ply.CloakActive and cloakconfig.UncloakInVehicle then
		Uncloak(ply, false, "Vehicle")
	end
end)


-- Accidents
local function onDemote(source, demoted, reason)
	if demoted.CloakActive then
	Uncloak(demoted, false, "Demoted")
	demoted.DidSomethingStupid = true
	end
end

local function UncloakOnAccident(ply)
	Uncloak(ply, false, "Accident")
	ply.DidSomethingStupid = true
end

hook.Add("PlayerDeath", "ce_bc2_3_Death" , UncloakOnAccident)
hook.Add("playerAFKDemoted", "ce_bc2_3_AFK" , UncloakOnAccident)
hook.Add("onPlayerDemoted", "ce_bc2_3_Demoted" , onDemote)
hook.Add("playerArrested", "ce_bc2_3_Arrested" , UncloakOnAccident)
hook.Add("playerStarved", "ce_bc2_3_Starved" , UncloakOnAccident)
hook.Add("OnPlayerChangedTeam", "ce_bc2_3_ChangedTeam" , UncloakOnAccident)