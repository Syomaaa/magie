AddCSLuaFile()

SWEP.PrintName 		      = "Astral 2" 
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

SWEP.Category             = "Astral"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

config.Cooldown = 0.1 -- coolwon atk pet

config.dmg1 = 25
config.dmg2 = 25
config.tmp = 5     -- temps de l'attack
config.hitbox = 250
config.zone = 300

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local astral2 = ents.Create("astral2")
		astral2:SetPos(self.Owner:GetPos())
		astral2:SetOwner(self.Owner )
		astral2:Spawn()

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

--------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	return true
end


function SWEP:Deploy()
	return true
end


function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "astral2"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_NONE )
			self:SetMoveType( MOVETYPE_NONE )
			self:SetSolid( SOLID_NONE )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end

			local idx = "astral2"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "aes_roller", 1, self, 1 )
				end
			end)
			
			local idx = "astral2.2"..self:EntIndex()
			timer.Create(idx,0.1,config.tmp/100,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffect("aes_exs",self:GetPos() + Vector(0,0,800),Angle(0,0,0), self )
				end
			end)

			SafeRemoveEntityDelayed(self,config.tmp)

			self.cd = 0.3
			self.cdDelay = 0
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
					end
				end  
				self.cdDelay = CurTime() + self.cd
			end
		end

		local own = self.Owner
		local tra = util.TraceLine( {
		start = own:EyePos(), 
		endpos = own:EyePos() + own:EyeAngles():Forward()*1000,
		mask = MASK_NPCWORLDSTATIC, 
		filter = { self, own } } )  
		local ptt = tra.HitPos + tra.HitNormal*30
		if self:GetPos():Distance( ptt ) > 150 then 
			self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*150 ) 
		end
		self:NextThink(CurTime())
		return true
	end
	function ENT:OnRemove()
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "astral2" )
end