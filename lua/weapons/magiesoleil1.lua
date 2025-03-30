AddCSLuaFile()

SWEP.PrintName 		      = "Soleil 1" 
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
SWEP.HoldType             = "magie"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Soleil"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.Cooldown = 0.5

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 65
config.dmg2 = 65  -- dmg de .. à ..

config.tmp = 0.1 -- tmp avant qu'ils s'envoient

--------------------------------------------------------------------------------------------------------------


function SWEP:Initialize()
	self:SetHoldType("magic")
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		config.switch = false

		local soleil = ents.Create("soleil1")
		soleil:SetOwner(ply)
		soleil:SetPos(self.Owner:GetShootPos() + self:GetForward()*70 + Vector(0,0,60))
		soleil:SetAngles(Angle(0,0,0))
		soleil:SetOwner(self.Owner)
		soleil:Spawn()
		soleil:Activate()
		
		timer.Simple(0.5, function()
			config.switch = true
		end)

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

function SWEP:SecondaryAttack()
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
	ENT.PrintName = "lame2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.NextFind =0
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/planets/sun.mdl" )
		self:SetMaterial( "models/planets/sun0.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale(0,0)
		self:SetModelScale(1,1)
		self:SetColor( Color( 255,255,255,245 ) )
		self:SetParent(self.Owner)
		self:EmitSound( "ambient/fire/ignite.wav",60,100)
		timer.Simple(0.5, function()
			if IsValid(self) and self.Owner:Alive() then
				self.speed = true
				local dir = self.Owner:GetAimVector()*(10) 
				self:SetParent(nil)
				self:PhysicsInit( SOLID_VPHYSICS )
				self:SetMoveType( MOVETYPE_VPHYSICS )
				self:SetSolid( SOLID_VPHYSICS ) 
				self:GetPhysicsObject():EnableGravity( false )
				self:GetPhysicsObject():SetVelocity( dir )
				self:SetPhysicsAttacker( self.Owner) 
			end
		end)
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:PhysicsCollide( data, phys )
		
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*20000 ) 
		end 

		local own = self.Owner

		for k,v in pairs(ents.FindInSphere(self:GetPos() ,150)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) and self.speed then
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then
			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,200)) do
				if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_BURN  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
					if (v:IsNPC() or v:IsPlayer() or type(v) == "NextBot" or string.find(v:GetClass(),"prop")) and !v:IsOnFire()  and v != self.Owner then
						v:Ignite(2)
					end
				end
			end  
			local ex = EffectData()
			ex:SetOrigin(self:GetPos())
			util.Effect("soleil_explo",ex) 
			sound.Play( "ambient/explosions/explode_4.wav",  self:GetPos() , 65, 80,0.2) 
		end
	end
	if CLIENT then
		function ENT:Draw() 
			self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "soleil1_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "soleil1" )
end