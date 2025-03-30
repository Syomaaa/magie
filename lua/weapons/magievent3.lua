AddCSLuaFile()

SWEP.PrintName 		      = "Vent 3" 
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

SWEP.Category             = "Vent"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 75
config.dmg2 = 75
config.tmp = 2.5    -- temps pour l'attaque 

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		config.switch = false
		local own = self:GetOwner()

		self.tor = ents.Create( "tor" )
		self.tor:SetPos( own:GetPos() + Vector( 0, 0, own:OBBCenter().z/2 ) ) 
		self.tor:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
		self.tor:SetOwner( own ) 
		self.tor:Spawn() 
		self.tor:Activate() 
		own:EmitSound("ambient/wind/wind_snippet5.wav", 60, 160, 0.6)

		local tornade = ents.Create("env_smokestack")
		tornade:SetKeyValue("smokematerial", "cloud/cloud.vmt")
		tornade:SetKeyValue("rendercolor", "170, 170, 170" )
		tornade:SetKeyValue("targetname","tornade")
		tornade:SetKeyValue("basespread","120")
		tornade:SetKeyValue("spreadspeed","100")
		tornade:SetKeyValue("speed","600")
		tornade:SetKeyValue("startsize","30")
		tornade:SetKeyValue("endzide","100")
		tornade:SetKeyValue("rate","600")
		tornade:SetKeyValue("jetlength","800")
		tornade:SetKeyValue("twist","800")
		tornade:SetPos( self.tor:GetPos())
		tornade:Spawn()
		tornade:Fire("turnon","",0.1)
		tornade:Fire("Kill","",config.tmp)
		tornade:EmitSound( "", 75, 100, 1, CHAN_AUTO )

		timer.Create("zone"..tornade:EntIndex(),0.01,config.tmp*100,function()
			if (IsValid(tornade) && IsValid(self) && self:GetOwner():Alive()) then
				tornade:SetPos( self.tor:GetPos())
			end
		end)

		timer.Create("zone_dmg"..tornade:EntIndex(),0.2,config.tmp*4.5,function()
			if (IsValid(tornade) && IsValid(self) && self:GetOwner():Alive() ) then
				local BigDust = EffectData()
				BigDust:SetOrigin(tornade:GetPos())
				BigDust:SetScale(200)
				util.Effect("ThumperDust",BigDust)
				for k,v in pairs(ents.FindInSphere(tornade:GetPos() + Vector(0,0,100),500)) do
					if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( tornade:GetPos() + Vector(0,0,100) )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
		end)

		timer.Simple(config.tmp,function()
			config.switch = true
		end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	return true
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	if config.switch == false then
		return false
	else
		return true
	end
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tor"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOT
	ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end self:SetNWBool( "XDEBZ_Iced", true )
		self:SetModel( "models/hunter/tubes/circle4x4.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) self:SetRenderMode( RENDERMODE_NORMAL )
		SafeRemoveEntityDelayed(self,config.tmp)
	end
	function ENT:Think() if !SERVER or !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() then
		if SERVER then self:Remove() end return end
		local own = self.Owner
		local tra = util.TraceLine( {
		start = own:EyePos(), endpos = own:EyePos() + own:EyeAngles():Forward()*1000,
		mask = MASK_NPCWORLDSTATIC, filter = { self, own } } )  local ptt = tra.HitPos + tra.HitNormal*8
		if self:GetPos():Distance( ptt ) > 10 then self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*100 ) end
		self:NextThink( CurTime() ) return true
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			self:DrawShadow( false )
		end
	end
	scripted_ents.Register( ENT, "tor" )
end

if SERVER then return end
