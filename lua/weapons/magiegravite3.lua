AddCSLuaFile()

SWEP.PrintName 		      = "Gravité 3" 
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

SWEP.Category             = "Gravité"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 50
config.dmg2 = 50

config.tmp = 5

config.zone = 350
config.hitbox = 350

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

--------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	
			local own = self:GetOwner()

			local pos = own:GetEyeTrace().HitPos
			local ang = Angle(0,own:GetAngles().y,0):Forward()

			local base = ents.Create( "draco_meteore_base" ) 
			base:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			base:SetPos( pos + Vector(0,0,800)) 
			base.Owner = own
			base:Spawn() 
			base:Activate() 
			own:DeleteOnRemove( base )

			timer.Create("darco_rain"..self:EntIndex(), 0.1, 0, function()
				if (IsValid(base) && IsValid(self) && self:GetOwner():Alive() ) then
					local air = base:GetPos() - Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),0)
					local dir = Vector(0,0,-3000) +VectorRand():GetNormal()*10

					local gravite3 = ents.Create( "draco_meteore" )
					gravite3:SetOwner( own ) 
					gravite3:SetPos( air)
					gravite3:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
					gravite3:Spawn() 
					gravite3:Activate()
					gravite3:GetPhysicsObject():SetVelocity( dir )
				end
			end)

			

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "gravite1"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/rock/rock.mdl")
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:SetMaterial("models/props_combine/prtl_sky_sheet")
			self:SetModelScale(1,0)
			self:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			self:DrawShadow(false)


			self:EmitSound(Sound("fireball_explosion.wav"),50)

			local idx = "draco"..self:EntIndex()
			timer.Create(idx,0.01,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "aes_tage", 1, self, 1 )
				end
			end)
			SafeRemoveEntityDelayed(self,2)

			

		end
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.2 )
	end
	function ENT:Think() if !SERVER then return end
		self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then

			ParticleEffect("aes_explode2",self:GetPos(),Angle(0,0,0))


			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
                if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end  
		end
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
				
			end
		end
	end
	scripted_ents.Register( ENT, "draco_meteore" )
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "gravit1"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_NONE )
			self:SetMoveType( MOVETYPE_NONE)
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end

			local idx = "draco1"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					ParticleEffect( "aes_tage_finish", self:GetPos(),Angle(0,0,0) )
				end
			end)
			SafeRemoveEntityDelayed(self,1)
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "draco_meteore_base" )
end