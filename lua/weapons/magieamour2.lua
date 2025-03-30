AddCSLuaFile()

SWEP.PrintName 		      = "Amour 2" 
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

SWEP.Category             = "Amour"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 200
config.dmg2 = 200  -- dmg de .. à ..
config.freeze = 1.5  -- Love du freeze

config.zone = 300

SWEP.Cooldown = 11.5

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end


-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
	local own = self:GetOwner()
	local tr = self.Owner:GetEyeTrace()

	local dist = tr.StartPos:Distance(tr.HitPos)
					
	
	if dist < 3000 then
		local tar = tr.Entity
		if not IsValid(tar) or tar == self.Owner then return end
		if !(tar:IsPlayer() or tar:IsNPC() or type( tar ) == "NextBot") then return end

		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then if !SERVER then return end
		

			local amour2 = ents.Create( "amour2" )
			amour2:SetOwner( own ) 
			amour2:SetPos( tar:GetPos() )
			amour2:SetAngles( Angle( 0, own:GetAngles().yaw+90, 0 ) ) 
			amour2:Spawn() 
			amour2:Activate()
				

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
	end
    return true

end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "amour2"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			if !SERVER then return end
			self:DrawShadow( false ) if !SERVER then return end
			self:SetModel( "models/huey/ph&ch/pure_heart.mdl" )
			self:SetMaterial( "models/huey/ph&ch/pureheart_7.vmt" )
			self:SetSolid( SOLID_NONE ) self:SetMoveType( MOVETYPE_NONE )
			self:SetTrigger( true )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:UseTriggerBounds( true, 0 )
			self:SetColor( Color( 255,255,255,100 ) )
			self:SetModelScale( 8, 0.3 ) local own = self.Owner
			self:SetPos(self:GetPos()+Vector(0,0,80))
			SafeRemoveEntityDelayed( self, config.freeze+0.5 )
	
			ParticleEffect( "[27]_love_dash_add", self:GetPos()-Vector(0,0,80),Angle(0,0,0), self )

			for k,v in pairs(ents.FindInSphere(self:GetPos()  - Vector(0,0,80),config.zone)) do
                if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					timer.Simple(1,function()
						if IsValid(v) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType( DMG_GENERIC  )
							dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
							dmginfo:SetDamagePosition( self:GetPos()  )
							dmginfo:SetAttacker( self.Owner )
							dmginfo:SetInflictor( self.Owner )
							v:TakeDamageInfo(dmginfo)
						end
					end)

					if IsValid(v) and v != self.Owner and (v:IsPlayer())  then
						v:SetMoveType(MOVETYPE_NONE)
						v:Freeze(true)
						timer.Simple(config.freeze,function()
							if IsValid(v) then
								v:SetMoveType(MOVETYPE_WALK)
								v:Freeze(false)
							end
						end)
					end
					if IsValid(v) and v:IsNPC() and v != self.Owner then
						v:SetCondition( 67 )
						timer.Simple(config.freeze,function()
							if IsValid(v) then
								v:SetCondition( 68 )
							end
						end)
					end
					
				end
			end  

			SafeRemoveEntityDelayed(self,3)
		end
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawShadow( false )
			self:DrawModel()
		end
	end
	scripted_ents.Register( ENT, "amour2" )
end