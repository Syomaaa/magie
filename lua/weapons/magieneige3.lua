AddCSLuaFile()

SWEP.PrintName 		      = "Neige 3" 
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

SWEP.Category             = "Neige"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 75
config.dmg2 = 75
config.tmp = 2.5
config.zone = 500

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

		local neige3 = ents.Create("neige3")
		neige3:SetPos(self.Owner:GetPos())
		neige3:SetOwner(self.Owner )
		neige3:Spawn()

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
	ENT.PrintName = "neige3"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	ENT.cd = 0.3
	ENT.cdDelay = 0

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

			self:EmitSound("ambient/fire/firebig.wav",60,100,0.8)

			local idx = "neige3"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "snow_tornado", 1, self, 1 )
				end
			end)

			SafeRemoveEntityDelayed(self,config.tmp)

		end
	end
	function ENT:Think()
		if SERVER then
			if self.cdDelay <= CurTime() then
				for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
					if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
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
		local ptt = tra.HitPos + tra.HitNormal*8
		if self:GetPos():Distance( ptt ) > 100 then 
			self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*100 ) 
		end
		self:NextThink(CurTime())
		return true
	end
	function ENT:OnRemove()
		self:StopSound("ambient/fire/firebig.wav")
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "neige3" )
end