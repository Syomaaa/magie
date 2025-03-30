AddCSLuaFile()

SWEP.PrintName 		      = "Ombre 3" 
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

SWEP.Category             = "Ombre"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 1

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 70
config.dmg2 = 70

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

		local f = Angle(0,self.Owner:GetAngles().y,0):Forward()
		local r = Angle(0,self.Owner:GetAngles().y,0):Right()
		local l = -Angle(0,self.Owner:GetAngles().y,0):Right()

		local ent = ents.Create("ombre3")
		ent:SetPos(self.Owner:GetPos()+f*50)
		ent:SetOwner(self.Owner)
		ent:Spawn()

		local ent1 = ents.Create("ombre3")
		ent1:SetPos(self.Owner:GetPos()+f*50)
		ent1:SetOwner(self.Owner)
		ent1:Spawn()

		local ent2 = ents.Create("ombre3")
		ent2:SetPos(self.Owner:GetPos()+f*50)
		ent2:SetOwner(self.Owner)
		ent2:Spawn()

		util.ScreenShake(self.Owner:GetPos(), 8, 0.5, 2, 500)

		timer.Create("ombre3"..ent:EntIndex(), 0.01, 200, function ()
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

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	return true
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "ombre3"
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
			par:SetKeyValue( "effect_name", "[3]_dark_tornado_ground_add" )
			par:SetKeyValue( "start_active", "1" )
			par:SetParent(self)
			par:SetPos( self:GetPos() ) 
			par:SetAngles( self:GetAngles() )
			par:Spawn() 
			par:Activate() 

			local par2 = ents.Create( "info_particle_system" ) 
			par2:SetKeyValue( "effect_name", "[3]_dark_tornado_ground_trail" )
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

						local prop = ents.Create("ombre3_1")
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
	scripted_ents.Register( ENT, "ombre3" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "ombre3_1"
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
		self:SetModelScale(15,0)
		self:SetMaterial( "poke/props/plainshiny" )
		self:GetPhysicsObject():EnableGravity( false )

		local par = ents.Create( "info_particle_system" ) 
			par:SetKeyValue( "effect_name", "[3]_dark_tornado_ground" )
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
	scripted_ents.Register( ENT, "ombre3_1" )
end