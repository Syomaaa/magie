AddCSLuaFile()

SWEP.PrintName 		      = "Plante 3" 
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

SWEP.Category             = "Plante"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

config.tmp = 5
config.dmg1 = 10
config.dmg2 = 15 -- degats de feu 
config.zone = 300

config.zone = 250
config.repet = 5

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end


-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	local own = self.Owner


	timer.Create("plantepar"..own:EntIndex(),0.01,1,function()
		if self:IsValid() then
			local p = ents.Create( "info_particle_system" ) 
			p:SetKeyValue( "effect_name", "[0]_sakura_sphere_ambient" )
			p:SetAngles(own:GetAngles() + Angle(0,90,0))
			p:SetKeyValue( "start_active", "1" )
			p:SetPos( own:GetPos() ) 
			p:SetParent(own)
			p:Spawn() 
			p:Activate() 
			SafeRemoveEntityDelayed(p,3)
		end
	end)


	timer.Create("plantecercle"..own:EntIndex(),0.2,1,function()
		if self:IsValid() then
			local circle = ents.Create( "plante_circle" )
			circle:SetPos( own:GetPos()+own:GetForward()*35+Vector(0,0,60))
			circle:SetAngles(own:GetAngles() + Angle(90,0,0))
			circle:Fire("SetParentAttachmentMaintainOffset", "eyes", 0.01)
			circle:SetParent(own)
			circle:SetOwner( own )
			circle:Spawn() 
			circle:Activate()
		end
	end)
	

	timer.Create("zone_dmg"..self:EntIndex(),0.2,config.tmp*5,function()
		if (IsValid(self) && self:GetOwner():Alive()) then
			local f = 0
			for i=1,config.repet do
				for k,v in pairs(ents.FindInSphere(own:GetPos()+own:GetForward()*(config.zone/2)+own:GetForward()*(f),config.zone)) do
					if IsValid(v) and v != own then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( own:GetPos()+own:GetForward()*(config.zone/2) )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end
				f = f + config.zone
			end
		end
	end)

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

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "plante3"
	ENT.Spawnable = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )	
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale(0.7,0)
		self:SetColor(Color(0,255,157,255))
		SafeRemoveEntityDelayed( self,config.tmp )

		local par = ents.Create( "info_particle_system" ) 
		par:SetKeyValue( "effect_name", "plants" )
		par:SetKeyValue( "start_active", "1" )
		par:SetPos( self:GetPos()+self:GetForward()*35+Vector(0,0,40)) 
		par:SetAngles(self:GetAngles()  + Angle(-90,0,0))
		par:SetParent(self)
		par:Spawn() 
		par:Activate() 

		SafeRemoveEntityDelayed(par,config.tmp)
	end
	function ENT:OnRemove()
		if !SERVER then return end
		self:StopSound( "")
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
		end
	end
	scripted_ents.Register( ENT, "plante_circle" )
end