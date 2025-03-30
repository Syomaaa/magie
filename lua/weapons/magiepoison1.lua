AddCSLuaFile()

SWEP.PrintName 		      = "Poison 1" 
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

SWEP.Category             = "Poison"

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
config.dmg2 = 50  -- dmg de .. à ..
config.hitbox = 150
config.zone = 200

SWEP.Cooldown = 0.3
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

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

		if SERVER then

			local own = self:GetOwner()
			local pos = self.Owner:GetEyeTrace().HitPos

			local dir = Vector(0,0,-3000) +VectorRand():GetNormal()*100

			local poison1 = ents.Create( "poison1" )
			poison1:SetPos( pos + Vector(math.random(0,0),math.random(0,0),200) )
			poison1:SetOwner( own )
			poison1:Spawn() 
			poison1:Activate() 
			own:DeleteOnRemove( poison1 )
			poison1:GetPhysicsObject():SetVelocity( dir )
			poison1:SetPhysicsAttacker( own )

		end

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
	ENT.PrintName = "poison1"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end

			local idx = "poison1"..self:EntIndex()
			timer.Create(idx,0.01,10,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)

					local ent = ents.Create("info_particle_system")
					ent:SetKeyValue("effect_name", "")
					ent:SetPos(self:GetPos())
					ent:Spawn()
					ent:Activate()
					ent:Fire("Start", "", 0)
					ent:Fire("Kill", "", 2)
				end
			end)
			SafeRemoveEntityDelayed(self,2)
		end
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think() if !SERVER then return end
		self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then
			local ent = ents.Create("info_particle_system")
			ent:SetKeyValue("effect_name", "[25]_swamp_ground_small")
			ent:SetPos(self:GetPos())
			ent:Spawn()
			ent:Activate()
			ent:Fire("Start", "", 0)
			ent:Fire("Kill", "", 2) 

			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
                if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_ACID  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					PoisonDmg(v, config.nb, own)
					v:TakeDamageInfo(dmginfo)
				end
			end  
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "poison1" )
end