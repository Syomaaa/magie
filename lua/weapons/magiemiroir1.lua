AddCSLuaFile()

SWEP.PrintName 		      = "Miroir 1" 
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
config.dmg1 = 5
config.dmg2 = 5 -- dmg de .. à ..

config.zone = 40 -- moin c'est grand plus ça touche

SWEP.Cooldown = 0.2

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
	local pos = own:GetPos()

	pos=pos+self:GetForward()*100+ Vector(0,0,30)
	
	local miroir = ents.Create( "miroir" ) 
	miroir:SetPos( pos ) 
	miroir:SetAngles(Angle(own:GetAngles().x,own:GetAngles().y,0))
	miroir.Owner = own
	miroir:Spawn() 
	miroir:Activate() 

	timer.Simple(0.3, function()
		if IsValid(miroir) then
			miroir:SetModelScale( 0.3, 0.3 )
		end
	end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

--------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
 return true
end


function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "miroir"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/blueflytrap/darksouls2/weapons/mirror_shield.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
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
				endpos = self:GetPos() + self:GetForward()*5000,
			} )
			
			local pos = tr.HitPos
			local effectdata = EffectData()
			effectdata:SetStart(pos)
			effectdata:SetOrigin(self:GetPos()+self.Owner:GetForward()+Vector(0,0,40))
			util.Effect( "laser", effectdata )

			
			local tr = util.TraceHull( {
				start = self:GetPos(),
				endpos = self:GetPos() + self:GetForward() * 5000,
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
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "miroir_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "miroir" )
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
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)) )
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
						particle2:SetColor( 200, 150, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)) )
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
						particle2:SetColor( 200, 150, 255 )
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
	effects.Register( EFFECT, "miroir_effect" )
end