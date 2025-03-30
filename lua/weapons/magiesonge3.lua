AddCSLuaFile()

SWEP.PrintName 		      = "Songe 3" 
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

SWEP.Category             = "Songe"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}

config.dmg1 = 50
config.dmg2 = 50    -- degat zones

config.tmp = 3    -- temps de la zone

config.switch = true

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		config.switch = true

		local own = self:GetOwner()
		local pos = own:GetPos()
		local ang = Angle(0,own:GetAngles().y,0):Forward()


		local songe3 = ents.Create( "songe3" ) 
		songe3:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
		songe3:SetPos( pos + ang) 
		songe3.Owner = own
		songe3:Spawn() 
		songe3:Activate() 
		own:DeleteOnRemove( songe3 )
		songe3:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )

		timer.Create("toy"..songe3:EntIndex(), 0.1, config.tmp*100, function()
			if (IsValid(songe3) && IsValid(self) && self:GetOwner():Alive() ) then
				local air = songe3:GetPos() - Vector(math.random(-400,400),math.random(-400,400),math.random(100,-400))
				local pluie = ents.Create("songe3_prop")
				pluie:SetPos(air)
				pluie:SetOwner(self:GetOwner())
				pluie:Activate()
				pluie:Spawn()
			end
		end)

		timer.Simple(config.tmp-1, function()
			if IsValid(songe3) then
				songe3:SetModelScale( 1, 1 )
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
end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

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
	ENT.PrintName = "songe3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/jackjack/props/circle2.mdl" )
		self:SetMaterial("models/shiny")
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetTrigger( true )
		self:SetColor( Color( 190,10,130,160 ) )
		self:SetModelScale( 0,0)
		self:SetModelScale( 1, 0.7 ) local own = self.Owner
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	
	function ENT:StartTouch( ent )
		if (ent:IsValid() and ent:IsPlayer()) and ent == self.Owner then
			self:SetSolid( SOLID_NONE ) 
		elseif (ent:IsValid() and ent:IsPlayer()) and ent != self.Owner then
			self:SetSolid( SOLID_VPHYSICS ) 
		end
	end
	function ENT:Think()
		if !CLIENT then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),500)) do
				if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)
					v:EmitSound( "npc/headcrab/attack1.wav",65 )
				end
			end
		end
		self:SetSolid( SOLID_VPHYSICS ) 
		self:NextThink( CurTime() + 0.3 )
		return true
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "songe3_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "songe3" )
end

if true then
	local toy = {
		"models/roblox/a_very_special_monster.mdl",
		"models/roblox/blue_sleepy_koala.mdl",
		"models/roblox/cat_of_the_week__bat_cat.mdl",
		"models/roblox/shoulder_shark_cat.mdl",
		"models/roblox/owl_of_the_week__witch_owl.mdl",
		"models/roblox/friendly_swamp_monster.mdl",
		"models/roblox_assets/the_bird_says____.mdl",
		"models/roblox/skeleton_owl.mdl",
		"models/roblox/snowboarding_penguin.mdl",
		"models/roblox_assets/from_the_vault_dozens_of_dinosaurs_dinosaur.mdl",
		"models/roblox_assets/frog_king.mdl",
		"models/roblox/sophisiticated_crow.mdl",
		"models/roblox/sophisticated_bat.mdl",
		"models/roblox_assets/ghostly_monster_friend.mdl",
		"models/roblox_assets/rocket_cat.mdl"
	} 
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "songe3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( toy[ math.random( #toy ) ] )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale(math.Rand(2,5),0.1)
		self:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableGravity(true)
		self:GetPhysicsObject():SetMass(0.01)
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "songe3_prop" )
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
				for i=1, 4 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 30, 600 ) - Vector(0,0,200)
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 15, 20 )
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
						particle:SetColor( 190, 10, 160 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 2 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 30, 600 )- Vector(0,0,200)
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
						particle:SetColor( 190, 60, 160 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 40, 600 )- Vector(0,0,200))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
						particle:SetDieTime( 2 )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( 75 )
						particle:SetEndSize( 100 )
						particle:SetColor( 190, 10, 160 )
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
	effects.Register( EFFECT, "songe3_effect" )
end