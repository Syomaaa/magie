AddCSLuaFile()

SWEP.PrintName 		      = "Illusion 2" 
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

SWEP.Category             = "Illusion"

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

config.hide = 5 -- tmp vision bloque

config.stop = false

SWEP.Cooldown = 10

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

		if SERVER then

			local own = self:GetOwner()
			local ang = Angle(180, own:EyeAngles().Yaw, 0)
			local pos = own:GetShootPos() - Vector(0,0,25) + ang:Forward() * 10,10
			local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*5

			local card = ents.Create( "illusion3" )
			card:SetPos( pos )
			card:SetAngles( ang ) 
			card:SetOwner( own )
			card:Spawn() 
			card:Activate() 
			own:DeleteOnRemove( card )
			card:GetPhysicsObject():SetVelocity( dir )
			card:SetPhysicsAttacker( own )
			card:EmitSound("physics/cardboard/cardboard_box_impact_bullet1.wav", 65, math.Rand(100,130), 0.8)

		end

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
	ENT.PrintName = "illusion3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/cards/card1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,255,255,255 ) )
		self:SetModelScale(3,0.1)
		self:GetPhysicsObject():EnableGravity( false )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_WAS_THROWN )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:cardBreak( ppp )
		if self.XDEBZ_Hit or !isvector( ppp ) then return end local own = self.Owner
		if SERVER then
			self.XDEBZ_Hit = true self:EmitSound("physics/cardboard/cardboard_box_impact_bullet1.wav", 65, math.Rand(30,60), 0.8)
			for k,v in pairs(ents.FindInSphere(ppp ,300)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( ppp )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
				if v:IsPlayer() and v != own and config.stop != true then
					if SERVER then
						config.stop = true
						local illusion4_zone2 = ents.Create( "illusion4_zone" ) 
						illusion4_zone2.Owner = own
						illusion4_zone2:SetPos( v:GetPos() + Vector(0,0,100))
						illusion4_zone2:SetAngles(own:EyeAngles())
						illusion4_zone2:SetParent(v)
						illusion4_zone2:Spawn() 
						illusion4_zone2:Activate() 
						timer.Simple(config.hide, function()
							config.stop = false
			
						end)	
					end		
				end
				if v:IsNPC() and v != own and config.stop != true then	
					if SERVER then
						config.stop = true
						local illusion4_zone3 = ents.Create( "illusion4_zone" ) 
						illusion4_zone3.Owner = own
						illusion4_zone3:SetPos( v:GetPos()+ Vector(0,0,100))
						illusion4_zone3:SetAngles(Angle(0,own:EyeAngles().y+90,0))
						illusion4_zone3:SetParent(v)
						illusion4_zone3:Spawn() 
						illusion4_zone3:Activate() 
						timer.Simple(config.hide, function()
							config.stop = false
						end)
					end
				end
			end
		end
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.1 )
	end
	function ENT:StartTouch( ent )
		if self.XDEBZ_Hit or ent:GetClass() == self:GetClass() or ent.XDEBZ_Gre then return end  local own = self.Owner
		if IsValid( own ) and own == ent then return end self:cardBreak( self:GetPos() )
	end
	function ENT:PhysicsCollide( data, phys )
		if self.XDEBZ_Hit then return end  local own = self.Owner
		if IsValid( data.HitEntity ) and ( data.HitEntity:GetClass() == self:GetClass() or ( IsValid( own ) and own == data.HitEntity ) or data.HitEntity.XDEBZ_Gre ) then return end
		self:cardBreak( data.HitPos + data.HitNormal*5 )
	end
	function ENT:Think() if !SERVER then return end
	if !self.XDEBZ_Hit then self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*50000 ) end end
	function ENT:OnTakeDamage( dmginfo ) if !self.XDEBZ_Hit then self:cardBreak( self:GetPos() ) end end
	function ENT:OnTakeDamage( dmg ) end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "illusion3_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "illusion3" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "illusion4zone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/misc/shell2x2.mdl" )
		self:SetMaterial( "models/shiny" )
		self:SetSolid( SOLID_NONE ) self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( true )
		self:UseTriggerBounds( true, 0 )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,255,255,235 ) )
		self:SetModelScale( 4, 0.3 ) local own = self.Owner
		SafeRemoveEntityDelayed( self, config.hide+0.1 )
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			local ef = EffectData()
			ef:SetEntity( self )
			util.Effect( "illusion4_zone_effect", ef )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "illusion4_zone" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.03
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-5,5),math.random(-5,5),math.random(-2,2)))
					if particle2 then  local size = math.Rand( 3, 6 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.2 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_glow_05.vmt", ent:WorldSpaceCenter()+ Vector(math.random(-5,5),math.random(-5,5),math.random(-2,2)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.2) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 3 )
						particle2:SetEndSize( 3 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255 )
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
	effects.Register( EFFECT, "illusion3_effect" )
end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = 0
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
		ent.RenderOverride = function( ent )
			render.SuppressEngineLighting( true ) ent:DrawModel() render.SuppressEngineLighting( false )
		end
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 1
				for i=0, 0 do
					local particle2 = self.Emitter:Add( "carte3.vmt", ent:WorldSpaceCenter()  + Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200)) )
					if particle2 then
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 30 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.2, 0.3) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( 5 )
						particle2:SetEndSize( 5 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor( 255, 255, 255 )
						particle2:SetGravity( Vector( 0, 0, 50 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
			end
			return true
		end
		
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "illusion4_zone_effect" )
end