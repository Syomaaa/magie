if (SERVER) then
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= false
end

if (CLIENT) then
	SWEP.PrintName		= "Anti Magie 4"
	SWEP.DrawAmmo		= false
	SWEP.DrawCrosshair	= true
	SWEP.ViewModelFOV	= 70
	SWEP.ViewModelFlip	= false
	SWEP.CSMuzzleFlashes	= false
end

/*---------------------------------------------------------
	Main SWEP Setup
---------------------------------------------------------*/
SWEP.Author		= "Brounix"
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true
SWEP.Category		= "Anti Magie"

SWEP.WorldModel		= "models/epee_asta/epee_asta2.mdl"
SWEP.ViewModel		= ""
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ReloadRate		= 1
SWEP.JumpRefire		= false
SWEP.OldSpin		= 0
SWEP.HoldType		= "rollsword"

local config = {}
config.dmg1 = 160 
config.dmg2 = 185 --dgt de base entre .. et ..

config.dmgup1 = 200
config.dmgup2 = 250 --dgt click droit saut entre .. et ..

config.dmgleap1 = 200
config.dmgleap2 = 250 --dgt click droit en avant entre .. et ..

config.dmgslh1 = 500
config.dmgslh2 = 500 --dgt slash entre .. et ..

config.tmpShield = 10

config.dmgspin1 = 50
config.dmgspin2 = 50 --dgt tornade entre .. et ..

SWEP.Cooldown = 35 --cooldown general pour utiliser une atk spe
SWEP.CooldownDelay = 0

config.canSwitch = true

SWEP.Cooldown1 = 35 --cooldown shield
SWEP.Cooldown2 = 20 --cooldown slash
SWEP.Cooldown3 = 20 --cooldown tornade
SWEP.Cooldown4 = 20 --cooldown zone


SWEP.ActionDelay = 0.2
SWEP.NextAction = 0

SWEP.CooldownDelay1 = 0
SWEP.CooldownDelay2 = 0
SWEP.CooldownDelay3 = 0
SWEP.CooldownDelay4 = 0

SWEP.WElements = {
	["ailes"] = { type = "Model", model = "models/asta/wings.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(18,8, -30), angle = Angle(120, 160, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
	["tete"] = { type = "Model", model = "models/asta/head.mdl", bone = "ValveBiped.Bip01_Head1", rel = "", pos = Vector(8, -1, 2), angle = Angle(-120, -60, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
}

local AttackHit2 = Sound( "custom characters/attack_hit2.wav")
local AttackHit1 = Sound( "custom characters/attack_hit.wav")
local Hitground2 = Sound( "custom characters/attack4_hit.mp3")
local Hitground = Sound( "custom characters/sword_crash.wav")
local Ready = Sound( "custom characters/sword_ready.wav")
local Stapout = Sound( "custom characters/sword_stapouthit.wav")
local Stapin = Sound( "custom characters/sword_stabinhit.wav")
local Stap = Sound( "custom characters/sword_stap.wav")
local Cloth = Sound( "custom characters/player_cloth.wav")
local Roll = Sound( "npc/combine_soldier/gear2.wav")
local Combo1 = Sound( "custom characters/sword_swim1.wav")
local Combo2 = Sound( "custom characters/sword_swim2.wav")
local Combo3 = Sound( "custom characters/sword_swim3.wav")
local Combo4 = Sound( "custom characters/sword_swim4.wav")
local SwordTrail = Sound ( "custom characters/sword_trail.mp3" )

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "AntiMagie4" )
	if (SERVER) then
		self:SetAntiMagie4( 1 )
	end
end

function SWEP:Initialize()
	self.combo = 11
	self:SetHoldType("g_combo1")
	self.duringattack = false
	self.backtime = 0
	self.duringattacktime = 0
	self.dodgetime = 0
	self.plyindirction = false
	self.DownSlashed = true
	self.downslashingdelay = 0
	self.back = true


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

if CLIENT then
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

/*---------------------------------------------------------
	SWEP:Think Operations
---------------------------------------------------------*/
function SWEP:Think()
	local ply = self.Owner

	if self.duringattacktime < CurTime() then
		self.duringattack = true
	elseif self.duringattacktime > CurTime() then
		self.duringattack = false
	end

	if ply:IsOnGround() then
		self.DownSlashed = true
	end

	if  self.duringattacktime == CurTime() then
		self.back = true
	end

	if  self.duringattacktime < CurTime() and self.back == false and self.Owner:IsOnGround() then
		self.back = true
		self:SetHoldType("g_restart")
		ply:SetAnimation( PLAYER_ATTACK1 )
	end

	if self.Spinning == 1 then
		if self.OldSpin == 0 then
			self.Owner:SetEyeAngles( Angle(0, self.Owner:EyeAngles().y + 11.0773, 0) )
			for k,v in pairs(ents.FindInSphere(self.Owner:GetPos() ,400)) do
				if IsValid(v) and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmgspin1,config.dmgspin2) )
					dmginfo:SetDamagePosition( self.Owner:GetPos() )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)
				end
			end
		end

		if self.OldSpin == 1 then
			self.Owner:SetEyeAngles( Angle(0, self.Owner:EyeAngles().y + 22.154, 0) )
			for k,v in pairs(ents.FindInSphere(self.Owner:GetPos() ,400)) do
				if IsValid(v) and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmgspin1,config.dmgspin2) )
					dmginfo:SetDamagePosition( self.Owner:GetPos() )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	end
end

/*---------------------------------------------------------
	Primary Attack (Sword Swinging)
---------------------------------------------------------*/
function SWEP:KillMove()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
	local ply = self.Owner
	self:SetHoldType("g_combo32")
	ply:SetAnimation( PLAYER_ATTACK1 )
	self.duringattack = true
	self.duringattacktime = CurTime() + 1.2
	self.dodgetime = CurTime() + 1.3
	self.Owner:ViewPunch(Angle(5, 1, 0))

	timer.Simple(0.2, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			ply:SetVelocity((self.Owner:GetForward() * 1) * 500 + Vector(0,0,50) )	
			ply:EmitSound(Combo2, 75, 80, 0.2, CHAN_AUTO)
			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmg1,config.dmg2)/3 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
			
			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 100, 200 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					ply:EmitSound(Stap, 75, 80, 0.2, CHAN_AUTO)
					if v:IsNPC() or type( v ) == "NextBot" then
						if SERVER then
							v:EmitSound(Stapin, 75, 80, 0.2, CHAN_AUTO)					
							v:SetVelocity((self.Owner:GetForward() * 1) * 100  )	
							ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
						end
					end
					if v:IsPlayer() then
						v:EmitSound(Stapin, 75, 80, 0.2, CHAN_AUTO)					
						v:SetVelocity((self.Owner:GetForward() * 1) * 100 )	
						ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
					end
					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)

	timer.Simple(0.75, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			ply:SetVelocity((self.Owner:GetForward() * 1) * -400 + Vector(0,0,50) )	
			ply:EmitSound(Combo3, 75, 80, 0.2, CHAN_AUTO)
			ply:EmitSound(Stap, 75, 80, 0.2, CHAN_AUTO)
			self.Owner:ViewPunch(Angle(-5, -1, 0))
			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmg1,config.dmg2)*3) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 100, 200 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() or type( v ) == "NextBot" then
						if SERVER then
							v:EmitSound(Stapout, 75, 80, 0.2, CHAN_AUTO)					
							v:SetVelocity((self.Owner:GetForward() * 1) * 100  )	
							ParticleEffect("blood_advisor_puncture_withdraw",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
						end
					end
					if v:IsPlayer() then--
						v:EmitSound(Stapout, 75, 80, 0.2, CHAN_AUTO)		
						v:SetVelocity((self.Owner:GetForward() * 1) * 100 )	
						ParticleEffect("blood_advisor_puncture_withdraw",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
					end
					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)
end

function SWEP:DoCombo( hitsound, combonumber, force, attackdelay, anim, viewbob, primarystuntime, stuntime, sound, sounddelay, hastrail, haspush, push, pushdelay ,pushenemy)
	local ply = self.Owner
	self.back = false
	self.combo = combonumber
	self:SetHoldType(anim)
	ply:ViewPunch(viewbob)
	self.backtime = CurTime() + stuntime

	if haspush == true then
		timer.Simple(pushdelay, function()
			if IsValid(self) and self:GetOwner():Alive() then
				ply:SetVelocity((self.Owner:GetForward() * 1) * push + Vector(0,0,50) )	
			end
		end)
	end
	timer.Simple(sounddelay, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			ply:EmitSound(sound, 75, 80, 0.2, CHAN_AUTO)
			if hastrail == true then
				ply:EmitSound(SwordTrail, 75, 80, 0.2, CHAN_AUTO)
			end
		end
	end)

	self.dodgetime = CurTime() + primarystuntime
	ply:SetAnimation( PLAYER_ATTACK1 )
	self.duringattack = true
	self.duringattacktime = CurTime() + stuntime
	self.Weapon:SetNextPrimaryFire(CurTime() + primarystuntime )

	timer.Simple(attackdelay, function()
		if IsValid(self) and self:GetOwner():Alive() then
			local k, v

			local dmg = DamageInfo()
			dmg:SetDamage( force ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 100, 200 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() or type( v ) == "NextBot" then
						if SERVER then
							v:EmitSound(hitsound, 75, 80, 0.2, CHAN_AUTO)
							v:TakeDamageInfo( dmg )	ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
						end
					end

					if v:IsPlayer() then
						v:EmitSound(hitsound, 75, 80,0.2, CHAN_AUTO)
						v:TakeDamageInfo( dmg )	ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
					end
				end	
			end
		end
	end)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.6 )

	if self.combo == 0 then
		return 
	end

	if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyDown(IN_ATTACK) and (self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_FORWARD)) then
	else
		if self.Owner:IsOnGround() then
			if self.combo == 11 then
				self:DoCombo( AttackHit1, 11, math.random(config.dmg1,config.dmg2), 0.16, "g_combo1", Angle(3, -3, 0),0.3, 0.7, Combo1, 0.14, false, true, 150, 0.2 )
				self.combo = 12
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 12 then
							self.combo = 11 
						end
					end
				end)
			elseif self.combo == 12 then
				self:DoCombo( AttackHit2, 12, math.random(config.dmg1,config.dmg2), 0.15, "g_combo2", Angle(1, 3, 0), 0.4, 0.8, Combo4, 0.12, false, true, 230, 0.2 )
				self.combo = 13
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 13 then
							self.combo = 11
						end
					end
				end)
			elseif self.combo == 13 then
				self:DoCombo( AttackHit1, 13, math.random(config.dmg1,config.dmg2),  0.17, "g_combo3", Angle(-2, -3, 0),0.3, 0.9, Combo2, 0.17, false, true, 300, 0.2 )
				self.combo = 14
				timer.Simple(0.8, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 14 then
							self.combo = 15
							timer.Simple(0.7, function()
								if IsValid(self) and self:GetOwner():Alive() then
									if self.combo == 15 then
										self.combo = 11
									end
								end
							end)
						end
					end
				end)
			elseif self.combo == 14 then
				self.Owner:EmitSound(Ready)
				self:DoCombo( Stapout, 14, math.random(config.dmg1*2,config.dmg2*2), 0.4, "g_combo4", Angle(3, -5, 0), 1.3, 1.2, Combo3, 0.4, true, true, 600, 0.3, false, true )
				self.combo = 11
				self.Owner:EmitSound(Cloth)
			elseif self.combo == 15 then
				self:KillMove()
				self.combo = 14
				timer.Simple(1.8, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 14 then
							self.combo = 11
						end
					end
				end)
			end
		end
		if not self.Owner:IsOnGround() then
			if self.combo == 11 then
				self:DoCombo( AttackHit2, 21, math.random(config.dmg1,config.dmg2), 0.16, "a_combo1", Angle(3, -3, 0), 0.25, 0.7, Combo1, 0.14, false, false, 150, 0.2 , true)
				self.combo = 12
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 12 then
							self.combo = 11 
						end
					end
				end)
			end
		end
	end
end

/*---------------------------------------------------------
	Secondary Attack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if !SERVER then return end
	if not self.Owner:IsOnGround() then
		self:SlashDown()
		self.Weapon:SetNextSecondaryFire(CurTime() + 4 )
	else
		if self.Owner:KeyDown( IN_FORWARD ) then
			self:LeapAttack()
			self.Weapon:SetNextSecondaryFire(CurTime() + 4)
		end
	end
end

function SWEP:SlashDown()
	local ply = self.Owner
	self.Owner:ViewPunch(Angle(-4, 4, 6))
	config.reset = false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1.5 )

	timer.Simple(0.01,function()
		self:SetHoldType("slashdown")
		ply:SetAnimation( PLAYER_ATTACK1 )
	end)

	self.duringattack = true
	self.duringattacktime = CurTime() + 1
	self.dodgetime = CurTime() + 1.2

	local pl = self.Owner
	local ang = pl:GetAngles()
	local forward, right = ang:Forward(), ang:Right()		
	local vel = -1 * pl:GetVelocity()
	vel = vel + Vector(0, 0, 200)
	local spd = pl:GetMaxSpeed()
			
	if pl:KeyDown(IN_FORWARD) then
		vel = vel + forward * spd
	elseif pl:KeyDown(IN_BACK) then
		vel = vel - forward * spd
	end
			
	if pl:KeyDown(IN_MOVERIGHT) then
		vel = vel + right * spd
	elseif pl:KeyDown(IN_MOVELEFT) then
		vel = vel - right * spd
	end
			
	pl:SetVelocity(vel) 

	timer.Simple(0.4, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			if SERVER then
				ply:EmitSound(Hitground)
			end
			self.combo = 11
			self.DownSlashed = false
			self.Owner:ViewPunch(Angle(4, -1, 0))

			local pl = self.Owner
			local ang = pl:GetAngles()
			local forward, right = ang:Forward(), ang:Right()
			local vel = -1 * pl:GetVelocity()
				
			vel = vel + Vector(0, 0, -2500)
				
			local spd = pl:GetMaxSpeed()
				
			if pl:KeyDown(IN_FORWARD) then
				vel = vel + forward * spd
			elseif pl:KeyDown(IN_BACK) then
				vel = vel - forward * spd
			end
				
			if pl:KeyDown(IN_MOVERIGHT) then
				vel = vel + right * spd
			elseif pl:KeyDown(IN_MOVELEFT) then
				vel = vel - right * spd
			end
				
			pl:SetVelocity(vel)
		end
	end)

	timer.Simple(0.3, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			if SERVER then
				ply:EmitSound(AttackHit2)
			end
			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmgup1,config.dmgup2) ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() + (self.Owner:GetForward() * 1) * 50, 120 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() then		
						if SERVER then
							v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,-2500) + (ply:GetForward() * 1) * 101 )	
						end
					end
					if v:IsPlayer() then		
						v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,-2500) + (ply:GetForward() * 1) * 100 )	
					end
					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)
	timer.Simple(1,function()
		if(IsValid(self) && self:GetOwner():Alive()) then
			self:EmitSound( Stap )
			self:SetHoldType("rollsword")	
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Owner:GodDisable()
		end
	end)
end

function SWEP:LeapAttack()
	if !SERVER then return end
	self.Owner:ViewPunch(Angle(3, 4, 3))
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.5 )
	self.back = false
	local ply = self.Owner
	
	self:SetHoldType("leap")
	ply:SetAnimation( PLAYER_ATTACK1 )
	if SERVER then
		ply:EmitSound(Ready)
		ply:EmitSound(Cloth)
	end
	self.duringattack = true
	self.duringattacktime = CurTime() + 1
	self.dodgetime = CurTime() + 1.2
	ply:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,200) )	

	timer.Simple(0.05, function()
		if IsValid(self) and self:GetOwner():Alive() then
			ply:SetVelocity((self.Owner:GetForward() * 1) * 2000 + Vector(0,0,-100) )
			self:SetHoldType("leapattack")
			ply:SetAnimation( PLAYER_ATTACK1 )
		end
	end)

	timer.Simple(0.3, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			if SERVER then
				ply:EmitSound(Hitground)	
			end
			self.Owner:ViewPunch(Angle(-6, -5, 0))

			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmgleap1,config.dmgleap2) ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50, 140 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() then
						if SERVER then
							v:EmitSound(AttackHit1)		
							v:SetVelocity((self.Owner:GetForward() * 1) * 80 + Vector(0,0,50) )	
						end
					end

					if v:IsPlayer() then
						v:EmitSound(AttackHit1)		
						v:SetVelocity((self.Owner:GetForward() * 1) * 80 + Vector(0,0,50) )	
					end

					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )

					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)
	timer.Simple(1, function()
		if IsValid(self) and self:GetOwner():Alive() then
			config.Reset = true
		end
	end)
end

/*---------------------------------------------------------
	Initialisation Reload bouton
---------------------------------------------------------*/
SWEP.Spinning = 0
function SWEP:Reload()
	if self:GetAntiMagie4() == 1 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay1 < CurTime() then
			self:BlockAttack()
			self.CooldownDelay1 = CurTime() + self.Cooldown1
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown1 .."s de cooldown avant le prochain spell !" )
		end
	elseif self:GetAntiMagie4() == 2 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:SlashAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown avant le prochain spell !" )
		end
	elseif self:GetAntiMagie4() == 3 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:TornadeAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown avant le prochain spell !" )
		end
	elseif self:GetAntiMagie4() == 4 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:ZoneAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown avant le prochain spell !" )
		end
	end
end

/*---------------------------------------------------------
	BlockAttack
---------------------------------------------------------*/
function SWEP:BlockAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay1 < CurTime() then if !SERVER then return end

		self.Weapon:SetNextSecondaryFire(CurTime() + config.tmpShield)
		self.Weapon:SetNextPrimaryFire(CurTime() + config.tmpShield)
		config.canSwitch = false
		self.Owner:GodEnable()

		local own = self:GetOwner()
		local shield = ents.Create( "shield3" ) 

		self:EmitSound( Cloth )
		self:SetHoldType("rollsword")
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		local pos = own:GetPos() + Vector(0,0,40)
		local ang = Angle(own:GetAngles().x,own:GetAngles().y,own:GetAngles().z):Forward()

		shield:SetPos( pos + ang)
		pos=pos+(ang*10)
		shield:SetParent(own)
		shield:SetAngles( Angle( ang.pitch, ang.yaw, 0 ) ) shield.Owner = own
		shield:Spawn() shield:Activate() own:DeleteOnRemove( shield )

		timer.Simple(config.tmpShield,function()
			if(IsValid(self) && self:GetOwner():Alive()) then
				config.canSwitch = true
				self:EmitSound( Stap )
				self:SetHoldType("rollsword")	
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				self.Owner:GodDisable()
			end
		end)

		if( !self:GetOwner():Alive()) then
			SafeRemoveEntityDelayed(self,0)
		end
		
		self.CooldownDelay1 = CurTime() + self.Cooldown1
		self.NextAction = CurTime() + self.ActionDelay
	else	
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown1 .."s de cooldown pour le bouclier !" )
	end
	return true
end

/*---------------------------------------------------------
	SlashAttack
---------------------------------------------------------*/
function SWEP:SlashAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay2 < CurTime() then if !SERVER then return end
 
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.8)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.8)


		timer.Simple(0.15, function()
			if(IsValid(self) && self:GetOwner():Alive()) then
				self:SetHoldType( "g_combo1" )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				timer.Simple(0.15, function()
					if(IsValid(self) && self:GetOwner():Alive()) then
						local own = self:GetOwner()
						local ang = Angle(0, own:EyeAngles().Yaw, 0)
						local pos = own:GetShootPos() + own:GetAimVector() * 40,10
						local dir = own:EyeAngles():Forward()*10000 +VectorRand():GetNormal()*50
						self:EmitSound( Combo3 )
						local slash2 = ents.Create( "slash3" )
						slash2:SetPos( pos )
						slash2:SetAngles( ang ) slash2:SetOwner( own )
						slash2:Spawn() slash2:Activate() own:DeleteOnRemove( slash2 )
						slash2:GetPhysicsObject():EnableGravity( false )
						slash2:GetPhysicsObject():SetVelocity( dir )
						slash2:SetPhysicsAttacker( own )
					end
				end)
			end
		end)
		timer.Simple(1, function()
			if IsValid(self) and self:GetOwner():Alive() and not self.Owner:KeyDown(IN_ATTACK) then
				self:SetHoldType("rollsword")
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
			end
		end)

	self.CooldownDelay2 = CurTime() + self.Cooldown2
	self.NextAction = CurTime() + self.ActionDelay
	else	
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .."s de cooldown pour le slash !" )
	end
    return true
end

/*---------------------------------------------------------
	TornadeAttack
---------------------------------------------------------*/
function SWEP:TornadeAttack()
	if IsValid(self) and self:GetOwner():Alive() then
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay3 < CurTime() then if !SERVER then return end

		config.canSwitch = false

		self.Weapon:SetNextSecondaryFire(CurTime() + 0.8)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.8)

		timer.Simple(0.01,function()
			self:SetHoldType( "leapattack" )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
		end)

		if SERVER then
			self.Owner:EmitSound(SwordTrail)
		end

		if self.OldSpin == 1 then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self.Owner:DoAttackEvent()
			self.ReloadRate = 0

			timer.Simple(0.98, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end
			end)
			timer.Simple(3, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end  
			end)  
			
			self.Spinning = 1
		end

		if self.OldSpin == 0 then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self.Owner:DoAttackEvent()
			self.ReloadRate = 0

			timer.Simple(1, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end
			end)
			timer.Simple(3, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end  
			end)  
			self.Spinning = 1

			if SERVER then 
				local own = self:GetOwner()
				local pos = own:GetPos()

				local antiornade = ents.Create("env_smokestack")
				antiornade:SetKeyValue("smokematerial", "effects/fire_cloud2.vmt")
				antiornade:SetKeyValue("rendercolor", "255 20 20" )
				antiornade:SetKeyValue("targetname","antiornade")
				antiornade:SetKeyValue("basespread","300")
				antiornade:SetKeyValue("spreadspeed","300")
				antiornade:SetKeyValue("speed","500")
				antiornade:SetKeyValue("startsize","50")
				antiornade:SetKeyValue("endzide","100")
				antiornade:SetKeyValue("rate","400")
				antiornade:SetKeyValue("jetlength","200")
				antiornade:SetKeyValue("twist","600")
				antiornade:SetPos(pos)
				antiornade:SetParent(self.Owner)
				antiornade:Spawn()
				antiornade:Fire("turnon","",0.1)
				antiornade:Fire("Kill","",1.2)

				local antiornade2 = ents.Create("env_smokestack")
				antiornade2:SetKeyValue("smokematerial", "particles/smokey.vmt")
				antiornade2:SetKeyValue("rendercolor", "20 20 20" )
				antiornade2:SetKeyValue("targetname","antiornade2")
				antiornade2:SetKeyValue("basespread","300")
				antiornade2:SetKeyValue("spreadspeed","300")
				antiornade2:SetKeyValue("speed","500")
				antiornade2:SetKeyValue("startsize","50")
				antiornade2:SetKeyValue("endzide","100")
				antiornade2:SetKeyValue("rate","400")
				antiornade2:SetKeyValue("jetlength","200")
				antiornade2:SetKeyValue("twist","600")
				antiornade2:SetPos(pos)
				antiornade2:SetParent(self.Owner)
				antiornade2:Spawn()
				antiornade2:Fire("turnon","",0.1)
				antiornade2:Fire("Kill","",1.2)

			end
		end

		timer.Simple(1.4, function()
			if IsValid(self) and self:GetOwner():Alive() then
				self:SetHoldType("rollsword")
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				config.canSwitch = true
			end
		end)

		timer.Simple(1.4, function()
			config.canSwitch = true
		end)

		self.CooldownDelay3 = CurTime() + self.Cooldown3
		self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown3 .."s de cooldown pour la tornade !" )
	end
	end
	return true
end

function SWEP:TornadeAttackReset()
	self.Spinning = 0
	if SERVER then
	end
end

function SWEP:TornadeAttackReset2()
	self.ReloadRate = 1
end

/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:ZoneAttack()
	if SERVER then
		if IsValid(self) and self:GetOwner():Alive() then
			if self.NextAction > CurTime() then return end
			if self.CooldownDelay4 < CurTime() then if !SERVER then return end
				config.canSwitch = false
				self.Weapon:EmitSound(Ready, 50, 100)
				self:SetHoldType("leap") 
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				util.ScreenShake( self.Owner:GetPos(), 5, 5, 0.3, 300 )
				self.Weapon:SetNextPrimaryFire(CurTime() + 3)
				self.Weapon:SetNextSecondaryFire(CurTime() + 3)	
					zoneSlash = ents.Create("prop_dynamic")
						zoneSlash:SetModel("models/hunter/misc/shell2x2a.mdl")
						zoneSlash:PhysicsInit( SOLID_NONE )
						zoneSlash:SetMoveType( MOVETYPE_NONE )
						zoneSlash:SetSolid( SOLID_NONE ) 
						zoneSlash:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash:SetMaterial( "models/shiny" )
						zoneSlash:SetModelScale( 15,0.2,1 )
						zoneSlash:SetPos(self.Owner:GetPos() )
						zoneSlash:SetLocalAngles(Angle(0,0,0))
						zoneSlash:Spawn()			
						zoneSlash:SetRenderMode( RENDERMODE_TRANSALPHA )
						SafeRemoveEntityDelayed( zoneSlash, 2 )
					zoneSlash2 = ents.Create("prop_dynamic")
						zoneSlash2:SetModel("models/hunter/tubes/circle2x2.mdl")
						zoneSlash2:PhysicsInit( SOLID_NONE )
						zoneSlash2:SetMoveType( MOVETYPE_NONE )
						zoneSlash2:SetSolid( SOLID_NONE ) 
						zoneSlash2:SetColor( Color( 255, 60, 60, 255 ) )
						zoneSlash2:SetMaterial( "models/props_combine/portalball001_sheet" )
						zoneSlash2:SetModelScale( 20,0.2,1 )
						zoneSlash2:SetPos(self.Owner:GetPos() + Vector( 0, 0, -30 ))
						zoneSlash2:SetLocalAngles(Angle(0,0,0))
						zoneSlash2:Spawn()			
						zoneSlash2:SetRenderMode( RENDERMODE_TRANSALPHA )
						SafeRemoveEntityDelayed( zoneSlash2, 2 )
			timer.Simple(0.2, function()	
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash:Remove() 
					zoneSlash3 = ents.Create("prop_dynamic")
						zoneSlash3:SetModel("models/3dsky/moving_clouds_01a.mdl")
						zoneSlash3:PhysicsInit( SOLID_NONE )
						zoneSlash3:SetMoveType( MOVETYPE_NONE )
						zoneSlash3:SetSolid( SOLID_NONE ) 
						zoneSlash3:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash3:SetModelScale( 0.35,0 )
						zoneSlash3:SetPos(self.Owner:GetPos() )
						zoneSlash3:SetLocalAngles(Angle(0,0,0))
						zoneSlash3:Spawn()			
						zoneSlash3:SetRenderMode( RENDERMODE_TRANSALPHA )
						SafeRemoveEntityDelayed( zoneSlash3, 2 )
				end
			end)
			timer.Simple( 0.7, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash3:Remove()
					zoneSlash4 = ents.Create("prop_dynamic")
						zoneSlash4:SetModel("models/3dsky/r_skyfog.mdl")
						zoneSlash4:PhysicsInit( SOLID_NONE )
						zoneSlash4:SetMoveType( MOVETYPE_NONE )
						zoneSlash4:SetSolid( SOLID_NONE ) 
						zoneSlash4:SetPos(self.Owner:GetPos() )
						zoneSlash4:SetLocalAngles(Angle(0,0,0))
						zoneSlash4:SetModelScale( 0.45,0 )
						zoneSlash4:SetColor( Color( 255, 255, 255, 100 ) )
						zoneSlash4:Spawn()			
						zoneSlash4:SetRenderMode( RENDERMODE_TRANSALPHA )
						SafeRemoveEntityDelayed( zoneSlash4, 2 )
				end
						
			end)
			timer.Simple(0.7,function()
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:EmitSound(SwordTrail, 50, 100)
					self:SetHoldType("leapattack") 
					self.Owner:SetAnimation( PLAYER_ATTACK1 )
					timer.Create("zonedmg"..self:EntIndex(),0.03,11,function()
						if IsValid(self) and self:GetOwner():Alive() then
							for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(),500)) do
								if IsValid(v) and v != self.Owner then
									local dmginfo = DamageInfo()
									dmginfo:SetDamageType( DMG_GENERIC  )
									dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
									dmginfo:SetDamagePosition( self.Owner:GetPos() )
									dmginfo:SetAttacker( self.Owner )
									dmginfo:SetInflictor( self.Owner )
									v:TakeDamageInfo(dmginfo)
								end
							end
						end
					end)
				end
			end)
			timer.Simple( 0.71, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash5 = ents.Create("prop_dynamic")
						zoneSlash5:SetModel("models/dmc5/cut1.mdl")
						zoneSlash5:PhysicsInit( SOLID_NONE )
						zoneSlash5:SetMoveType( MOVETYPE_NONE )
						zoneSlash5:SetSolid( SOLID_NONE ) 
						zoneSlash5:SetPos(self.Owner:GetPos() )
						zoneSlash5:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash5:SetLocalAngles(Angle(0,0,0))
						zoneSlash5:SetModelScale( 0.5,0 )
						zoneSlash5:Spawn()			
						zoneSlash5:SetRenderMode( RENDERMODE_TRANSALPHA )
						SafeRemoveEntityDelayed( zoneSlash5, 2 )
				end
			end)
			timer.Simple( 0.74, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash6 = ents.Create("prop_dynamic")
						zoneSlash6:SetModel("models/dmc5/cut2.mdl")
						zoneSlash6:PhysicsInit( SOLID_NONE )
						zoneSlash6:SetMoveType( MOVETYPE_NONE )
						zoneSlash6:SetSolid( SOLID_NONE ) 
						zoneSlash6:SetPos(self.Owner:GetPos() )
						zoneSlash6:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash6:SetLocalAngles(Angle(0,0,0))
						zoneSlash6:SetModelScale( 0.5,0 )
						zoneSlash6:Spawn()			
						zoneSlash6:SetRenderMode( RENDERMODE_TRANSALPHA )
						zoneSlash4:SetColor( Color( 255, 255, 255, 250 ) )
						SafeRemoveEntityDelayed( zoneSlash6, 2 )
				end
			end)
			timer.Simple( 0.77, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash7 = ents.Create("prop_dynamic")
						zoneSlash7:SetModel("models/dmc5/cut3.mdl")
						zoneSlash7:PhysicsInit( SOLID_NONE )
						zoneSlash7:SetMoveType( MOVETYPE_NONE )
						zoneSlash7:SetSolid( SOLID_NONE ) 
						zoneSlash7:SetPos(self.Owner:GetPos() )
						zoneSlash7:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash7:SetLocalAngles(Angle(0,0,0))
						zoneSlash7:SetModelScale( 0.5,0 )
						zoneSlash7:Spawn()			
						zoneSlash7:SetRenderMode( RENDERMODE_TRANSALPHA ) 
						zoneSlash2:SetColor( Color( 200, 60, 60, 200 ) )
						SafeRemoveEntityDelayed( zoneSlash7, 2 )
				end
			end)
			timer.Simple( 0.80, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash8 = ents.Create("prop_dynamic")
						zoneSlash8:SetModel("models/dmc5/cut4.mdl")
						zoneSlash8:PhysicsInit( SOLID_NONE )
						zoneSlash8:SetMoveType( MOVETYPE_NONE )
						zoneSlash8:SetSolid( SOLID_NONE ) 
						zoneSlash8:SetPos(self.Owner:GetPos() )
						zoneSlash8:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash8:SetLocalAngles(Angle(0,0,0))
						zoneSlash8:SetModelScale( 0.5,0 )
						zoneSlash8:Spawn()			
						zoneSlash8:SetRenderMode( RENDERMODE_TRANSALPHA )
						zoneSlash2:SetColor( Color( 200, 60, 60, 150 ) )
						SafeRemoveEntityDelayed( zoneSlash8, 2 )
				end
			end)
			timer.Simple( 0.83, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash9 = ents.Create("prop_dynamic")
						zoneSlash9:SetModel("models/dmc5/cut5.mdl")
						zoneSlash9:PhysicsInit( SOLID_NONE )
						zoneSlash9:SetMoveType( MOVETYPE_NONE )
						zoneSlash9:SetSolid( SOLID_NONE ) 
						zoneSlash9:SetPos(self.Owner:GetPos() )
						zoneSlash9:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash9:SetLocalAngles(Angle(0,0,0))
						zoneSlash9:SetModelScale( 0.5,0 )
						zoneSlash9:Spawn()			
						zoneSlash9:SetRenderMode( RENDERMODE_TRANSALPHA ) 
						zoneSlash2:SetColor( Color( 200, 60, 60, 100 ) )
						SafeRemoveEntityDelayed( zoneSlash9, 2 )
				end
			end)
			timer.Simple( 0.86, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash10 = ents.Create("prop_dynamic")
						zoneSlash10:SetModel("models/dmc5/cut6.mdl")
						zoneSlash10:PhysicsInit( SOLID_NONE )
						zoneSlash10:SetMoveType( MOVETYPE_NONE )
						zoneSlash10:SetSolid( SOLID_NONE ) 
						zoneSlash10:SetPos(self.Owner:GetPos() )
						zoneSlash10:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash10:SetLocalAngles(Angle(0,0,0))
						zoneSlash10:SetModelScale( 0.5,0 )
						zoneSlash10:Spawn()			
						zoneSlash10:SetRenderMode( RENDERMODE_TRANSALPHA )
						zoneSlash2:SetColor( Color( 200, 60, 60, 50 ) )
						SafeRemoveEntityDelayed( zoneSlash10, 2 )
				end
			end)
			timer.Simple( 0.89, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash11 = ents.Create("prop_dynamic")
						zoneSlash11:SetModel("models/dmc5/cut7.mdl")
						zoneSlash11:PhysicsInit( SOLID_NONE )
						zoneSlash11:SetMoveType( MOVETYPE_NONE )
						zoneSlash11:SetSolid( SOLID_NONE ) 
						zoneSlash11:SetPos(self.Owner:GetPos() )
						zoneSlash11:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash11:SetLocalAngles(Angle(0,0,0))
						zoneSlash11:SetModelScale( 0.5,0 )
						zoneSlash11:Spawn()			
						zoneSlash11:SetRenderMode( RENDERMODE_TRANSALPHA )
						zoneSlash2:Remove()
						SafeRemoveEntityDelayed( zoneSlash11, 2 )
				end
			end)
			timer.Simple( 0.91, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash12 = ents.Create("prop_dynamic")
						zoneSlash12:SetModel("models/dmc5/cut8.mdl")
						zoneSlash12:PhysicsInit( SOLID_NONE )
						zoneSlash12:SetMoveType( MOVETYPE_NONE )
						zoneSlash12:SetSolid( SOLID_NONE ) 
						zoneSlash12:SetPos(self.Owner:GetPos() )
						zoneSlash12:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash12:SetLocalAngles(Angle(0,0,0))
						zoneSlash12:SetModelScale( 0.5,0 )
						zoneSlash12:Spawn()			
						zoneSlash12:SetRenderMode( RENDERMODE_TRANSALPHA )
						SafeRemoveEntityDelayed( zoneSlash12, 2 )
				end
			end)
			timer.Simple( 0.94, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash13 = ents.Create("prop_dynamic")
						zoneSlash13:SetModel("models/dmc5/cut9.mdl")
						zoneSlash13:PhysicsInit( SOLID_NONE )
						zoneSlash13:SetMoveType( MOVETYPE_NONE )
						zoneSlash13:SetSolid( SOLID_NONE ) 
						zoneSlash13:SetPos(self.Owner:GetPos() )
						zoneSlash13:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash13:SetLocalAngles(Angle(0,0,0))
						zoneSlash13:SetModelScale( 0.5,0 )
						zoneSlash13:Spawn()			
						zoneSlash13:SetRenderMode( RENDERMODE_TRANSALPHA )
						zoneSlash4:SetColor( Color( 255, 255, 255, 200 ) )
						SafeRemoveEntityDelayed( zoneSlash13, 2 )
				end
			end)
			timer.Simple( 0.97, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash14 = ents.Create("prop_dynamic")
						zoneSlash14:SetModel("models/dmc5/cut10.mdl")
						zoneSlash14:PhysicsInit( SOLID_NONE )
						zoneSlash14:SetMoveType( MOVETYPE_NONE )
						zoneSlash14:SetSolid( SOLID_NONE ) 
						zoneSlash14:SetPos(self.Owner:GetPos() )
						zoneSlash14:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash14:SetLocalAngles(Angle(0,0,0))
						zoneSlash14:SetModelScale( 0.5,0 )
						zoneSlash14:Spawn()			
						zoneSlash14:SetRenderMode( RENDERMODE_TRANSALPHA )
						zoneSlash4:SetColor( Color( 255, 255, 255, 150 ) )
						SafeRemoveEntityDelayed( zoneSlash14, 2 )
				end
			end)
			timer.Simple( 1, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
					zoneSlash15 = ents.Create("prop_dynamic")
						zoneSlash15:SetModel("models/dmc5/cut11.mdl")
						zoneSlash15:PhysicsInit( SOLID_NONE )
						zoneSlash15:SetMoveType( MOVETYPE_NONE )
						zoneSlash15:SetSolid( SOLID_NONE ) 
						zoneSlash15:SetPos(self.Owner:GetPos() )
						zoneSlash15:SetColor( Color( 255, 70, 70, 200 ) )
						zoneSlash15:SetLocalAngles(Angle(0,0,0))
						zoneSlash15:SetModelScale( 0.5,0 )
						zoneSlash15:Spawn()			
						zoneSlash15:SetRenderMode( RENDERMODE_TRANSALPHA )
						zoneSlash4:SetColor( Color( 255, 255, 255, 100 ) )
						SafeRemoveEntityDelayed( zoneSlash15, 2 )
				end
			end)
			timer.Simple( 1.03, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
						zoneSlash4:SetColor( Color( 255, 255, 255, 50 ) )
				end
			end)
			timer.Simple(1.03, function()
				if IsValid(self) and self:GetOwner():Alive() then
					util.ScreenShake( self.Owner:GetPos(), 50, 5, 0.3, 3000 )
				end
			end)
			timer.Simple( 1.06, function()if IsValid(self) and self:GetOwner():Alive() then end	end)
			timer.Simple( 1.09, function()if IsValid(self) and self:GetOwner():Alive() then end	end)
			timer.Simple( 1.11, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash5:SetColor( Color( 255, 70, 70, 100 ) )  
				end
			end)
			timer.Simple( 1.14, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash6:SetColor( Color( 255, 70, 70, 100 ) )
				end
			end)
			timer.Simple( 1.17, function()
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash7:SetColor( Color( 255, 70, 70, 100 ) )	
				end
			end)
			timer.Simple( 1.20, function()
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash8:SetColor( Color( 255, 70, 70, 100 ) )	
				end
			end)
			timer.Simple( 1.23, function()	
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash9:SetColor( Color( 255, 70, 70, 100 ) )
				end	
			end)
			timer.Simple( 1.26, function()
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash10:SetColor( Color( 255, 70, 70, 100 ) )	
				end
			end)
			timer.Simple( 1.29,function() 
				if IsValid(self) and self:GetOwner():Alive() then 
					zoneSlash11:SetColor( Color( 255, 70, 70, 100 ) )	
				end	
			end)
			timer.Simple( 1.32,function() 
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash12:SetColor( Color( 255, 70, 70, 100 ) )	
				end
			end)
			timer.Simple( 1.35,function() 
				if IsValid(self) and self:GetOwner():Alive() then 
					zoneSlash13:SetColor( Color( 255, 70, 70, 100 ) )
				end
			end)
			timer.Simple( 1.38,function()
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash14:SetColor( Color( 255, 70, 70, 100 ) )
				end
			end)
			timer.Simple( 1.41,function()
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash15:SetColor( Color( 255, 70, 70, 100 ) )
				end
			end)
			timer.Simple( 1.6, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self:SetHoldType("rollsword") self.Owner:SetAnimation( PLAYER_ATTACK1 ) 
				end
			end)
			timer.Simple( 1.6,function() 
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash4:Remove() 
				end
			end)
			timer.Simple( 1.9,function() 
				if IsValid(self) and self:GetOwner():Alive() then
					zoneSlash5:Remove()zoneSlash6:Remove()zoneSlash7:Remove()zoneSlash8:Remove()zoneSlash9:Remove()zoneSlash10:Remove()
					zoneSlash11:Remove()zoneSlash12:Remove()zoneSlash13:Remove()zoneSlash14:Remove()zoneSlash15:Remove()
					config.canSwitch = true
				end
			end)
			timer.Simple( 1.9,function()
				if IsValid(self) and self:GetOwner():Alive() then
				end
			end)
			timer.Simple(1.9, function()
				config.canSwitch = true
			end)
			self.CooldownDelay4 = CurTime() + self.Cooldown4
			self.NextAction = CurTime() + self.ActionDelay
		else		
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown4 .."s de cooldown pour l'attaque de zone !" )
		end
		end
	end
end

/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	if (IsValid(self) && self:GetOwner():Alive()) then
		if SERVER then 
			self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav", 256, 75)
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end
	end
	return true
end

/*---------------------------------------------------------
	Holster
---------------------------------------------------------*/
function SWEP:Holster()
	if SERVER then
		if config.canSwitch == true then
			if (IsValid(self) && self:GetOwner():Alive()) then
				self.Owner:GodDisable()
			elseif (IsValid(self) && !self:GetOwner():Alive()) then
				self.Owner:GodDisable()
			end
			return true
		else
			if (IsValid(self) && !self:GetOwner():Alive()) then
				self.Owner:GodDisable()
				config.canSwitch = true
			end
			return false
		end
		config.canSwitch = true
		self.Owner:GodDisable()
	end
end

/*---------------------------------------------------------
	OnDrop
---------------------------------------------------------*/
function SWEP:OnDrop()
	return false
end

/*---------------------------------------------------------
	Draw HUD
---------------------------------------------------------*/
function SWEP:DrawHUD()
 
	local ScrW = ScrW()
	local ScrH = ScrH()
	
	local color = Color(210,30,0)

	local icon = 60
	local icongap = 2
	local gap = 5
 
	local bar = 4
	
	local powername = 16
	
	local Font = "Trebuchet18"

	if ( ESPSelectPower ) then
		icon = 128
		icongap = 4
		bar = 8
		bar2 = 24
		powername = 20
		Font = "Trebuchet24"
	end
	
	local FrameW = gap + ( ( icon + gap ) * 4 )
	local FrameH = (gap*3) + icon
	
	local FrameWPos = ScrW/2 - (FrameW/2)
	local FrameHPos = ScrH - ( FrameH + gap )
	
	draw.RoundedBox( 0, FrameWPos, FrameHPos, FrameW, FrameH, Color( 20,20,20, 100 ) )
	
	---- power icon
	 
	local iconWPos = FrameWPos + gap
	local iconslot = 1
	local SelectedPower = self:GetAntiMagie4()
	local IconCaseColor = Color(20,20,20, 150 )
	
	
	for id, t in pairs( AntiMagie4 ) do
		IconCaseColor = Color(20,20,20, 150 )
		if SelectedPower == iconslot then
			IconCaseColor = color
			draw.RoundedBox( 0, ScrW/2 - (icon + gap/2 ), FrameHPos - ( gap + powername ), (icon*2) + gap, powername, Color(20,20,20, 150 ) )
			draw.SimpleText( t.name, Font, ScrW/2 , FrameHPos - ( gap + powername/2 ), Color( 255, 255, 255, 255), 1, 1 )
		end
		
		draw.RoundedBox( 0, iconWPos, FrameHPos + gap, icon, icon, IconCaseColor )
		if (ESPSelectPower) then
			local TextColor = Color(255,255,255,255)
			if iconslot == 2 and self:GetZone() then
				TextColor = Color(50,255,50,255)
			elseif iconslot == 1 and self:GetBarrier() then
				TextColor = Color(50,255,50,255)
			end
			draw.SimpleText( iconslot, Font, iconWPos + icongap, FrameHPos + gap + icongap, TextColor, 0, 3 )
		end
		
		surface.SetMaterial( t.material )
		surface.SetDrawColor( Color(255,255,255) )

		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
			surface.DrawTexturedRect( iconWPos + icongap, FrameHPos + gap + icongap , icon - (icongap * 2), icon - (icongap * 2) )
		render.PopFilterMag()
		render.PopFilterMin()
		
		iconWPos = iconWPos + icon + gap
		iconslot = iconslot + 1
	end
end

/*---------------------------------------------------------
	Hook et Bouton
---------------------------------------------------------*/

function SWEP:CalcView( ply, pos, angles, fov )
	if not IsValid( ply ) or ply:GetViewEntity() ~= ply or not ply:Alive() then return end

	ply._lscsCalcViewTime = CurTime() + 0.1 -- this is used to detect if its broken
  
	return ply:lscsGetViewOrigin(), ply:EyeAngles(), fov
end

hook.Add( "ShouldDrawLocalPlayer", "AntiMagieThirdPDraw5", function (ply)
	if ply:GetActiveWeapon():IsValid() then
		if ply:IsPlayer() && ply:Alive() && ply:GetActiveWeapon():GetClass() == "antimagie5" then
			return true
		end
	end
end)



hook.Add("PlayerButtonDown", "AntiMagie4binds", function( ply, button )
	if config.canSwitch == true then if !SERVER then return end
	if button == ply:GetInfoNum( "TouchesBind1", 15) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "antimagie5" then
					ply:GetActiveWeapon():SetAntiMagie4(1)
			end
		end
	elseif button == ply:GetInfoNum( "TouchesBind2", 28) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "antimagie5" then
					ply:GetActiveWeapon():SetAntiMagie4(2)
			end
		end
	elseif button == ply:GetInfoNum( "TouchesBind3", 15) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "antimagie5" then
					ply:GetActiveWeapon():SetAntiMagie4(3)
			end
		end
	elseif button == ply:GetInfoNum( "TouchesBind4", 28) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "antimagie5" then
					ply:GetActiveWeapon():SetAntiMagie4(4)
			end
		end
	end
	end
end)

/*---------------------------------------------------------
	ent et effect
---------------------------------------------------------*/

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "slash2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/slash/slash.mdl" )
		self:SetMaterial("models/shadertest/shader4")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetAngles(Angle(0,own:EyeAngles().Yaw + 90,0))
		self:SetModelScale( 4, 0 )
		self:ManipulateBoneScale(self:EntIndex(),Vector(10,10,10))
		self:SetSolid( SOLID_NONE ) self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 180,20,20,230 ) )
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 1 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*3000 ) 
		end 
		local own = self:GetOwner()
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,250)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmgslh1,config.dmgslh2) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
				self:EmitSound( Hitground2 )
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  
	end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "slash2_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "slash3" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "shield3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		local own = self.Owner
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/tubes/tube4x4x3b.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:PhysicsInit(SOLID_NONE)
		self:SetTrigger( true )
		self:SetAngles(Angle(0,own:EyeAngles().y + 125,0))
		self:SetMaterial( "models/shadertest/shader4" ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmpShield )
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "shield3_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "shield3" )
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = CurTime()
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
		ent.RenderOverride = function( ent )
			render.SuppressEngineLighting( true ) ent:DrawModel() render.SuppressEngineLighting( false )
		end
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.03
				for i=1, 3 do
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter()  + Vector(math.random(-50,50),math.random(-50,50),0) )
					if particle then  local size = math.Rand( 2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.3, 0.5 ) )
						particle:SetStartAlpha( 160 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 230, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 20 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter()  + Vector(math.random(-50,50),math.random(-50,50),0) )
					if particle then  local size = math.Rand( 2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.3, 0.5 ) )
						particle:SetStartAlpha( 160 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 20, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 20 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "slash3_effect" )
end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = CurTime()
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
		ent.RenderOverride = function( ent )
			render.SuppressEngineLighting( true ) ent:DrawModel() render.SuppressEngineLighting( false )
		end
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 3 do
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-50,50)) )
					if particle then  local size = math.Rand(2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.2, 0.3 ) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 230, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-50,50)) )
					if particle then  local size = math.Rand(2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.2, 0.3 ) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 20, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "shield3_effect" )
end