/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

if SERVER then
    AddCSLuaFile()
end

function SWEP:Initialize()
self:SetHoldType( "fist" )
	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end



SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

local author_first_names = {"Luna", "Nova", "Vega", "Orion", "Phoenix", "Aurora", "Stella", "Nebula", "Galaxy", "Comet"}
local author_last_names = {"Starlight", "Nightsky", "Cosmos", "Moonbeam", "Skywatcher", "Solarflare", "Supernova", "Meteorite", "Celestial", "Astro"}

SWEP.Author = author_first_names[math.random(#author_first_names)] .. " " .. author_last_names[math.random(#author_last_names)]
SWEP.Contact = SWEP.Author:lower():gsub(" ", "") .. "@example.com"
SWEP.Purpose = "Switch places with a random player or NPC in the game"
SWEP.Instructions = ""

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {

	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}
SWEP.VElements = {
	["switch"] = { type = "Model", model = "models/nintendo_switch/switch.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(-0.519, 4.675, -0.519), angle = Angle(-162.469, 3.506, -5.844), size = Vector(0.69, 0.69, 0.69), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["switch"] = { type = "Model", model = "models/nintendo_switch/switch.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 7.791, 0.518), angle = Angle(180, -5.844, -12.858), size = Vector(0.69, 0.69, 0.69), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


AddCSLuaFile()

if CLIENT then
end

SWEP.PrintName			= "Bestial 4"
SWEP.Category       = "Bestial"
SWEP.Author			= "itsElub"
SWEP.Instructions	= ""

SWEP.Spawnable			= true
SWEP.UseHands			= true

SWEP.ViewModel			= Model( "models/weapons/c_arms_apex.mdl" )
SWEP.WorldModel			= ""

SWEP.ViewModelFOV		= 64
SWEP.BobScale		= 1.3
SWEP.SwayScale		= 1.3

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.ViewModelFlip = false;

SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Slot				= 4
SWEP.SlotPos			= 1

SWEP.DrawAmmo = false
SWEP.DrawCrosshair		= false

SWEP.DisableDuplicator = true
SWEP.BounceWeaponIcon = false
SWEP.m_bPlayPickupSound = false

SWEP.HitDistance = 300

local function genOrderedTbl(str, min, max)
	if not min then min = 1 end
	if not max then
		max = min
		min = 1
	end
	local tbl = {}
	for i = min, max do
		table.insert(tbl, str:format(i))
	end
	return tbl
end

sound.Add({
    name = "apexarms.deploy",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {80, 110},
	sound = genOrderedTbl("weapons/Pilot_Mvmt_Foley_FistRise_1ch_v1_%i.wav", 3),
})

sound.Add({
    name = "apexarms.inspect",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {80, 110},
    sound = "weapons/Mvmt_Generic_KnuckleCrack_v1_01.wav"
})

sound.Add({
    name = "apexarms.melee_swing",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {90, 110},
	sound = genOrderedTbl("weapons/Pilot_Mvmt_Melee_LeftHook_1P_2ch_v1_%i.wav", 3),
	sound = genOrderedTbl("weapons/Pilot_Mvmt_Melee_RightHook_1P_2ch_v1_%i.wav", 3)
})

sound.Add({
    name = "apexarms.melee_punch",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {90, 110},
	sound = genOrderedTbl("weapons/Pilot_Mvmt_Melee_Elbow_1P_2ch_v1_%i.wav", 3)
})

sound.Add({
    name = "apexarms.Uppercut_swing",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {90, 110},
	sound = genOrderedTbl("weapons/Pilot_Mvmt_Melee_Uppercut_1P_2ch_v1_%i.wav", 3)
})

sound.Add({
    name = "apexarms.melee_hit",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {90, 115},
	sound = genOrderedTbl("weapons/Pilot_Mvmt_Melee_Hit_Flesh_1P_2ch_v1_%i.wav", 6)
})

sound.Add({
    name = "apexarms.melee_hit_World",
    channel = CHAN_AUTO,
    level = 75,
    volume = 1,
    pitch = {90, 115},
	sound = genOrderedTbl("weapons/Imp_Player_MeleePunch_Default_1ch_v1_%i.wav", 4)
})

sound.Add({
    name = "apexarms.melee_hit_Concrete",
    channel = CHAN_AUTO,
    level = 75,
    volume = 1,
    pitch = {90, 115},
	sound = genOrderedTbl("weapons/Imp_Player_MeleePunch_Concrete_1ch_v1_%i.wav", 4)
})

sound.Add({
    name = "apexarms.melee_hit_Water",
    channel = CHAN_AUTO,
    level = 75,
    volume = 1,
    pitch = {90, 115},
	sound = genOrderedTbl("weapons/Imp_Player_MeleePunch_Water_1ch_v1_%i.wav", 4)
})

sound.Add({
    name = "apexarms.melee_hit_Metal",
    channel = CHAN_AUTO,
    level = 75,
    volume = 1,
    pitch = {90, 115},
	sound = genOrderedTbl("weapons/Imp_Player_MeleePunch_Metal_1ch_v1_%i.wav", 4)
})

sound.Add({
    name = "apex.kick_swing",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {80, 115},
	sound = genOrderedTbl("weapons/Pilot_Mvmt_Melee_WallKick_1P_2ch_v1_%i.wav", 3)
})

util.PrecacheSound("apexarms.deploy")
util.PrecacheSound("apexarms.inspect")
util.PrecacheSound("apexarms.melee_swing")
util.PrecacheSound("apexarms.Uppercut_swing")
util.PrecacheSound("apexarms.melee_punch")
util.PrecacheSound("apexarms.melee_hit")
util.PrecacheSound("apexarms.melee_hit_world")
util.PrecacheSound("apexarms.melee_hit_water")
util.PrecacheSound("apexarms.melee_hit_metal")
util.PrecacheSound("apexarms.melee_hit_concrete")

util.PrecacheSound("apex.kick_swing")

local SwingSound = Sound( "apexarms.melee_swing" )
local SwingSound2 = Sound( "apexarms.melee_punch" )
local UppercutSound = Sound( "apexarms.Uppercut_swing" )

local DeploySound = Sound( "apexarms.deploy" )
local HitSound = Sound( "apexarms.melee_hit" )
local WorldHitSound = Sound( "apexarms.melee_hit_world" )
local WaterHitSound = Sound( "apexarms.melee_hit_water" )
local MetalHitSound = Sound( "apexarms.melee_hit_metal" )
local ConcreteHitSound = Sound( "apexarms.melee_hit_concrete" )
local inspectsound = Sound( "apexarms.inspect" )

if SERVER then
    util.AddNetworkString("ApexMelee_HitKillable")
end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "AnimationTime" )
	self:NetworkVar( "Float", 1, "NextMeleeAttack" )
	self:NetworkVar( "Int", 0, "Combo" )
	self:NetworkVar( "Int", 1, "AnimPriority" )
	self:NetworkVar( "String", 0, "CurrentAnim" )
	self:NetworkVar( "Bool", 0, "LastGroundState" )

end

function SWEP:Initialize()
	self:SetHoldType("fist")
end

function SWEP:SetAnim(anim, forceplay, animpriority)

    // Set the default arguments
    if (forceplay == nil) then
        forceplay = false
    end
    if (animpriority == nil) then
        animpriority = 0
    end
    
    // If we're idle, if we're forced to play this animation, then play the given animation
    if (self:IsIdle() || (forceplay && self:GetAnimPriority() <= animpriority)) then
        local vm = self.Owner:GetViewModel()
        self:SetCurrentAnim(anim)
        vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
        self:SetAnimationTime(CurTime() + vm:SequenceDuration()/vm:GetPlaybackRate())
        self:SetAnimPriority(animpriority)
    end
end

function SWEP:IsIdle()
end

function SWEP:HandleAnimations()
end

function SWEP:Deploy()

	local vm = self.Owner:GetViewModel()
	
	self:EmitSound( DeploySound )
	self:SetHoldType("fist")
	vm:SetWeaponModel("models/weapons/c_arms_apex.mdl", self)
	
	self:SetAnim("deploy", true, 1)
	if ( SERVER ) then
		self:SetCombo( 0 )
	end

	return true

end

function SWEP:OnDrop()
	self:Remove() -- You can't drop fists
end

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack( right )
    local currentAnimFSF = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())
	self:SetHoldType("fist")
    self.Owner:SetAnimation( PLAYER_ATTACK1 )

    local anim = "fists_left"
    if ( right ) then 
        anim = "fists_right"
	end

	timer.Simple(0.1, function()
        if (!IsValid(self)) then return end
        self.Owner:ViewPunch(Angle(0, 0, 0))
	end)                     

    if ( self:GetCombo() >= 2 ) then
        anim = "fists_uppercut"
		self:EmitSound( SwingSound2 )
    end
    self:SetAnim(anim, true, 3)

    self:EmitSound( SwingSound )

    //self:UpdateNextIdle()
    self:SetNextMeleeAttack( CurTime() + 0.001 )

    self:SetNextPrimaryFire( CurTime() + 0.1 )
    self:SetNextSecondaryFire( CurTime() + 0.1 )
	
	if self.Owner:Crouching() then 
        self:SetAnim("fists_uppercut2", true, 3)
        self:EmitSound( UppercutSound )
        timer.Simple( 0.2, function()
            if (!IsValid(self)) then return end
            self.Owner:ViewPunch(Angle(0, 0, 0))
        end)
    end
end

local phys_pushscale = GetConVar( "phys_pushscale" )
function SWEP:DealDamage()

	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	self.Owner:LagCompensation( true )

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector( -100, -10, -8 ),
			maxs = Vector( 100, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	-- if ( tr.Hit && !( game.SinglePlayer() && CLIENT ) ) then
		-- self:EmitSound( HitSound )
	-- end

	if (tr.Hit && (SERVER || !(game.SinglePlayer() && CLIENT))) then
        if (tr.HitWorld) then
            self:EmitSound( WorldHitSound )
        elseif (tr.MatType == MAT_CONCRETE) then
            self:EmitSound( ConcreteHitSound )
        elseif (tr.MatType == MAT_WOOD) then
            self:EmitSound( WorldHitSound )
        elseif (tr.MatType == MAT_METAL) then
            self:EmitSound( MetalHitSound )
        elseif (tr.MatType == MAT_FLESH) then
            self:EmitSound( HitSound )
        else
            self:EmitSound( WorldHitSound )
        end
    end

	local hit = false
	local scale = phys_pushscale:GetFloat()

	if ( SERVER && IsValid( tr.Entity ) && ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) ) then
		local dmginfo = DamageInfo()

		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )

		dmginfo:SetInflictor( self )
		dmginfo:SetDamage( math.random( 75, 75, 75 ) )

		if ( anim == "fists_left" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * 5912 * scale + self.Owner:GetForward() * 35000 * scale ) -- Yes we need those specific numbers
		elseif ( anim == "fists_right" ) then
			dmginfo:SetDamageForce( self.Owner:GetRight() * -5912 * scale + self.Owner:GetForward() * 38000 * scale )
		elseif ( anim == "fists_uppercut" ) then
			dmginfo:SetDamageForce( self.Owner:GetUp() * 3158 * scale + self.Owner:GetForward() * 15012 * scale )
			dmginfo:SetDamage( math.random( 80, 80, 80 ) )
		elseif ( anim == "fists_uppercut2" ) then
			dmginfo:SetDamageForce( self.Owner:GetUp() * 25158 * scale + self.Owner:GetForward() * 24000 * scale + self.Owner:GetRight() * 8912 * scale )
			dmginfo:SetDamage( math.random( 85, 85 ) )
		elseif ( anim == "fists_uppercut2_alt" ) then
			dmginfo:SetDamageForce( self.Owner:GetUp() * 25158 * scale + self.Owner:GetForward() * 28000 * scale + self.Owner:GetRight() * -8912 * scale )
			dmginfo:SetDamage( math.random( 90, 90 ) )
		elseif ( anim == "fists_elbowstrike" ) then
		    dmginfo:SetDamageForce( self.Owner:GetUp() * 30000 * scale + self.Owner:GetForward() * 25000 * scale )
			dmginfo:SetDamage( math.random( 100, 100, 100 ) )
		end

		SuppressHostEvents( NULL ) -- Let the breakable gibs spawn in multiplayer on client
		tr.Entity:AddEFlags("-2147483648" )
		tr.Entity:TakeDamageInfo( dmginfo )
		tr.Entity:RemoveEFlags("-2147483648" )
		SuppressHostEvents( self.Owner )

        hit = true
        if (tr.Entity:IsPlayer() || tr.Entity:IsNPC()) then
            net.Start("ApexMelee_HitKillable")
            net.WriteEntity(tr.Entity)
            net.Send(self.Owner)
		end

	end

	if ( IsValid( tr.Entity ) ) then
		local phys = tr.Entity:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * 1500 * phys:GetMass() * scale, tr.HitPos )
		end
	end
	

	if ( SERVER ) then
		if ( hit && anim != "fists_uppercut" ) then
			self:SetCombo( self:GetCombo() + 1 )
		else
			self:SetCombo( 0 )
		end
	end

	self.Owner:LagCompensation( false )

end

function SWEP:SecondaryAttack()
    local currentAnimFSF = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())
	self:SetHoldType("fist")
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local anim = "fists_right"
	if ( right ) then anim = "fists_right" end
	if ( self:GetCombo() >= 2 ) then
        anim = "fists_elbowstrike"
	end

    self:SetAnim(anim, true, 3)

	timer.Simple(0.1, function()
        if (!IsValid(self)) then return end
        self.Owner:ViewPunch(Angle(-0, 0, 0))
	end)  

	self:EmitSound(SwingSound)

	//self:UpdateNextIdle()
	self:SetNextMeleeAttack( CurTime() + 0.001 )

	self:SetNextPrimaryFire( CurTime() + 0.1 )
	self:SetNextSecondaryFire( CurTime() + 0.1 )
	
	if self.Owner:Crouching() then 
        self:SetAnim("fists_uppercut2_alt", true, 3)
        self:EmitSound( UppercutSound )
        timer.Simple( 0.2, function()
            if (!IsValid(self)) then return end
            self.Owner:ViewPunch(Angle(0, 0, 0))
        end)
    end
end

function SWEP:Reload(right) 

    self:SetNextPrimaryFire(CurTime() + 0)

    local tr = self.Owner:GetEyeTrace()
    local target = tr.Entity

    if IsValid(target) and (target:IsPlayer() or target:IsNPC() or target:GetClass() == "prop_physics") then


        local ownerPos = self.Owner:GetPos()
        local targetPos = target:GetPos()

        self.Owner:SetPos(targetPos)
		if (target:GetClass() == "prop_physics") then
        target:SetPos(ownerPos + Vector(0, 0, 50) )
		else
		target:SetPos(ownerPos)
		end
		self.Owner:EmitSound("clapswap.mp3")

        self.Owner:ViewPunch(Angle(-10, 0, 0))
    end
end

function SWEP:IsMoving()
    return (self.Owner:KeyDown(IN_FORWARD) || self.Owner:KeyDown(IN_BACK) || self.Owner:KeyDown(IN_MOVELEFT) || self.Owner:KeyDown(IN_MOVERIGHT))
end

function SWEP:Think()

    local plyvel = Vector(self.Owner:GetVelocity().x, self.Owner:GetVelocity().y, 0):Length()

	local meleetime = self:GetNextMeleeAttack()
	if ( meleetime > 0 && CurTime() > meleetime ) then
		self:DealDamage()
		self:SetNextMeleeAttack( 0 )
	end

	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then
		self:SetCombo( 0 )
	end
	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0 ) then
		self:SetHoldType("normal")
	end
    
    // Handle jumping animations
    if (self.Owner:KeyPressed(IN_JUMP) && self:GetLastGroundState() == true && !self.Owner:OnGround()) then
        if (plyvel > self.Owner:GetRunSpeed()*0.9) then
            if (GetConVar("cl_apexmelee_animjumpsprint"):GetBool()) then
                self:SetAnim("jumprun", true, 1)
            end
        else
            if (GetConVar("cl_apexmelee_animjump"):GetBool()) then
                self:SetAnim("jumpstand", true, 1)
            end
        end
    end
    
    // Handle movement animations
    if (self:IsMoving() && self.Owner:OnGround() && !self.Owner:Crouching() && self.Owner:WaterLevel() < 2 && plyvel > self.Owner:GetRunSpeed()*0.9) then
        if (self:GetCurrentAnim() != "sprint") then
            if (GetConVar("cl_apexmelee_animsprint"):GetBool()) then
                self:SetAnim("sprint", true)
            else
                self:SetAnim("idle1", true)
            end
        end
    elseif (self:IsMoving() && self.Owner:OnGround() && self.Owner:WaterLevel() < 2 && (plyvel > self.Owner:GetWalkSpeed()*0.9 || (self.Owner:Crouching() && plyvel > self.Owner:GetCrouchedWalkSpeed()*0.9))) then
        if (self.Owner:Crouching() && self:GetCurrentAnim() != "crouch_walk") then
            if (GetConVar("cl_apexmelee_animcrouch"):GetBool()) then
                self:SetAnim("crouch_walk", true)
            end
        elseif (!self.Owner:Crouching() && self:GetCurrentAnim() != "walk") then
            if (GetConVar("cl_apexmelee_animwalk"):GetBool()) then
                self:SetAnim("walk", true)
            else
                self:SetAnim("idle1", true)
            end
        end
    else
        local force = false
        
        // Force if we were previously walking
        if (self:GetCurrentAnim() == "sprint" || self:GetCurrentAnim() == "crouch_walk" || self:GetCurrentAnim() == "walk") then
            force = true
        end
        
        // Force if we switched crouching
        if (self:GetCurrentAnim() == "crouch" && self.Owner:OnGround() && !self.Owner:Crouching()) then
            force = true
        elseif (self:GetCurrentAnim() == "idle1" && self.Owner:OnGround() && self.Owner:Crouching()) then
            force = true
        end
        
        if (self.Owner:Crouching() && self.Owner:OnGround()) then
            if (self:GetCurrentAnim() != "crouch") then
                if (GetConVar("cl_apexmelee_animcrouch"):GetBool()) then
                    self:SetAnim("crouch", force)
                end
            end
        elseif (self:GetCurrentAnim() != "idle1") then
            self:SetAnim("idle1", force)
        end
    end
    self:SetLastGroundState(self.Owner:OnGround())
end

-- function SWEP:DrawWeaponSelection()
-- end

function SWEP:PrintWeaponInfo()
    return false
end

if (CLIENT) then
    net.Receive("ApexMelee_HitKillable", function(len, ply)
        if (!GetConVar("cl_apexmelee_hitmarker"):GetBool()) then return end
        if (IsValid(LocalPlayer():GetActiveWeapon())) then
            LocalPlayer():GetActiveWeapon().HitMarkerEnt = net.ReadEntity()
        end
    end)

    local hitmarkeralpha = 0
    local hitmarkersize = 0
    local hitmarkerholdtime = 0
    local hitmarkercolor = Color(255, 255, 255)
    local hitmarkermat = Material("hud/apex_melee/hitmarker.png")
    function SWEP:DrawHUD()
    
        // Make the marker if we hit something
        if (LocalPlayer():GetActiveWeapon().HitMarkerEnt != nil) then
        
            // Initialize the hitmarker
            hitmarkeralpha = 255
            hitmarkersize = 128
            hitmarkerholdtime = CurTime() + 0.5
            if (!IsValid(LocalPlayer():GetActiveWeapon().HitMarkerEnt) || LocalPlayer():GetActiveWeapon().HitMarkerEnt:Health() > 0) then
                hitmarkercolor = Color(255, 255, 255)
            else
                hitmarkercolor = Color(255, 0, 0)
            end
            
            -- self:EmitSound("YourHitmarkerSoundHere")
            LocalPlayer():GetActiveWeapon().HitMarkerEnt = nil
        end
        
        // Draw it on the screen
        if (hitmarkerholdtime > CurTime()) then
            local resw = ScrW()/1600
            local resh = ScrH()/900
            local hitw = hitmarkersize*resw
            local hith = hitmarkersize*resh
            
            // Animate the marker
            hitmarkersize = Lerp(1*FrameTime(), hitmarkersize, 0)
            hitmarkeralpha = Lerp(3*FrameTime(), hitmarkeralpha, 0)
            
            // Draw the marker
            surface.SetDrawColor(hitmarkercolor.r, hitmarkercolor.g, hitmarkercolor.b, hitmarkeralpha)
            surface.SetMaterial(hitmarkermat)
            surface.DrawTexturedRect(ScrW()/2 - hitw/2, ScrH()/2 - hith/2, hitw, hith)
        end
    end
end

function SWEP:AddCustomSwapHooks()
end

function SWEP:JumpHookCreateTodo()
end

function SWEP:JumpHookRemoveTodo()
end