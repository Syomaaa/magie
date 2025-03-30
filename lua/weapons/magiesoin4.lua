AddCSLuaFile()
 
SWEP.PrintName 		      = "Soin 4" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 85
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.AutoSwitchFrom       = true 
SWEP.DrawAmmo             = false 
SWEP.Base                 = "weapon_base" 
SWEP.Slot 			      = 2
SWEP.SlotPos              = 1 
SWEP.HoldType             = "magic"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Soin"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

---------------------------------------------------------------------------------------------------------

SWEP.Cooldown = 60

SWEP.ActionDelay = 1

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 20
config.dmg2 = 20
config.stoleVie = 15  -- regene vole de vie quand enemie dans la zone

config.tmp = 30  -- temps de l atk

config.addVie = 15 -- regene tout le temps
config.vitesseRegene = 0.5  --deg + regene toute les .. tmp
config.zone = 500

---------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )

end

---------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
		
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if CLIENT then return end


		local own = self.Owner
		if IsValid(feePet) then 
			own:PrintMessage( HUD_PRINTCENTER, "Un seul minion à la fois !" )
			return 
		end
		
		local feePet = ents.Create( "fee" )
		feePet:SetPos( own:GetShootPos() +own:EyeAngles():Forward()*40 )
		feePet:SetAngles( own:EyeAngles() ) 
		feePet:SetOwner( own )
		feePet:Spawn() 
		feePet:Activate() 
		feePet:EmitSound( "npc/ichthyosaur/water_growl5.wav" )
		own:DeleteOnRemove( feePet )
		feePet:SetPhysicsAttacker( own )
		config.Minion = feePet  
		own:SetNWEntity( "Mint2", feePet )
		undo.Create( "fee" )
		undo.AddEntity( feePet ) 
		undo.SetPlayer( own ) 
		undo.Finish()

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end

end

---------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return true
end

function SWEP:Holster()
	return true
end

if true then
	local ENT = {}
	ENT.PrintName = "Fée"
	ENT.Base = "base_anim"
	ENT.hp = 1000 --hp de la fee
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	ENT.AutomaticFrameAdvance = true  ENT.Tick = 0  ENT.Dead = false
	ENT.Effect = false  ENT.Owner = nil  ENT.Gre = 1  ENT.NextSnd = CurTime() + math.Rand( 5, 20 )
	ENT.Enemy = nil  ENT.NextFind = 0  ENT.ClBeam = false  ENT.Regen = -1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/ori_u_npc.mdl" )
		self:SetMoveType( MOVETYPE_NOCLIP ) 
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON ) 
		self:DrawShadow( false )
		self:SetColor(Color(0,255,157))
		self:SetBloodColor( DONT_BLEED )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:UseTriggerBounds( self:OBBMins(), self:OBBMaxs() )
		self:SetMaxHealth( self.hp ) 
		self:SetHealth( self:GetMaxHealth() )
		SafeRemoveEntityDelayed( self, config.tmp )
		self.eff = ents.Create( "heal_pet" )
		self.eff:SetPos( self.Owner:GetPos()) 
		self.eff:Spawn() 
		self.eff:Activate() 
		self.vitesseRegene = 0
	end
	function ENT:Think() self:NextThink( CurTime() ) self.Tick = self.Tick + 0.01  local tic = self.Tick
		if SERVER then
			self.eff:SetPos(self.Owner:GetPos()) 
			if !IsValid(config.Minion) or !IsValid(self.Owner) or !self.Owner:Alive() then
				SafeRemoveEntity(self.eff)
				SafeRemoveEntity(self)
			end		
		end
		if SERVER and IsValid( self.Owner ) then 
			local own = self.Owner
			if self:IsOnFire() then 
				self:Extinguish() 
			end 
			if own:IsOnFire() then 
				own:Extinguish() 
			end
			local top = Vector( math.sin( tic )*own:OBBMaxs().x*4, math.cos( tic )*own:OBBMaxs().x*4, own:OBBMaxs().z +math.sin( tic*2 )*5 )
			local tr = util.TraceLine( {
				start = own:EyePos(),
				endpos = own:EyePos() + top,
				filter = { own, self },
				mask = MASK_SHOT_HULL
			} )
			local vel = tr.HitPos + tr.HitNormal*20  
			local ang = self:GetVelocity():Angle().yaw 
			vel = ( vel - self:EyePos() )  local spd = math.max( vel:Length(), 0 )
			vel:Normalize() 
			self:SetLocalVelocity( vel * spd * 5 ) 
			if self:WorldSpaceCenter():Distance( own:EyePos() + top ) >= 2048 then
				self:SetPos( own:EyePos() + top ) 
			end
			local def = self:GetAngles().yaw  
			def = Lerp( 0.2, def, ang  )  
			self:SetAngles( Angle( 0, def, 0 ) )

			if self.vitesseRegene <= CurTime() then
				for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
					if IsValid(v) and v != own and v != config.Minion then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( self:GetPos() )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
					if v:IsPlayer() and v != own and (own:Health() + config.stoleVie < own:GetMaxHealth()) then
						own:SetHealth(own:Health()+config.stoleVie)
					elseif v:IsNPC() and v != own and (own:Health() + config.stoleVie < own:GetMaxHealth()) then
						own:SetHealth(own:Health()+config.stoleVie)
					end
				end
		
				if (own:Health() + config.addVie < own:GetMaxHealth()) then
					own:SetHealth(own:Health()+config.addVie)
				elseif (own:Health() + config.addVie < own:GetMaxHealth()) then
					own:SetHealth(own:Health()+config.addVie)
				elseif (own:Health() + config.addVie >= own:GetMaxHealth()) then
					own:SetHealth(own:GetMaxHealth())
				end
				self.vitesseRegene = CurTime() + config.vitesseRegene
			end
		end 

		

		return true
	end
	function ENT:Use( act ) 
		if self.Dead then 
			return 
		end 
		local own = self.Owner
		if IsValid( own ) and act == own then 
			self:feeKill() 
		end
	end
	function ENT:feeKill()
		if self.Dead then 
			return 
		end 
		SafeRemoveEntity(self.eff)
		SafeRemoveEntity(self)
		local own = self.Owner
		self.Dead = true 
		self:EmitSound( "Underwater.BulletImpact" )
	end
	function ENT:OnRemove()
        config.switch = true
    end
	function ENT:OnTakeDamage( dmg ) 
		if self.Dead or dmg:GetDamage() <= 0 then 
			return 
		end 
		self:RemoveAllDecals()
		if IsValid( dmg:GetAttacker() ) and IsValid( self.Owner ) and dmg:GetAttacker() == self.Owner then 
			return 
		end
		local atk = dmg:GetAttacker()  
		local own = self.Owner
		if IsValid( own ) and IsValid( config.Minion ) and config.Minion == self and IsValid( atk ) and ( ( atk:IsPlayer() and atk:Alive() ) or ( atk:IsNPC() and atk:GetNPCState() != NPC_STATE_DEAD ) ) then
			if !istable( own.Mint2 ) then 
				own.Mint2 = {} 
			end 
			own.Mint2[ atk:EntIndex() ] = true 
		end
		self.Regen = -1  
		if dmg:GetDamage() >= self:Health() then 
			self:feeKill()
		else 
			self:SetHealth( math.max( 0, self:Health() - dmg:GetDamage() ) )
			self:StopSound( "Glass.BulletImpact" ) 
			self:EmitSound( "Glass.BulletImpact" )
		end
	end
	if CLIENT then 
		function ENT:Draw() 
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end 
	end
	scripted_ents.Register( ENT, "fee" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "heal pet"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Upper = 0 
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE )  
		self:SetMoveType( MOVETYPE_NONE )
		self:SetColor(Color(60,255,60,255))
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale(0,0)
		self:SetModelScale(3,0.7)
		self:SetPos( self:GetPos() ) 
		SafeRemoveEntityDelayed( self, config.tmp)
	end
	function ENT:Think()
		if SERVER then
			if !IsValid(config.Minion) then
				SafeRemoveEntity(self)
			end
			if !IsValid(zone) then
				zone = ents.Create("prop_dynamic")
				zone:SetModel( "models/hunter/misc/shell2x2.mdl" )
				zone:SetMaterial( "models/props_combine/stasisfield_beam" )
				zone:SetSolid( SOLID_NONE )  
				zone:SetMoveType( MOVETYPE_NONE )
				zone:SetRenderMode( RENDERMODE_TRANSCOLOR )
				zone:SetPos(self:GetPos())
				zone:SetParent(self)
				zone:DrawShadow( false )
				zone:SetModelScale(0,0)
				zone:SetColor(Color(0,0,0,0))
				zone:SetModelScale(config.zone/83.3,config.vitesseRegene)
				SafeRemoveEntityDelayed( zone, config.vitesseRegene)
			end

			
		end
		self:NextThink( CurTime()+ config.vitesseRegene) 
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
				util.Effect( "heal_zone_eff2", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "heal_pet" )
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
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone,config.zone))
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( config.zone/20,config.zone/15 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 1.5 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 150, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 100 ) + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone,config.zone))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 1, 3 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 5, 10 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 150, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-config.zone,config.zone),math.random(-config.zone,config.zone),math.random(-config.zone,-config.zone+100)))
				if particle then
					particle:SetLifeTime( 0 )
					particle:SetAngles( Angle( -90, CurTime() * 10, 0 ) )
					particle:SetDieTime( 1 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 200 )
					particle:SetEndSize( 300 )
					particle:SetColor( 150, 255, 200 )
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
				dlight.r = 0
				dlight.g = 255
				dlight.b = 255
				dlight.Brightness = 2
				dlight.Size = config.zone*3
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "heal_zone_eff2" )
end

-----------------------------------------------------------------------------------------------------------------------

surface.CreateFont( "Types",  { font = "Arial", size = 24, weight = 1000, antialias = true, additive = false } )

hook.Add( "HUDPaint", "Mint2HP", function() local ply = LocalPlayer()
	local ent = ply:GetNWEntity( "Mint2" )
	if IsValid( ent ) and ent:Health() > 0 and ent:GetMaxHealth() > 0 then
		local ps = ent:WorldSpaceCenter():ToScreen()
		local alp = ( 500000 - math.Clamp( ent:WorldSpaceCenter():DistToSqr( ply:EyePos() ), 0, 500000 ) )/500000*255
		draw.TextShadow( {
			text = "HP: "..ent:Health(),
			pos = { ps.x, ps.y },
			font = "Types",
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color( 0, 255, 157, alp )
		}, 1, alp )
	end
end )