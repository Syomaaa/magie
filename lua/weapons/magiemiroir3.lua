AddCSLuaFile()

SWEP.PrintName 		      = "Miroir 3" 
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

SWEP.Category             = "Miroir"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 10
config.dmg2 = 10 -- dmg de .. à ..

config.nb = 20 -- 
config.parS = 0.1 

config.zone = 200 -- moin c'est grand plus ça touche

SWEP.Cooldown = 15

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
   
	self:SetHoldType( "magic" )
end

--------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	local own = self.Owner
	local pos = self.Owner:GetEyeTrace().HitPos
	local miroir = ents.Create( "miroir_zone" ) 
	miroir:SetPos(pos) 
	miroir.Owner = own 
	miroir:SetAngles( Angle( 0, own:GetAngles().yaw, 0 ) ) 
	miroir:Spawn() 
	miroir:Activate() 
	
	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

--------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end


if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "miroir_zone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2a.mdl" )
		self:SetMaterial( "color-blanco-transparente" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )

		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,180,255,30 ) )
		self:SetModelScale( 0,0 ) local own = self.Owner
		SafeRemoveEntityDelayed( self, config.parS*config.nb )
		timer.Simple(0.2, function()
			if IsValid(self) then
				timer.Create("speed"..self:EntIndex(),config.parS,config.nb, function()
					if IsValid(self) then
						local miroir = ents.Create( "miroir2" ) 
						miroir:SetPos( self:GetPos()+Vector(0,0,0) + Vector(math.random(-350,350),math.random(-350,350),math.random(250,250)) ) 
						miroir:SetAngles(Angle(math.random(10,40),math.random(0,360),0))
						miroir.Owner = own
						miroir:Spawn() 
						miroir:Activate() 
					end
				end)
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
				util.Effect( "miroir_zone_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "miroir_zone" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "miroir_zone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/blueflytrap/darksouls2/weapons/mirror_shield.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,180,255,255 ) )
		self:SetModelScale( 0, 0)
		self:SetModelScale( 0.7, 0.2) local own = self.Owner
		SafeRemoveEntityDelayed( self, 1 )
	end
	function ENT:Think()
		if SERVER then
			local own = self.Owner
			local tr = util.TraceLine( {
				start = self:GetPos(),
				endpos = self:GetPos() + self:GetForward()*600,
			} )
			
			local pos = tr.HitPos
			local effectdata = EffectData()
			effectdata:SetStart(pos)
			effectdata:SetOrigin(self:GetPos()+self:GetForward()+Vector(0,0,40))
			util.Effect( "laser", effectdata )

			
			local tr = util.TraceHull( {
				start = self:GetPos(),
				endpos = self:GetPos() + self:GetForward() * 600,
				filter = function( ent )
					if ent == self.Owner then return end
					if( ent:IsValid() and ent != self and (ent:IsPlayer() or ent:IsNPC() or type( ent ) == "NextBot")) then
						ent:TakeDamage( math.random(config.dmg1,config.dmg2), self.Owner, self )
						if( ent:IsValid() ) then
							return false
						end
					end
				end,
				mins = Vector( -config.zone -config.zone, -config.zone ),
				maxs = Vector( config.zone, config.zone, config.zone ),
				mask = MASK_SHOT_HULL
			} )
		end
		self:NextThink( CurTime() ) return true
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "miroir2" )
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
				for i=1, 15 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-600,600),math.random(-600,600),math.random(-200,600)) )
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
						particle2:SetColor( 255, 150, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 15 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-600,600),math.random(-600,600),math.random(-200,600)) )
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
						particle2:SetColor( 255, 150, 255 )
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
	effects.Register( EFFECT, "miroir_zone_effect" )
end