AddCSLuaFile()


-- Per Person Setting

CreateClientConVar("bc2_ShowCloakCharge", 1, false, false, "")

-- Visual

CreateConVar("bc2_CloakType", "Transparent", FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakMode", "Timer", FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakUntilVel", 75, FCVAR_ARCHIVE, "")
CreateConVar("bc2_MinimumVisibility", 0, FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakMaterial", "", FCVAR_ARCHIVE, "")
CreateConVar("bc2_ChargeGainMultiplier", 1, FCVAR_ARCHIVE, "")
CreateConVar("bc2_ChargeLossMultiplier", 1, FCVAR_ARCHIVE, "")
CreateConVar("bc2_MaxCharge1", 10, FCVAR_ARCHIVE, "")
CreateConVar("bc2_MaxCharge2", 20, FCVAR_ARCHIVE, "")
CreateConVar("bc2_MaxCharge3", 30, FCVAR_ARCHIVE, "")
CreateConVar("bc2_MinimumNPCVisibility", 70, FCVAR_ARCHIVE, "")
CreateConVar("bc2_UncloakInVehicle", 1, FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakOverlay", "", FCVAR_ARCHIVE, "")
CreateConVar("bc2_MinimumIDVisibility", 70, FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakFireMode", 3, FCVAR_ARCHIVE, "")
CreateConVar("bc2_LoseChargeAmountFire", 5, FCVAR_ARCHIVE, "")
CreateConVar("bc2_TempDisableTimeFire", 2, FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakDamageMode", 3, FCVAR_ARCHIVE, "")
CreateConVar("bc2_LoseChargeAmountHurt", 5, FCVAR_ARCHIVE, "")
CreateConVar("bc2_TempDisableTimeHurt", 2, FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakEffectOn", "", FCVAR_ARCHIVE, "")
CreateConVar("bc2_CloakEffectOff", "", FCVAR_ARCHIVE, "")
CreateConVar("bc2_ToggleTime", 3, FCVAR_ARCHIVE, "")

-- Audio

CreateConVar("bc2_DistortSound", 14, FCVAR_ARCHIVE, "")
CreateConVar("bc2_EnableSound", "npc/sniper/reload1.wav", FCVAR_ARCHIVE, "")
CreateConVar("bc2_DisableSound", "AlyxEMP.Discharge", FCVAR_ARCHIVE, "")
CreateConVar("bc2_ForceDisableSound", "npc/roller/mine/combine_mine_deactivate1.wav", FCVAR_ARCHIVE, "")
CreateConVar("bc2_ToggleFailureSound", "npc/roller/mine/combine_mine_deploy1.wav", FCVAR_ARCHIVE, "")
CreateConVar("bc2_FootstepVolume", 0, FCVAR_ARCHIVE, "")
CreateConVar("bc2_TauntSound", "", FCVAR_ARCHIVE, "")
CreateConVar("bc2_TauntVolume", 1, FCVAR_ARCHIVE, "")
CreateConVar("bc2_TauntDelay", 4, FCVAR_ARCHIVE, "")

hook.Add( "PopulateToolMenu", "ce_bc2_configmenu", function()
	spawnmenu.AddToolMenuOption( "Utilities", "JustCrimson", "ce_bc2_config", "Better Cloaking Config", "", "", function( panel )
		panel:ClearControls()
		local CloakTypeBox = panel:ComboBox("Cloak Type", "bc2_CloakType")
		
		CloakTypeBox:AddChoice("Transparent")
		CloakTypeBox:AddChoice("Material")
		
		local CloakModeBox = panel:ComboBox("Cloak Mode", "bc2_CloakMode")
		CloakModeBox:AddChoice("Timer")
		CloakModeBox:AddChoice("Charge")

		panel:TextEntry("Movement Sensitivity", "bc2_CloakUntilVel"):SetNumeric(true)

		panel:TextEntry("Toggle Time", "bc2_ToggleTime"):SetNumeric(true)

		panel:NumSlider("Minimum Visibility", "bc2_MinimumVisibility", 0, 255, 0)

		panel:TextEntry("Cloak Material", "bc2_CloakMaterial")

		local SoundDistortBox = panel:ComboBox("Sound Distortion", "bc2_DistortSound")
		SoundDistortBox:AddChoice("None", 0)
		SoundDistortBox:AddChoice("Light", 14)
		SoundDistortBox:AddChoice("Medium", 15)
		SoundDistortBox:AddChoice("Heavy", 16)

		panel:TextEntry("Enable Sound", "bc2_EnableSound")
		panel:TextEntry("Disable Sound", "bc2_DisableSound")
		panel:TextEntry("Toggle Fail Sound", "bc2_ToggleFailureSound")
		panel:TextEntry("Force Disable Sound", "bc2_ForceDisableSound")


		panel:NumSlider("Visibility For NPC Target", "bc2_MinimumNPCVisibility", 0, 255, 0)
		panel:NumSlider("Visibility To Show ID", "bc2_MinimumIDVisibility", 0, 255, 0)

		panel:NumSlider("Footstep Volume", "bc2_FootstepVolume", 0, 1, 2)

		panel:CheckBox("Uncloak In Vehicle", "bc2_UncloakInVehicle")

		panel:TextEntry("Cloak Overlay", "bc2_CloakOverlay")

		local CloakShootMode = panel:ComboBox("Shooting While Cloaked Mode", "bc2_CloakFireMode")
		CloakShootMode:AddChoice("Disable Cloak", 1)
		CloakShootMode:AddChoice("Lose Charge", 2)
		CloakShootMode:AddChoice("Temp Disable", 3)
		CloakShootMode:AddChoice("Nothing", 4)

		panel:TextEntry("Shooting Lose Charge Amount", "bc2_LoseChargeAmountFire"):SetNumeric(true)
		panel:TextEntry("Shooting Temp Disable Time", "bc2_TempDisableTimeFire"):SetNumeric(true)

		panel:TextEntry("Cloak 1 Max Charge", "bc2_MaxCharge1"):SetNumeric(true)
		panel:TextEntry("Cloak 2 Max Charge", "bc2_MaxCharge2"):SetNumeric(true)
		panel:TextEntry("Cloak 3 Max Charge", "bc2_MaxCharge3"):SetNumeric(true)

		panel:TextEntry("Charge Gain Multiplier", "bc2_ChargeGainMultiplier"):SetNumeric(true)
		panel:TextEntry("Charge Loss Multiplier", "bc2_ChargeLossMultiplier"):SetNumeric(true)

		local CloakDamageMode = panel:ComboBox("Damaged While Cloaked Mode", "bc2_CloakDamageMode")
		CloakDamageMode:AddChoice("Disable Cloak", 1)
		CloakDamageMode:AddChoice("Lose Charge", 2)
		CloakDamageMode:AddChoice("Temp Disable", 3)
		CloakDamageMode:AddChoice("Nothing", 4)
		
		panel:TextEntry("Damaged Lose Charge Amount", "bc2_LoseChargeAmountHurt"):SetNumeric(true)
		panel:TextEntry("Damaged Temp Disable Time", "bc2_TempDisableTimeHurt"):SetNumeric(true)

		panel:TextEntry("Cloak Enable Effect", "bc2_CloakEffectOn")
		panel:TextEntry("Cloak Disable Effect", "bc2_CloakEffectOff")

		panel:TextEntry("Taunt Sound", "bc2_TauntSound")
		panel:NumSlider("Taunt Volume", "bc2_TauntVolume", 0, 1, 2)
		panel:TextEntry("Taunt Delay", "bc2_TauntDelay"):SetNumeric(true)

	end )
end )

cloakconfig = {}

-- Visual
cloakconfig["CloakType"] = GetConVar("bc2_CloakType"):GetString()
cloakconfig["CloakMode"] = GetConVar("bc2_CloakMode"):GetString()
cloakconfig["CloakUntilVel"] = GetConVar("bc2_CloakUntilVel"):GetInt()
cloakconfig["MinimumVisibility"] = GetConVar("bc2_MinimumVisibility"):GetInt()
cloakconfig["CloakMaterial"] = GetConVar("bc2_CloakMaterial"):GetString()
cloakconfig["ChargeGainMultiplier"] = GetConVar("bc2_ChargeGainMultiplier"):GetFloat()
cloakconfig["ChargeLossMultiplier"] = GetConVar("bc2_ChargeLossMultiplier"):GetFloat()
cloakconfig["MaxCharge0"] = 0
cloakconfig["MaxCharge1"] = GetConVar("bc2_MaxCharge1"):GetInt()
cloakconfig["MaxCharge2"] = GetConVar("bc2_MaxCharge2"):GetInt()
cloakconfig["MaxCharge3"] = GetConVar("bc2_MaxCharge3"):GetInt()
cloakconfig["MinimumNPCVisibility"] = GetConVar("bc2_MinimumNPCVisibility"):GetInt()
cloakconfig["UncloakInVehicle"] = GetConVar("bc2_UncloakInVehicle"):GetBool()
cloakconfig["CloakOverlay"] = GetConVar("bc2_CloakOverlay"):GetString()
cloakconfig["MinimumIDVisibility"] = GetConVar("bc2_MinimumIDVisibility"):GetInt()
cloakconfig["CloakFireMode"] = GetConVar("bc2_CloakFireMode"):GetInt()
cloakconfig["LoseChargeAmountFire"] = GetConVar("bc2_LoseChargeAmountFire"):GetFloat()
cloakconfig["TempDisableTimeFire"] = GetConVar("bc2_TempDisableTimeFire"):GetFloat()
cloakconfig["CloakDamageMode"] = GetConVar("bc2_CloakDamageMode"):GetInt()
cloakconfig["LoseChargeAmountHurt"] = GetConVar("bc2_LoseChargeAmountHurt"):GetFloat()
cloakconfig["TempDisableTimeHurt"] = GetConVar("bc2_TempDisableTimeHurt"):GetFloat()
cloakconfig["CloakEffectOn"] = GetConVar("bc2_CloakEffectOn"):GetString()
cloakconfig["CloakEffectOff"] = GetConVar("bc2_CloakEffectOff"):GetString()
cloakconfig["ToggleTime"] = GetConVar("bc2_ToggleTime"):GetFloat()
-- Audio
cloakconfig["DistortSound"] = GetConVar("bc2_DistortSound"):GetInt()
cloakconfig["EnableSound"] = GetConVar("bc2_EnableSound"):GetString()
cloakconfig["DisableSound"] = GetConVar("bc2_DisableSound"):GetString()
cloakconfig["ForceDisableSound"] = GetConVar("bc2_ForceDisableSound"):GetString()
cloakconfig["ToggleFailureSound"] = GetConVar("bc2_ToggleFailureSound"):GetString()
cloakconfig["FootstepVolume"] = GetConVar("bc2_FootstepVolume"):GetFloat()
cloakconfig["TauntSound"] = GetConVar("bc2_TauntSound"):GetString()
cloakconfig["TauntVolume"] = GetConVar("bc2_TauntVolume"):GetFloat()
cloakconfig["TauntDelay"] = GetConVar("bc2_TauntDelay"):GetFloat()




for k,v in pairs(cloakconfig) do
    cvars.AddChangeCallback(k, function(convarName, oldValue, newValue) 

            tableCV[convarName] = newValue


    end)
end