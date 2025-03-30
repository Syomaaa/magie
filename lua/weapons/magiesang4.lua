AddCSLuaFile()

SWEP.PrintName 		      = "Sanguinaire 4" 
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

SWEP.Category             = "Sanguinaire"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 20
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

config.addVie = 5 -- vie en plus par touché
config.delVie = 0 -- vie en moins par attaque

local config = {}
config.dmg1 = 10
config.dmg2 = 10
config.tmp = 5     -- temps pour l'attaque 

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()


   if(CLIENT) then

	fxEmitter = ParticleEmitter(vector_origin)

	end
   
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		config.switch = true

		local own = self:GetOwner()

		pluieSang = ents.Create( "plui_sang" )
		pluieSang:SetPos( own:GetPos() + Vector( 0, 0, own:OBBCenter().z/2 ) ) 
		pluieSang:SetAngles( Angle( 0, own:EyeAngles().yaw, 0 ) )
		pluieSang:SetOwner( own ) 
		pluieSang:Spawn() 
		pluieSang:Activate()

		timer.Create("bloodstorm", 0.02, 200, function()
			if (IsValid(pluieSang) && IsValid(self) && self:GetOwner():Alive() ) then
				local air = pluieSang:GetPos() - Vector(math.random(-150,150),math.random(-150,150),0)
				local pluie = ents.Create("pluie")
				pluie:SetPos(air)
				pluie:SetOwner(self:GetOwner())
				pluie:Activate()
				pluie:Spawn()
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

local regenHealthAmount = 5

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
	ENT.PrintName = "Cloud"
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
	end
	function ENT:Think() if !SERVER or !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() then
		if SERVER then self:Remove() end return end
		local own = self.Owner
		local tra = util.TraceLine( {
			start = own:EyePos(), 
			endpos = own:EyePos() + own:EyeAngles():Forward()*1000,
			mask = MASK_NPCWORLDSTATIC, 
			filter = { self, own }
		 } )  
		
		local ptt = tra.HitPos + tra.HitNormal*8 + Vector(0,0,300)
		if self:GetPos():Distance( ptt ) > 10 then 
			self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*50 ) 
		end
		self:NextThink( CurTime() ) return true
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "plui_sang_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "plui_sang" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "pluie"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/maxofs2d/hover_classic.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetMaterial( "models/shadertest/shader3" )
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableGravity(true);
		self:SetColor( Color( 255 , 255 ,255 , 100 ) )
		SafeRemoveEntityDelayed( self, 1 )
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0.2 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*200 ) 
		end 

		self:NextThink( CurTime() ) return true
	end
	
	function ENT:OnRemove()
    if SERVER then
        local own = self.Owner
        for k,v in pairs(ents.FindInSphere(self:GetPos() ,500)) do
            if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
                self:EmitSound("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav", 70)
                local dmginfo = DamageInfo()
                dmginfo:SetDamageType( DMG_GENERIC  )
                dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
                dmginfo:SetDamagePosition( self:GetPos()  )
                dmginfo:SetAttacker( own )
                dmginfo:SetInflictor( own )
                v:AddEFlags("-2147483648" )
                v:TakeDamageInfo(dmginfo)
                v:RemoveEFlags("-2147483648" )

                if own:IsPlayer() then
                    own:SetHealth(math.min(own:Health() + regenHealthAmount, own:GetMaxHealth()))
                end
            end
        end  
    end
end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "pluie_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "pluie" )
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
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp+ Vector(math.random(-200,200),math.random(-200,200),0) )
					if particle then  local size = math.Rand( 5, 10 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.5, 1.5 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 200, 70, 70 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 )
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp + Vector(math.random(-200,200),math.random(-200,200),0))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 3 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 1, 2 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 200, 70, 70 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),0))
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetAngles( Angle( 90, CurTime() * 10, 0 ) )
					particle:SetDieTime( 0.5 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 255 )
					particle:SetEndSize( 100 )
					particle:SetColor( 150, 30, 30 )
					particle:SetGravity( Vector( 0, 0, 0 ) )
					particle:SetAirResistance( 10 )
					particle:SetCollide( false )
					particle:SetBounce( 0 )
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
				dlight.r = 200
				dlight.g = 70
				dlight.b = 70
				dlight.Brightness = 5
				dlight.Size = 256
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "plui_sang_eff" )
end

if true then
	local Mat2 = Material( "sang/sang2" )
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
				for i=0,1 do
					local particle = self.Emitter:Add( "sang/sang.vmt", ent:WorldSpaceCenter() )
					if particle then  local size = math.Rand( 2, 3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.1, 0.2) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 2 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 150, 150, 150 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
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
		local ent = self.Owner  if IsValid( ent ) then local siz = ( math.abs( math.sin( CurTime()*5 ) )*5 +10 )
			render.SetMaterial( Mat2 ) render.DrawSprite( ent:WorldSpaceCenter(), siz, siz, Color( 150, 150, 150 ) )
		end
	end
	effects.Register( EFFECT, "pluie_effect" )
end