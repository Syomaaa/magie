AddCSLuaFile()

SWEP.PrintName 		      = "Jugement 3" 
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

SWEP.Category             = "Jugement"

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

--degat avec probabilite--

	config.dmg1 = 350 
	config.dmg2 = 350   -- degat normaux      4/10

	config.critdmg1 = 500 
	config.critdmg2 = 500   -- degat max      1/10

	config.lowdmg1 = 200 
	config.lowdmg2 = 200   -- degat les plus faibles    4/10

	config.nuldmg1 = 200 
	config.nuldmg2 = 200   -- degat que tout le monde ce prend meme le porteur   1/10

	config.tmp = 3 -- temps de la prison



--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.Owner:IsOnGround() then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then if !SERVER then return end

			local own = self:GetOwner()
			local pos = own:GetPos()
			local ang = Angle(0,own:GetAngles().y,0):Forward()

			local lune_zone = ents.Create( "jugement_zone" ) 
			lune_zone:SetPos( pos + ang*300) 
			lune_zone.Owner = own
			lune_zone:Spawn() 
			lune_zone:Activate() 
			own:DeleteOnRemove( lune_zone )
			lune_zone:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )
			

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
	end
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.PrintName = "lune_zone"
	ENT.Base = "base_anim"
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	ENT.Effect = false  ENT.Owner = nil  ENT.Gre = 1  ENT.NextSnd = CurTime() + math.Rand( 5, 20 )
	ENT.Enemy = nil  ENT.NextFind = 0  ENT.ClBeam = false
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/jackjack/props/circle2.mdl" )
		self:SetMaterial("chaine")
		self:SetColor(Color(55,50,50,255))
		self:SetMoveType( MOVETYPE_NONE ) 
		self:SetSolid( SOLID_VPHYSICS )
		self:SetModelScale(0,0)
		self:SetModelScale(1,0.2)
		self:DrawShadow( false )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmp )

		self.balance = ents.Create("prop_dynamic")
		self.balance:SetPos(self:GetPos())
		self.balance:SetMoveType( MOVETYPE_NONE ) 
		self.balance:SetSolid( SOLID_VPHYSICS )
		self.balance:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self.balance:SetColor(Color(80,40,40))
		self.balance:SetAngles(Angle(0,0,0))
		self.balance:SetModelScale(3,0.5)
		self.balance:SetModel("models/tipthescales/scale.mdl")
		self.balance:Spawn()
		self.balance:Activate()
		SafeRemoveEntityDelayed(self.balance,config.tmp)


		timer.Simple(2,function()
			local x = math.random(1,10)
			if IsValid(self) then
				if x == 1 then
					local own = self.Owner
					for k,v in pairs(ents.FindInSphere(self:GetPos(),600)) do
						if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType( DMG_GENERIC  )
							dmginfo:SetDamage( math.random(config.critdmg1,config.critdmg2) )
							dmginfo:SetDamagePosition( self:GetPos() )
							dmginfo:SetAttacker( self.Owner )
							dmginfo:SetInflictor( self )
							v:TakeDamageInfo(dmginfo)
						end
					end
				elseif x <= 5 && x!=1 then
					local own = self.Owner
					for k,v in pairs(ents.FindInSphere(self:GetPos(),600)) do
						if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType( DMG_GENERIC  )
							dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
							dmginfo:SetDamagePosition( self:GetPos() )
							dmginfo:SetAttacker( self.Owner )
							dmginfo:SetInflictor( self )
							v:TakeDamageInfo(dmginfo)
						end
					end
				elseif x <= 9 && x >= 6 then
					local own = self.Owner
					for k,v in pairs(ents.FindInSphere(self:GetPos(),600)) do
						if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType( DMG_GENERIC  )
							dmginfo:SetDamage( math.random(config.lowdmg1,config.lowdmg2) )
							dmginfo:SetDamagePosition( self:GetPos() )
							dmginfo:SetAttacker( self.Owner )
							dmginfo:SetInflictor( self )
							v:TakeDamageInfo(dmginfo)
						end
					end
				elseif x == 10 then
					for k,v in pairs(ents.FindInSphere(self:GetPos(),600)) do
						if IsValid(v) and (v:IsPlayer() or v:IsNPC()) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType( DMG_GENERIC  )
							dmginfo:SetDamage( math.random(config.nuldmg1,config.nuldmg2) )
							dmginfo:SetDamagePosition( self:GetPos() )
							dmginfo:SetAttacker( self.Owner )
							dmginfo:SetInflictor( self )
							v:TakeDamageInfo(dmginfo)
						end
					end
				end
			end
		end)

	end
	function ENT:Think() self:NextThink( CurTime() )
	end

	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.Effect then self.Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "jugement_zone_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "jugement_zone" )
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = CurTime()
		self.Emitte2 = ParticleEmitter( self.Owner:WorldSpaceCenter(), true )
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )  self.NextLight = CurTime()
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() ) self.Emitte2:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 15 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 ) - Vector(0,0,200)
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 8, 12 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 2, 4 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 10, 10, 10 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 5 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 )- Vector(0,0,200)
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 3 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 3, 4 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 180, 0, 0 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 20 do
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 )- Vector(0,0,200))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
						particle:SetDieTime( 0.5 )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( 75 )
						particle:SetEndSize( 100 )
						particle:SetColor( 10, 10, 10 )
						particle:SetGravity( Vector( 0, 0, 0 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render() local own = self.Owner
		if IsValid( own ) and self.NextLight < CurTime() then self.NextLight = CurTime() + 0.01
			local dlight = DynamicLight( own:EntIndex() ) if dlight then
				dlight.Pos = own:WorldSpaceCenter()
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.Brightness = 5
				dlight.Size = 256
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "jugement_zone_effect" )
end
