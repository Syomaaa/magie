AddCSLuaFile()

SWEP.PrintName 		      = "Corruption 4" 
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

SWEP.Category             = "Corruption"

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
config.dmg1 = 85
config.dmg2 = 85
config.zone = 200

config.intervalDmgPoi = 0.5 -- interval entre chaque dgt poison
config.dmgPoi1 = 5 -- dgt poison entre .. et ..
config.dmgPoi2 = 5
config.nb = 5 -- nb de fois de dgt
config.interval = 0.1 -- interval entre chaque dgt

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
   
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

local function PoisonDmg(ent, num, attacker)
    local timerName = "DMGPOISON" .. ent:EntIndex()
    
    if not timer.Exists(timerName) then
        timer.Create(timerName, config.intervalDmgPoi, num, function()
            if IsValid(ent) then
                ent:TakeDamage(math.random(config.dmgPoi1, config.dmgPoi2), attacker, DMG_ACID)
            else
                timer.Remove(timerName)
            end
        end)
    end
end


function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()

		local f = Angle(0,self.Owner:GetAngles().y,0):Forward()
		local r = Angle(0,self.Owner:GetAngles().y,0):Right()
		local l = -Angle(0,self.Owner:GetAngles().y,0):Right()

		local entcor = ents.Create("corruption4")
		entcor:SetPos(self.Owner:GetPos()+f*50)
		entcor:SetOwner(self.Owner)
		entcor:Spawn()

		local entcor1 = ents.Create("corruption4")
		entcor1:SetPos(self.Owner:GetPos()+f*50)
		entcor1:SetOwner(self.Owner)
		entcor1:Spawn()

		local entcor2 = ents.Create("corruption4")
		entcor2:SetPos(self.Owner:GetPos()+f*50)
		entcor2:SetOwner(self.Owner)
		entcor2:Spawn()

		util.ScreenShake(self.Owner:GetPos(), 8, 0.5, 2, 500)

		timer.Create("corruption4"..entcor:EntIndex(), 0.01, 200, function ()
	        if entcor:IsValid() and entcor1:IsValid() and entcor2:IsValid() then
				entcor:SetPos(entcor:GetPos()+f*85+l*35)
	            entcor1:SetPos(entcor1:GetPos()+f*50+f*35)
				entcor2:SetPos(entcor2:GetPos()+f*85+r*35)
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
	ENT.PrintName = "corruption4"
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
			par:SetKeyValue( "effect_name", "[28]_aqua_tornado" )
			par:SetKeyValue( "start_active", "1" )
			par:SetParent(self)
			par:SetPos( self:GetPos() ) 
			par:SetAngles( self:GetAngles() )
			par:Spawn() 
			par:Activate() 

			local par2 = ents.Create( "info_particle_system" ) 
			par2:SetKeyValue( "effect_name", "[28]_aquadrop" )
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
						dmginfo:SetDamageType( DMG_ACID  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
						dmginfo:SetDamagePosition( self:GetPos()  )
						dmginfo:SetAttacker( self.Owner )
						dmginfo:SetInflictor( self.Owner )
						PoisonDmg(v, config.nb, own)
						v:TakeDamageInfo(dmginfo)

						local spawnPos = v:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), -50)

						local prop = ents.Create("corruption4_1")
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
	scripted_ents.Register( ENT, "corruption4" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "corruption4_1"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/remiliadammaku/remiredcrystal.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor(Color(127,0,0,255))
		self:SetAngles(Angle(0,math.random(0,360),0))
		self:SetModelScale(10,0)
		self:GetPhysicsObject():EnableGravity( false )

		local par = ents.Create( "info_particle_system" ) 
			par:SetKeyValue( "effect_name", "[28]_aqua_area" )
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
	scripted_ents.Register( ENT, "corruption4_1" )
end