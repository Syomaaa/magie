SWEP.PrintName 		      = "Désintégration 1" 
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

SWEP.Category             = "Désintégration"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 35
config.dmg2 = 50  -- dmg de .. à ..

config.hitbox = 100
config.zone = 150

SWEP.Cooldown = 0.2

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

config.intervalDmgPoi = 0.5 -- interval entre chaque dgt poison
config.dmgPoi1 = 10 -- dgt poison entre .. et ..
config.dmgPoi2 = 10
config.nb = 1 --nb de fois que le poison touche

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
			local ang = Angle(0, own:EyeAngles().Yaw, 0)
			local pos = own:GetShootPos() - Vector(0,0,25) + ang:Forward() * 10,10
			local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

			local desintegration1 = ents.Create( "desintegration1" )
			desintegration1:SetPos( pos )
			desintegration1:SetAngles( ang ) 
			desintegration1:SetOwner( own )
			desintegration1:Spawn() 
			desintegration1:Activate() 
			own:DeleteOnRemove( desintegration1 )
			desintegration1:GetPhysicsObject():SetVelocity( dir )
			desintegration1:SetPhysicsAttacker( own )

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
	ENT.PrintName = "Desintegration1"
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
			self:EmitSound( "npc/roller/mine/rmine_explode_shock1.wav" , 100, 100,0.4)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end
			local idx = "desintegration1"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "dskart_death_ash", 1, self, 1 )
				else
					timer.Remove(idx)
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
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*3000 ) 
		end 

		local own = self.Owner

		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.hitbox)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then
			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
                if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_DISSOLVE  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
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
	scripted_ents.Register( ENT, "desintegration1" )
end