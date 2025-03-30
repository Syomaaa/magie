AddCSLuaFile()

SWEP.PrintName 		      = "Songe 2" 
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

local config = {}

SWEP.Cooldown = 10

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 15
config.dmg2 = 20  -- dmg de .. à ..
config.tmp = 2 -- temps de l'attaque
config.zone = 500

config.switch = true


--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

function SWEP:Think()
end
-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		if SERVER then

			config.switch = true

			local own = self:GetOwner()
			tr = self.Owner:GetEyeTrace()
            hitpos = tr.HitPos

            local pluitoy = ents.Create( "pluie_songe" )
            pluitoy:SetPos( hitpos + Vector(0,0,700)) 
            pluitoy:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
            pluitoy:SetOwner( own ) 
            pluitoy:Spawn() 
            pluitoy:Activate() 

			timer.Simple(config.tmp,function()
				config.switch = true
			end)

		end

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
	ENT.PrintName = "pluie_songe"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/tubes/circle4x4.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		SafeRemoveEntityDelayed(self,config.tmp)

		self.cd = 0.05
		self.cdDelay = 0
	end
	function ENT:Think()
		local own = self.Owner
		local tra = util.TraceLine( {
		start = own:EyePos(), 
		endpos = own:EyePos() + own:EyeAngles():Forward()*1000,
		mask = MASK_NPCWORLDSTATIC, 
		filter = { self, own } } )  
		local ptt = tra.HitPos + tra.HitNormal*8  + Vector(0,0,700)
		if self:GetPos():Distance( ptt ) > 10 then 
			self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*10) 
		end

		if SERVER then
			if self.cdDelay <= CurTime() then
				if IsValid(self) then
					local air = self:GetPos() - Vector(math.random(-500,500),math.random(-500,500),0)
					local pluie = ents.Create("songe_prop")
					pluie:SetPos(air)
					pluie:SetOwner(self:GetOwner())
					pluie:Activate()
					pluie:Spawn()
				end  
				self.cdDelay = CurTime() + self.cd
			end
		end

		self:NextThink(CurTime())
		return true
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "pluie_songe_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "pluie_songe" )
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
	ENT.PrintName = "songe1"
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
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_WAS_THROWN )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
		self:SetModelScale(math.Rand(2,4),0.1)
		self:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableGravity(true)
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:PhysicsCollide( data, phys )
	self:GetPhysicsObject():EnableMotion( false )
	SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*100 ) 
		end 

		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
				local own = self.Owner
				if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end  
		end
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "songe_prop_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "songe_prop" )
end

if SERVER then return end

if true then
	local Mat2 = Material( "paint2" )
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
				for i=1, 1 do
					local ppp = ent:WorldSpaceCenter()+ Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 5, 10 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.1, 0.2 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 1 )
						particle:SetColor( 190, 10, 130 )
						particle:SetGravity( Vector( 0, 0, 10 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 1 do
					local ppp = ent:WorldSpaceCenter() + Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.1, 0.2 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 1, 2 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 190, 10, 130 )
						particle:SetGravity( Vector( 0, 0, 10 ) )
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
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "songe_prop_effect" )
end

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
				for i=1, 2 do
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-600,600),math.random(-600,600),0))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetAngles( Angle( 90, CurTime() * 10, 0 ) )
						particle:SetDieTime(2 )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( 255 )
						particle:SetEndSize( 100 )
						particle:SetColor(190, 10, 130  )
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
				dlight.g = 30
				dlight.b = 200
				dlight.Brightness = 5
				dlight.Size = 256
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "pluie_songe_eff" )
end