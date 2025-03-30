AddCSLuaFile()

SWEP.PrintName 		      = "Contrôle 3" 
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

SWEP.Category             = "Contrôle"

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
config.dmg1 = 175
config.dmg2 = 175
config.tmp = 1     -- temps pour l'attaque 

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()


	local own = self.Owner
	local tra = util.TraceLine( {
	start = own:EyePos(), 
	endpos = own:EyePos() + own:EyeAngles():Forward()*10000,
	filter = { self, own } } )  
	local ptt = tra.HitPos + tra.HitNormal*8
	
	if ptt.z <= own:GetPos().z + 100 then

		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then if !SERVER then return end

			config.switch = false

			if SERVER then
				local base = ents.Create( "grass" )
				base:SetPos( ptt - Vector(0,0,200)) 
				base:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
				base:SetOwner( own ) 
				base:Spawn() 
				base:Activate()
				base:EmitSound("player/footsteps/grass4.wav", 100, math.Rand(30,60), 1)

				timer.Create("switch"..own:EntIndex(),config.tmp,1,function()
					config.switch = true
				end)
			end

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
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/sceneprops/grass_patch.mdl" )
		self.go = false
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_NORMAL )
		self:SetModelScale(3,0.5)
		self:SetColor(Color(200,200,200))
		self:GetPhysicsObject():EnableGravity( true )
		self:GetPhysicsObject():SetMass(1000)
		SafeRemoveEntityDelayed(self,config.tmp)
	end
	function ENT:PhysicsCollide( data, phys )
		SafeRemoveEntityDelayed( self, 0 )
		self:EmitSound("player/footsteps/grass4.wav", 65, math.Rand(30,60), 0.8)
	end
	function ENT:Think() if !SERVER or !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() then
		if SERVER then self:Remove() end return end
		local own = self.Owner
		
		if !self.go then
			local tra = util.TraceLine( {
			start = own:EyePos(), 
			endpos = own:EyePos() + own:EyeAngles():Forward()*1000,
			mask = MASK_NPCWORLDSTATIC, 
			filter = { self, own } } )  
			local ptt = tra.HitPos + tra.HitNormal*8
			if self:GetPos():Distance( ptt ) > 10 then 
				self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*35 ) 
			end
		end


		for k,v in pairs(ents.FindInSphere(self:GetPos() ,300)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
				SafeRemoveEntityDelayed( self, 0.1 )
			end
		end  
				
		if self.Owner:KeyPressed(IN_ATTACK2) and !self.go then
			self.go = true
			config.switch = true
			timer.Remove("switch"..own:EntIndex())
			self:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector()*(100))
			self:EmitSound("player/footsteps/grass2.wav", 65, math.Rand(30,60), 0.8)
		end
		if self.go then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*10000 )
		end

		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		local ex = EffectData()
		ex:SetOrigin(self:GetPos())
		util.Effect("wall",ex) 
	end
	
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "grass_eff", ef )
			end
		end
	end
	scripted_ents.Register( ENT, "grass" )
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
			self.Emitter:SetPos( ent:GetPos() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.05
				for i=0,10 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:GetPos() + Vector(math.random(-300,300),math.random(-300,300),math.random(-100,100)))
					if particle2 then  local size = math.Rand( 10, 15 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.4, 1 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 50, 150, 50 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=0, 10 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:GetPos()+ Vector(math.random(-300,300),math.random(-300,300),math.random(-100,100)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.4, 0.8) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 5 )
						particle2:SetEndSize( 5 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor(  50, 150, 50  )
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
	effects.Register( EFFECT, "grass_eff" )
end