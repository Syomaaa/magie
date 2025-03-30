AddCSLuaFile()

SWEP.PrintName 		      = "Infernal 2" 
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

SWEP.Category             = "Infernal"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 11.5
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

config.dmg1 = 40
config.dmg2 = 40
config.tmp = 1.5     -- temps pour la tempete
config.tmpfreeze = 1.5
config.zone = 300

config.intervalDmgPoi = 0.5 -- interval entre chaque dgt poison
config.dmgPoi1 = 5 -- dgt poison entre .. et ..
config.dmgPoi2 = 5
config.nb = 5 --nb de fois que le poison touche

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
			local infernal2 = ents.Create( "infernal2" )
			infernal2:SetOwner( own ) 
			infernal2:SetPos( pos )
			infernal2:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
			infernal2:Spawn() 
			infernal2:Activate()

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	
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

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "infernal2"
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
			self:EmitSound( "ambient/fire/gascan_ignite1.wav" , 100, 100,0.4)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end

			local idx = "infernal2"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "fire_wall", 1, self, 1 )
				end
			end)

			SafeRemoveEntityDelayed(self,config.tmp)
		end
	end
	function ENT:Think()
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
				if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_BURN  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					PoisonDmg(v, config.nb, own)
					v:Ignite(3)
					v:TakeDamageInfo(dmginfo)

					if IsValid(v) and v != self.Owner and (v:IsPlayer())  then
						v:SetMoveType(MOVETYPE_NONE)
						v:Freeze(true)
						timer.Simple(config.tmpfreeze,function()
							if IsValid(v) then
								v:SetMoveType(MOVETYPE_WALK)
								v:Freeze(false)
							end
						end)
					end
					if IsValid(v) and v:IsNPC() and v != self.Owner then
						v:SetCondition( 67 )
						timer.Simple(config.tmpfreeze,function()
							if IsValid(v) then
								v:SetCondition( 68 )
							end
						end)
					end
				end
			end  
		end
		self:NextThink(CurTime() + 0.2)
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
	scripted_ents.Register( ENT, "infernal2" )
end