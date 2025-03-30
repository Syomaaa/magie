SWEP.PrintName = "Désintégration 2"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.Author			= "Brounix"
SWEP.Instructions	= ""
SWEP.Contact		= "N/A"
SWEP.Purpose		= ""
SWEP.Category		= "Désintégration"

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.Primary.Cone				= 0
SWEP.Primary.ClipSize			= 0
SWEP.Primary.DefaultClip		= 0
SWEP.Primary.Automatic   		= false
SWEP.Primary.Ammo         		= "none"

SWEP.Cooldown = 10
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 50
config.dmg2 = 50 -- dmg de .. à ..
config.zone = 300

config.nb = 4 -- nb de fois de dgt
config.interval = 0.1 -- interval entre chaque dgt

config.intervalDmgPoi = 0.5 -- interval entre chaque dgt poison
config.dmgPoi1 = 20 -- dgt poison entre .. et ..
config.dmgPoi2 = 20
config.nbpoi = 1 --nb de fois que le poison touche

function SWEP:Initialize()
    self:SetHoldType( "magic" )
end

function SWEP:OnDrop() 
	return false
end

function SWEP:Holster()
	return true
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

function SWEP:PrimaryAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
		if SERVER then
			local pos = self.Owner:GetEyeTrace().HitPos
			
			local entdesintegration2 = ents.Create("desintegration2")
			entdesintegration2:SetPos(pos)
			entdesintegration2.Owner = self.Owner
			entdesintegration2:Spawn()
			SafeRemoveEntityDelayed(entdesintegration2,1)

			local own = self.Owner
		
			timer.Create("dmgexplosion4"..self.Owner:EntIndex(),config.interval,config.nb,function()
				for k,v in pairs(ents.FindInSphere(pos ,config.zone)) do
					if IsValid(v) and v != ent4 and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_DISSOLVE  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						v:AddEFlags("-2147483648" )
						dmginfo:SetDamagePosition( pos  )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
						PoisonDmg(v, config.nbpoi, own)
						v:RemoveEFlags("-2147483648" )
					end
				end 
			end)

		end
		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:Reload()
end

function SWEP:SecondaryAttack()
end 

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "desintegration2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/plates/plate6x7.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:EmitSound( "npc/env_headcrabcanister/explosion.wav" , 100, 100,0.4)

		local idx = "desintegrationnnnnn"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "dskart_slam", 1, self, 1 )
				else
					timer.Remove(idx)
				end
			end)
		
		SafeRemoveEntityDelayed( self, 1 )
	end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "[4]_compass", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "desintegration2" )
end