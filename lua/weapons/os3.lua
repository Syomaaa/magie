if SERVER then
    AddCSLuaFile ()
    SWEP.AutoSwitchTo        = true
    SWEP.AutoSwitchFrom        = true
elseif CLIENT then
    SWEP.DrawCrosshair        = true
    SWEP.PrintName            = "Ancien OS 3"
    SWEP.BounceWeaponIcon   = false
end

game.AddParticles( "particles/stalactite.pcf" )

SWEP.Base = "weapon_base"
SWEP.Author          = "Hds46"
SWEP.Contact         = ""
SWEP.Purpose         = ""
SWEP.Instructions    = ""
SWEP.Category        = "Magie"
		
SWEP.Spawnable                = true
SWEP.AdminOnly           = false
SWEP.UseHands = false

SWEP.HoldType             = "melee"
SWEP.ViewModel = "models/weapons/thifax/blc7.mdl"
SWEP.WorldModel = "models/weapons/kerry/w_garrys_pass.mdl"
SWEP.Slot				= 2
SWEP.SlotPos			= 3
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic        = false
SWEP.Primary.Ammo            = "None" 

SWEP.Secondary.ClipSize        = -1 
SWEP.Secondary.DefaultClip    = -1 
SWEP.Secondary.Automatic    = false 
SWEP.Secondary.Ammo            = "none"
SWEP.NextAttackSound = 0
SWEP.NextAttackStop = 0
SWEP.NextUseShield = 0

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

function SWEP:PrimaryAttack()

    if IsValid(self.Owner) && self.Owner:IsOnGround() && !self.ShieldIsValid && self.NextUseShield < CurTime() && SERVER then
        self.Owner.HasShield = true

        local zib = math.random(250,500)
        local mana = self.Owner:GetNWInt("BCMana")
        self.Owner:SetNWInt("BCMana", mana - zib)

        local pos_tab = {
        Vector(300,60,-30),
        Vector(300,180,-30),
        Vector(300,250,-30),
        Vector(300,200,-30),
        Vector(-300,70,-30),
        Vector(-300,-190,-30),
        Vector(-300,-250,-30),
        Vector(-300,-200,-30)
        }
        local pos_ang = {
        Angle(0,0,0),
        Angle(0,40,0),
        Angle(0,90,0),
        Angle(0,130,0),
        Angle(0,170,0),
        Angle(0,230,0),
        Angle(0,270,0),
        Angle(0,310,0)
        }
        for i=1,8 do
            local spike = ents.Create("prop_physics")
            spike:SetModel("models/naruto modelpack/models/bones/bones.mdl")
            spike:SetPos(self.Owner:GetPos() + pos_tab[i] - Vector(80,0,0))
            spike:SetAngles(pos_ang[i])
            spike:Spawn()
            spike.IsEarthMagicProp = true
            spike.IsShield = true
            spike.Owner = self.Owner
            undo.AddEntity( spike )
            spike.RockOwner = self.Owner
            spike:GetPhysicsObject():EnableMotion(false)
            local plyang = self.Owner:GetAngles()
            plyang.pitch = -90
            plyang.roll = plyang.roll
            plyang.yaw = plyang.yaw
            local DustAngle = plyang
            local BigDust = EffectData()
            BigDust:SetOrigin(spike:GetPos() + Vector(0,0,45))
            BigDust:SetNormal(DustAngle:Forward())
            BigDust:SetScale(400)
            util.Effect("ThumperDust",BigDust)
            timer.Create("spike_up_shield" .. spike:EntIndex(),0.01,10,function()
                if IsValid(spike) then
                    spike:SetPos(spike:GetPos() + Vector(0,0,3))
                end
            end)
			timer.Simple(1,function()
				self.Owner.HasShield = false
				self.ShieldIsValid = false
				self.NextUseShield = CurTime() + self.Cooldown
				for k,v in pairs(ents.FindByClass("prop_physics")) do
					if IsValid(v) and v.IsShield and v.Owner == self.Owner then
						timer.Create("spike_down" .. v:EntIndex(),0.0000001,30,function()
							if IsValid(v) then
								v:SetPos(v:GetPos() - Vector(0,0,6.2))
							end
						end)
						timer.Create("spike_down_finish" .. v:EntIndex(),0.5,1,function()
							if IsValid(v) then
								v:Remove()
							end
						end)
					end
				end
			end)
        end
        for k,v in pairs(ents.FindInSphere(self.Owner:GetPos(),500)) do
            if IsValid(v) and v != self.Owner then
                local dmginfo = DamageInfo()
                dmginfo:SetDamageType( DMG_GENERIC  )
                dmginfo:SetDamage( 500 )
                dmginfo:SetDamagePosition( self.Owner:GetPos() )
                dmginfo:SetAttacker( self.Owner )
                dmginfo:SetInflictor( self )
                v:TakeDamageInfo(dmginfo)
            end
        end
    self.ShieldIsValid = true
    elseif self.Owner:KeyDown(IN_ATTACK) && self.NextUseShield > CurTime() then
        self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
    end
	return true
end


function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
        if CLIENT then	
		self.Owl = table.FullCopy( self.Owl )
		self:CreateModels( self.Owl )
	end
	self:SetupValue()
end

function SWEP:Equip()
end

function SWEP:Holster()
if SERVER then
self.Owner:SetCanZoom( true )
end
return true
end

function SWEP:OnRemove()
if SERVER then
self.Owner:SetCanZoom( true )
self.Owner.HasShield = false
self.ShieldIsValid = false
self.NextUseShield = CurTime() + 1
for k,v in pairs(ents.FindByClass("prop_physics")) do
if IsValid(v) and v.IsShield and v.Owner == self.Owner then
v:Remove()
end
end
end
end

function SWEP:OnDrop()
if SERVER then
self.Owner:SetCanZoom( true )
self.Owner.HasShield = false
self.ShieldIsValid = false
self.NextUseShield = CurTime() + 1
for k,v in pairs(ents.FindByClass("prop_physics")) do
if IsValid(v) and v.IsShield and v.Owner == self.Owner then
v:Remove()
end
end
end
end

if CLIENT then
function SWEP:ViewModelDrawn()
	local vm = self.Owner:GetViewModel()
	if !IsValid(vm) then return end
		local bone = vm:LookupBone("PBase")
		if (!bone) then return end
		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = vm:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		else
			return
		end
			ang:RotateAroundAxis(ang:Forward(),0)
			ang:RotateAroundAxis(ang:Right(), -130)
			ang:RotateAroundAxis(ang:Up(), 93)
end
end

function SWEP:Deploy()
   self.Owner:DrawViewModel(false)
   if SERVER then
   self.Owner:SetCanZoom( false )
   end
end


hook.Add("EntityTakeDamage" , "StopBlastDamageShield" , function(target, dmginfo)
        if shield then return end
        shield = true
        if IsValid(target) and target.HasShield then
		if dmginfo:IsDamageType(DMG_BLAST) then
		dmginfo:SetDamage(0)
		target:TakeDamageInfo(dmginfo)
		end
        end
		shield = false
end)

if CLIENT then	
	SWEP.Owl = {
		["owl"] = { type = "Model", model = "models/thifax/blc7.mdl", bone = "ValveBiped.Bip01_Spine2", rel = "", pos = Vector(6, -30, -1), angle = Angle(180, -90, 90), size = Vector(0.699, 0.699, 0.699), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["info_owl"] = { type = "Quad", bone = "ValveBiped.Bip01_Spine2", rel = "owl", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = 0.5}
	}
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.Owl) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Quad") then
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
		
			local v = self.Owl[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.Owl, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.Owl, v, bone_ent, "ValveBiped.Bip01_Spine2" )
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
				

			end
			
		end
		
	end
	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
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
		
		end
		
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
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
			end
		end		
	end
	
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

function SWEP:SetupValue()
	if not IsValid(self.Owner) then return end
	if not self.Owner:IsBot() then
	end
	self.mat_ply = Material("spawnicons/" .. string.gsub(self.Owner:GetModel(), ".mdl", ".png"))
end