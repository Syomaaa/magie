AddCSLuaFile()

SWEP.PrintName 		      = "Jugement 1" 
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

SWEP.Cooldown2 = 1

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0

SWEP.CooldownDelay2 = 0

config.dmg1 = 30 
config.dmg2 = 30    -- degat 
config.zone = 150
config.tmp = 3

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay2 < CurTime() then if !SERVER then return end

	    if SERVER then

		    local own = self:GetOwner()
		    local pos = own:GetEyeTrace().HitPos
		    local ang = Angle(0,own:GetAngles().y,0)

			local chaine = ents.Create( "sceau_chaine" ) 
			chaine:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			chaine:SetPos(pos + ang) 
			chaine.Owner = own
			chaine:Spawn() 
			chaine:Activate() 
			own:DeleteOnRemove( chaine )
			chaine:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )


		self.CooldownDelay2 = CurTime() + self.Cooldown2
		self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .."s de cooldown !" )
		end
	end
end

-------------------------------------------------------------------------------------------------------------

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "Spike"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.Broken = false  ENT.Upper = 0  ENT.Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/heroes/pudge/pudge_chain.mdl" )
		self:SetSolid( SOLID_NONE )  
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale(2,0.5)
		self:SetMaxHealth( 40 ) 
		self:SetHealth( self:GetMaxHealth() )
		self:SetAngles(  Angle( math.random(0,45), math.random(0,360), math.random(0,90) ) ) 
		self:SetPos( self:GetPos() + Vector( 0, 0, 20 ) ) 
		SafeRemoveEntityDelayed( self, 1.5 )
	end
	function ENT:OnRemove() if !SERVER or self.Broken then return end 
		self.Broken = true
		local own = self.Owner
		local par = ents.Create( "info_particle_system" )
		par:SetKeyValue( "effect_name", "blood_impact_green_02_chunk" ) 
		par:SetKeyValue( "start_active", "1" )
		par:SetPos( self:WorldSpaceCenter() ) 
		par:SetOwner( Entity( 0 ) ) 
		par:SetAngles( Angle( 0, 0, 0 ) )
		par:Spawn() 
		par:Activate() 
		SafeRemoveEntityDelayed( par, 0.1 )
		self:StopSound( ")npc/roller/blade_out.wav" ) 
		self:EmitSound( ")npc/roller/blade_out.wav" ,70,100,0.6) 
		self:SetHealth( 0 )
	end
	function ENT:Think() if !SERVER or self.Broken then return end
		
		self:NextThink( CurTime() + 0.01 ) return true
	end
	function ENT:OnTakeDamage( dmg ) if self.Broken then return end
		if IsValid( dmg:GetInflictor() ) and dmg:GetInflictor():GetClass() == self:GetClass() then return end
		if self:Health() <= dmg:GetDamage() then 
			self:Remove() 
		else 
			self:SetHealth( math.max( 1, self:Health() - dmg:GetDamage() ) )
		end
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "chaine" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "sceau_chaine"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH  ENT.Tars = {}  ENT.NextAtk = 0 ENT.Nexttik = 0
	ENT.Effect = false  ENT.Gre = 1  ENT.Owner = nil
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/jutsu/models/trap/trap.mdl" )
		self:SetColor(Color(140,10,10,220))
		self:SetModelScale(6.5,0.5)
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetPos( self:GetPos() - Vector( 0, 0, 0 ) ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR)
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think() if !SERVER or !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() then
		if SERVER then self:Remove() end return end
		local own = self.Owner

		if self.NextAtk < CurTime() then 
			self.NextAtk = CurTime() + math.Rand( 0.1, 0.3 )
			local tas = {}  
			for k, v in pairs( ents.FindInSphere( self:WorldSpaceCenter(), 200 ) ) do
				if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
					table.insert( tas, v )
				end
			end 
			local tar = tas[ math.random( #tas ) ]
			if IsValid( tar ) then
				local rps = VectorRand():GetNormal()*15  
				rps = Vector( rps.x, rps.y, 0 )
				local ppp = tar:GetPos() + rps
				local spk = ents.Create( "chaine" ) 
				spk:SetPos( ppp )
				spk:SetAngles( Angle( 180, math.Rand( 0, 360 ), 0 ) )
				spk:SetOwner( self ) 
				spk:Spawn() 
				spk:Activate()
				sound.Play( ")weapons/crossbow/hit1.wav", self:WorldSpaceCenter(), 85, math.random( 110, 130 ), 1 )
				timer.Simple( 0, function() 
					if IsValid( tar ) then
						tar:EmitSound( ")npc/roller/blade_out.wav", 80, math.random( 95, 105 ) )
					end 
				end) 
				
				for k,v in pairs(ents.FindInSphere(ppp ,config.zone)) do
					if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( ppp )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end
				
			end
		end
		if self.Nexttik < CurTime() then 
			self.Nexttik = CurTime() + 0.1
			self:SetAngles(self:GetAngles() + Angle(0,1,0))
		end
		self:NextThink( CurTime() ) return true
	end
	function ENT:StartTouch( ent ) end
	function ENT:EndTouch( ent ) end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.Effect then self.Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "sceau_chaine_eff", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "sceau_chaine" )
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
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 255 ) - Vector(0,0,20)
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
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
						particle:SetColor( 10, 10, 10 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 255 )- Vector(0,0,10)
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
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
						particle:SetColor( 180, 0, 0 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 15 do
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 255 )- Vector(0,0,20))
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
	effects.Register( EFFECT, "sceau_chaine_eff" )
end