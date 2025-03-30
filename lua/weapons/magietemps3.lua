AddCSLuaFile()

SWEP.PrintName 		      = "Temps 3" 
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

SWEP.Category             = "Temps"

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
config.dmg1 = 70
config.dmg2 = 70  -- degat en continue de zone
config.tmp = 2.5    -- temps de la zone
config.freeze = 2.5  -- temps du freeze
config.beforefreeze = 1  -- temps avant freeze apres la bulle active

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		local own = self:GetOwner()
		local pos = own:GetPos()
		local ang = Angle(0,own:GetAngles().y,0):Forward()


		local temps_zone = ents.Create( "temps_zone" ) 
		temps_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
		temps_zone:SetPos( pos + ang) 
		temps_zone.Owner = own
		temps_zone:Spawn() 
		temps_zone:Activate() 
		own:DeleteOnRemove( temps_zone )
		temps_zone:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )

		timer.Create("zone_dmg".. temps_zone:EntIndex(),0.5,config.tmp*2,function()
			if IsValid(temps_zone) then
				for k,v in pairs(ents.FindInSphere(pos + ang,600)) do
					if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( pos )
						v:AddEFlags("-2147483648" )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
						v:RemoveEFlags("-2147483648" )
					end
				end
			end
		end)
		timer.Simple(config.tmp-1, function()
			if IsValid(temps_zone) then
				temps_zone:SetModelScale( 1, 1 )
			end
		end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/rumiadammaku/bluesphere_2.mdl" )
		self:SetSolid( SOLID_NONE ) self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,255,255,100 ) )
		self:SetModelScale( 50, 0.7 ) local own = self.Owner
		SafeRemoveEntityDelayed( self, config.tmp )
		timer.Simple(config.beforefreeze,function()
			if IsValid(self) then
				for k,v in pairs(ents.FindInSphere(self:GetPos(),600)) do
					if v:IsPlayer() and v != own then
						v:Freeze( true )
						timer.Simple(0.2,function()
							if IsValid(self) then
								local temps_zone2 = ents.Create( "temps_zone2" ) 
								temps_zone2.Owner = own
								temps_zone2:SetPos( v:GetPos())
								temps_zone2:Spawn() 
								temps_zone2:Activate() 
							end
						end)
						timer.Simple(config.freeze, function()
							if IsValid(v) then 
								v:Freeze( false )
							end
						end)			
					end
					if v:IsNPC() and v != own then	
						if SERVER then
							v:SetCondition( 67 )
							timer.Simple(0.2,function()
								if IsValid(self) then
									local temps_zone3 = ents.Create( "temps_zone2" ) 
									temps_zone3.Owner = own
									temps_zone3:SetPos( v:GetPos())
									temps_zone3:Spawn() 
									temps_zone3:Activate() 
								end
							end)
							timer.Simple(config.freeze, function()
								if IsValid(v) then 
									v:SetCondition( 68 )
								end
							end)
						end
					end
				end
			end
		end)
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "temps_zone_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "temps_zone" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/rumiadammaku/bluesphere_2.mdl" )
		self:SetSolid( SOLID_NONE ) self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:UseTriggerBounds( true, 0 )
		self:SetColor( Color( 255,255,255,60 ) )
		self:SetModelScale( 8, 0.6 ) local own = self.Owner
		SafeRemoveEntityDelayed( self, config.freeze )
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "temps_zone2" )
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = CurTime()
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
		ent.RenderOverride = function( ent )
			render.SuppressEngineLighting( true ) ent:DrawModel() render.SuppressEngineLighting( false )
		end
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-600,600),math.random(-600,600),math.random(-400,600)) )
					if particle2 then  local size = math.Rand( 3, 6 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.3 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 100, 150, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-600,600),math.random(-600,600),math.random(-400,600)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.2, 0.4) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 3 )
						particle2:SetEndSize( 3 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 100, 150, 255 )
						particle2:SetGravity( Vector( 0, 0, 50 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "temps_zone_effect" )
end