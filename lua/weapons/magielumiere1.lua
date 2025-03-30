AddCSLuaFile()

SWEP.PrintName 		      = "Lumière 1" 
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

SWEP.Category             = "Lumière"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.Cooldown = 2

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 20
config.dmg2 = 20  -- dmg de .. à ..
config.nb = 20 -- nombre lame
config.vitesse = 0.1 -- tmp que les lames spawn 1 par 1 et s'envoient toute les .....s
config.tmp = 0.2 -- tmp avant qu'ils s'envoient

--------------------------------------------------------------------------------------------------------------


function SWEP:Initialize()
	self:SetHoldType("magic")
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		config.switch = false

		local ply = self.Owner

		timer.Create("speed"..self:EntIndex(),config.vitesse,config.nb, function()
			if IsValid(self) and self:GetOwner():Alive() then
				self.lame = ents.Create("lame_light")
				self.lame:SetOwner(self.Owner)
				self.lame:SetPos(self.Owner:GetShootPos() + Vector(math.random(80,-80),math.random(80,-80),math.random(10,80)))
				self.lame:SetAngles(Angle(0,0,90))
				self.lame:Spawn()
				self.lame:Activate()
			end
		end)
		
		timer.Simple(1, function()
			config.switch = true
		end)

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

-------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	if config.switch == false then
		return false
	else
		return true
	end
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "lameLight"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/leitris/broadsword.mdl" )
		self:SetMaterial("models/shiny")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_NONE ) 
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color(255, 255, 150,200 ) )
		self:SetParent(self.Owner)
		timer.Simple(config.tmp, function()
			if IsValid(self) and self:GetOwner():Alive() then
				self.speed = true
				local dir = self.Owner:GetAimVector()*(10000)
				self:SetAngles(Angle(self.Owner:EyeAngles().x+90,self.Owner:EyeAngles().Yaw,self.Owner:EyeAngles().r+90))
				self:SetParent(nil)
				self:PhysicsInit( SOLID_VPHYSICS )
				self:SetMoveType( MOVETYPE_VPHYSICS )
				self:SetSolid( SOLID_VPHYSICS ) 
				self:GetPhysicsObject():EnableGravity( false )
				self:GetPhysicsObject():SetVelocity( dir)
				self:SetPhysicsAttacker( self.Owner) 
				self:EmitSound("weapons/fx/nearmiss/bulletLtoR06.wav", 70, math.Rand(30,60), 0.8)
				timer.Create("speed11"..self:EntIndex(),0.1,config.nb*2, function()	
					if IsValid(self) and self:GetOwner():Alive() then
						self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 )
					end
				end)
			end
		end)
		local idx = "lumiere1"..self:EntIndex()
		timer.Create(idx,0.01,1,function()
			if IsValid(self) then
				local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetScale(1)
				effectdata:SetEntity(self)
				ParticleEffectAttach( "[12]_light", 1, self, 1 )
			end
		end)
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:PhysicsCollide( data, phys )
		SafeRemoveEntityDelayed( self, 0 )
		self:EmitSound("weapons/fx/nearmiss/bulletLtoR06.wav", 65, math.Rand(30,60), 0.8)
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*10000 ) 
		end 
		local own = self:GetOwner()
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,150)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
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
				util.Effect( "lame_light_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "lame_light" )
end

if SERVER then return end