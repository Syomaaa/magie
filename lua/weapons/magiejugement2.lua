AddCSLuaFile()

SWEP.PrintName 		      = "Jugement 2" 
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

config.dmg1 = 200 
config.dmg2 = 200    -- degat
config.zone = 300

SWEP.Cooldown = 10

SWEP.ActionDelay = 1

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
   
	self:SetHoldType( "magic" )
end

function SWEP:CheckAttaque( attaque )
	if self.Owner:GetNWBool(tostring(attaque), false) == true then
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	    local own = self:GetOwner()
	    local pos = own:GetEyeTrace().HitPos
	    local ang = Angle(0,own:GetAngles().y,0)
		local chaine = ents.Create( "sceau_chaine2" ) 
		chaine:SetPos(pos + ang)
		chaine:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) )
		chaine:Spawn() 
		chaine:Activate() 

		timer.Simple(0.5,function()
			if IsValid(self) then
				local pos_tab = {
					Vector(185,0,-140),
					Vector(160,70,-140),
					Vector(90,100,-140),
					Vector(19,75,-140),
					Vector(-20,10,-140),
					Vector(5,-70,-140),
					Vector(75,-100,-140),
					Vector(150,-75,-140),
					
					Vector(185*2,0,-140),
					Vector(160*2,70*2,-140),
					Vector(90*2,100*2,-140),
					Vector(19*2,75*2,-140),
					Vector(-20*2,10*2,-140),
					Vector(5*2,-70*2,-140),
					Vector(75*2,-100*2,-140),
					Vector(150*2,-75*2,-140),

					Vector(185*4,0,-140),
					Vector(160*4,70*4,-140),
					Vector(90*4,100*4,-140),
					Vector(19*4,75*4,-140),
					Vector(-20*4,10*4,-140),
					Vector(5*4,-70*4,-140),
					Vector(75*4,-100*4,-140),
					Vector(150*4,-75*4,-140)
				}
				local pos_ang = {
					Angle(40,0,0),
					Angle(40,40,0),
					Angle(40,90,0),
					Angle(40,130,0),
					Angle(40,170,0),
					Angle(40,230,0),
					Angle(40,270,0),
					Angle(40,310,0),
					Angle(40,0,0),
					Angle(40,40,0),
					Angle(40,90,0),
					Angle(40,130,0),
					Angle(40,170,0),
					Angle(40,230,0),
					Angle(40,270,0),
					Angle(40,310,0),
					Angle(40,0,0),
					Angle(40,40,0),
					Angle(40,90,0),
					Angle(40,130,0),
					Angle(40,170,0),
					Angle(40,230,0),
					Angle(40,270,0),
					Angle(40,310,0)
				}

				for i=1,24 do
					if self.Owner:Alive() and IsValid(self) then
						local spike = ents.Create("chains")

						if i <=8 then
							spike:SetPos( chaine:GetPos() + pos_tab[i] - Vector(80,0,-50))
						elseif i <=16 then
							spike:SetPos( chaine:GetPos() + pos_tab[i] - Vector(160,0,-70))
							spike:SetModelScale(1.5,0)
						else
							spike:SetPos( chaine:GetPos() + pos_tab[i] - Vector(320,0,-90))
							spike:SetModelScale(2,0)
						end
						spike:SetAngles(pos_ang[i])
						spike:Spawn()

						spike.IsEarthMagicProp = true
						spike.IsShield = true
						spike.Owner = self.Owner

						spike:StopSound( ")npc/roller/blade_out.wav" ) 
						spike:EmitSound( ")npc/roller/blade_out.wav" ,70,100,0.6) 

						spike.RockOwner = self.Owner

						local plyang = self.Owner:GetAngles()
						plyang.pitch = -90
						plyang.roll = plyang.roll
						plyang.yaw = plyang.yaw

						local DustAngle = plyang
						local BigDust = EffectData()
						BigDust:SetOrigin(spike:GetPos() + Vector(0,0,100))
						BigDust:SetNormal(DustAngle:Forward())
						BigDust:SetScale(100)
						util.Effect("ThumperDust",BigDust)
						util.ScreenShake( self.Owner:GetPos(), 2, 7, 1, 400 )

						timer.Create("spike_up_shield" .. spike:EntIndex(),0.01,20,function()
							if IsValid(spike) then
								spike:SetPos(spike:GetPos() + Vector(0,0,8))
							end	
						end)
						timer.Simple(1.2,function()
							timer.Create("spike_down" .. spike:EntIndex(),0.01,30,function()
								if IsValid(spike) then
									spike:SetPos(spike:GetPos() - Vector(0,0,8))
								end	
							end)
							timer.Create("spike_down_finish" .. spike:EntIndex(),1,1,function()
								if IsValid(spike) then
									SafeRemoveEntity(spike)
								end	
							end)
						end)
					end
				end
				local own = self.Owner
				for k,v in pairs(ents.FindInSphere(pos ,config.zone)) do
					if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( pos )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
		end)
		
		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as 10s de cooldown !" )
	end
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Think()
end

function SWEP:SecondaryAttack()
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
		self:SetModelScale(7,0.5)
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetPos( self:GetPos() ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR)
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:Think() if !SERVER then return end
		local own = self.Owner
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
				util.Effect( "sceau_chaine_eff2", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "sceau_chaine2" )
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
		self:SetModel( "models/heroes/pudge/pudge_chain.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE ) 
		self:SetPos( self:GetPos() ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR)
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "chains" )
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
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 400 ) - Vector(0,0,20)
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
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 400 )- Vector(0,0,20)
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
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 400 )- Vector(0,0,20))
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
	effects.Register( EFFECT, "sceau_chaine_eff2" )
end