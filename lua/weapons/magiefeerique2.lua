AddCSLuaFile()

SWEP.PrintName 		      = "Féerique 2" 
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

SWEP.Category             = "Féerique"

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

config.dmg1 = 200
config.dmg2 = 200
config.tmp = 1.5     -- temps pour la tempete
config.zone = 300

config.intervalDmgPoi = 0.5 -- interval entre chaque dgt poison
config.dmgPoi1 = 5 -- dgt poison entre .. et ..
config.dmgPoi2 = 5
config.nb = 4 --nb de fois que le poison touche

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	
			local own = self:GetOwner()
			local pos = self.Owner:GetEyeTrace().HitPos
			local feerique2 = ents.Create( "feerique2" )
			feerique2:SetOwner( own ) 
			feerique2:SetPos( pos )
			feerique2:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
			feerique2:Spawn() 
			feerique2:Activate()

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

local function PoisonDmg(ent, num, attacker)

    local valent = ent:EntIndex()

    if !timer.Exists("DMGPOISON"..tostring(valent)) then
        timer.Create("DMGPOISON"..tostring(valent), config.intervalDmgPoi, num, function()
            if IsValid(ent) then
                ent:TakeDamage(math.random(config.dmgPoi1, config.dmgPoi2), attacker, DMG_ACID)   
            else
                timer.Remove("DMGPOISON"..tostring(valent))
            end
        end)
    end
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "Feerique2"
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
			local idx = "feerique2"..self:EntIndex()
			timer.Create(idx,0.2,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(20)
					effectdata:SetEntity(self)
					self:EmitSound("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav", 70, 180, 0.6)
					ParticleEffectAttach( "[11]_insect_follow", 1, self, 1 )
				else
					timer.Remove(idx)
				end
			end)

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
				end
			end  

			SafeRemoveEntityDelayed(self,config.tmp)
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "feerique2" )
end