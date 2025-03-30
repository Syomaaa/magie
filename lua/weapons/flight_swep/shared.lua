if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
	SWEP.HoldType			= "fist"
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "Vent 2" 
	SWEP.Author				= "Ali" 
	SWEP.Purpose		= "flight and entertainment and learning lua"
	SWEP.Instructions	= "Primary = Flight mode | Secondary = end"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 3
	

	SWEP.WepSelectIcon		= surface.GetTextureID( "weapons/swep" )
	
end


SWEP.DrawCrosshair      = false
--SWEP.Base				= "weapon_cs_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Category = "Vent"

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFlip		= true
SWEP.DrawAmmo = false
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Delay			= 0.9 	--In seconds
SWEP.Primary.Recoil			= 0		--Gun Kick
SWEP.Primary.NumShots		= 1		--Number of shots per one fire
SWEP.Primary.ClipSize		= 1000 --Use "-1 if there are no clips"
SWEP.Primary.DefaultClip	= 1000	--Number of shots in next clip
SWEP.Primary.Automatic   	= false	--Pistol fire (false) or SMG fire (true)
SWEP.Primary.Ammo         	= "pistol"	--Ammo Type

SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "pistol"

local config = {}

SWEP.Cooldown = 1
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 45
config.dmg2 = 45
config.zone = 200

function SWEP:Initialize()

self.IsJumping = 0
self.NextJumpTime = 0
util.PrecacheSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")
util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")

end


function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() or self.IsJumping == 1 ) then
		return
	end
	
	if self.IsJumping == 0 then
	
		self.IsJumping = 1
		
		self.Owner:SetMoveType( 4 )
			
		self.NextJumpTime = CurTime() + math.random( 3, 4 )
		self.Owner:SetMaxSpeed( 1500 )

		self.Owner:ConCommand("pp_dof_initlength 9")
		self.Owner:ConCommand("pp_dof_spacing 8")

	end
	
	// Play shoot sound
	self.Owner:EmitSound(Sound("player/suit_sprint.wav"))
	self.Weapon:EmitSound("ambient/wind/wind_hit2.wav", 100, 60)
end

function SWEP:SecondaryAttack()

local trace = self.Owner:GetEyeTrace()

	if self.IsJumping == 1 then

		self.IsJumping = 0 

		self.Owner:ConCommand("pp_dof 0")

		self.Owner:SetVelocity(self.Owner:GetForward() * 200 + Vector(0,0,200))
		self.Owner:SetMoveType( 2 )
		self.Owner:SetMaxSpeed( 200 )
		self.NextJumpTime = CurTime()
		
	end
	
end

function SWEP:Reload()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()

		local f = Angle(0,self.Owner:GetAngles().y,0):Forward()
		local r = Angle(0,self.Owner:GetAngles().y,0):Right()
		local l = -Angle(0,self.Owner:GetAngles().y,0):Right()

		local ent = ents.Create("vent2att")
		ent:SetPos(self.Owner:GetPos()+f*50)
		ent:SetOwner(self.Owner)
		ent:Spawn()

		local ent1 = ents.Create("vent2att")
		ent1:SetPos(self.Owner:GetPos()+f*50)
		ent1:SetOwner(self.Owner)
		ent1:Spawn()

		local ent2 = ents.Create("vent2att")
		ent2:SetPos(self.Owner:GetPos()+f*50)
		ent2:SetOwner(self.Owner)
		ent2:Spawn()

		util.ScreenShake(self.Owner:GetPos(), 8, 0.5, 2, 500)

		timer.Create("vent2att"..ent:EntIndex(), 0.01, 200, function ()
	        if ent:IsValid() and ent1:IsValid() and ent2:IsValid() then
				ent:SetPos(ent:GetPos()+f*85+l*35)
	            ent1:SetPos(ent1:GetPos()+f*50+f*35)
				ent2:SetPos(ent2:GetPos()+f*85+r*35)
	        end
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
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "vent2"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/hunter/misc/sphere2x2.mdl")
			self:PhysicsInit( SOLID_NONE )
			self:SetMoveType( MOVETYPE_NONE )
			self:SetSolid( SOLID_NONE )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
			self:DrawShadow(false)

			local par = ents.Create( "info_particle_system" ) 
			par:SetKeyValue( "effect_name", "[18]_wind_tornado" )
			par:SetKeyValue( "start_active", "1" )
			par:SetParent(self)
			par:SetPos( self:GetPos() ) 
			par:SetAngles( self:GetAngles() )
			par:Spawn() 
			par:Activate() 

			local par2 = ents.Create( "info_particle_system" ) 
			par2:SetKeyValue( "effect_name", "[12]_wind" )
			par2:SetKeyValue( "start_active", "1" )
			par2:SetParent(self)
			par2:SetPos( self:GetPos() ) 
			par2:SetAngles( self:GetAngles() )
			par2:Spawn() 
			par2:Activate() 

			SafeRemoveEntityDelayed(self,5)

			self.cdDelay = 0
			self.cdDelay2 = 0
		end
	end
	function ENT:Think()
		if SERVER then
			if self.cdDelay <= CurTime() then
				for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
					if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
						dmginfo:SetDamagePosition( self:GetPos()  )
						dmginfo:SetAttacker( self.Owner )
						dmginfo:SetInflictor( self.Owner )
						v:TakeDamageInfo(dmginfo)

						local spawnPos = v:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), -50)

						local prop = ents.Create("vent2_1")
						prop:SetPos(spawnPos)
						prop:SetOwner(self)
						prop:Spawn()
					end
				end  
				self.cdDelay = CurTime() + 0.2
			
			end
		end

		self:NextThink(CurTime())
		return true
	end
	function ENT:OnRemove()

	end
	if CLIENT then
		function ENT:Draw()
			self:DrawShadow( false )
		end
	end
	scripted_ents.Register( ENT, "vent2att" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "vent2_1"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/poke/props/pokedarkhand.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor(Color(10,0,30,200))
		self:SetAngles(Angle(0,math.random(0,360),0))
		self:SetModelScale(0,0)
		self:SetMaterial( "poke/props/plainshiny" )
		self:GetPhysicsObject():EnableGravity( false )

		local par = ents.Create( "info_particle_system" ) 
			par:SetKeyValue( "effect_name", "[3]_wind_aura" )
			par:SetKeyValue( "start_active", "1" )
			par:SetParent(self)
			par:SetPos( self:GetPos() ) 
			par:SetAngles( self:GetAngles() )
			par:Spawn() 
			par:Activate() 

		SafeRemoveEntityDelayed( self, 0.5)
		self.touch = true
	end
	function ENT:Think()
		if SERVER then
			self:SetPos(self:GetPos()+Vector(0,0,10))
		end
		
		self:NextThink(CurTime() + 0.05)
		return true
	end
	
	
	function ENT:OnRemove()
		self:StopSound("physics/concrete/concrete_break"..math.random(2,3)..".wav")
		
	end
	
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "vent2_1" )
end

function SWEP:Think()
	
	if self.NextJumpTime == CurTime() then

		self.IsJumping = 0
		
		self.Owner:ConCommand("pp_dof 0")
		self.Owner:SetVelocity(self.Owner:GetForward() * 50 + Vector(0,0,200))
		self.Owner:SetMoveType( 2 )
		self.Owner:SetMaxSpeed( 200 )
		
	end
	
end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	SafeRemoveEntity(self.eff)
	return true
end

function SWEP:Deploy()
	local own = self.Owner
	self.eff = ents.Create( "vent_effect" ) 
	self.eff:SetPos( own:GetPos() ) 
	self.eff:SetParent(own)
	self.eff:Spawn() 
	self.eff:Activate() 
	own:DeleteOnRemove( self.eff )
end