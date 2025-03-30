AddCSLuaFile()

SWEP.PrintName 		      = "Os 4" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 54
SWEP.UseHands = true
SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
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

SWEP.Category             = "OS"

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

local config = {}
config.dmg1 = 0
config.dmg2 = 0
config.dmgzone1 = 25
config.dmgzone2 = 25
config.tmp = 3 -- temps de la tete

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end


			local own = self:GetOwner()
			local pos = own:GetEyeTrace().HitPos
			local ang = Angle(0,own:GetAngles().y,0):Forward()

			local dragTorn = ents.Create("env_smokestack")
			dragTorn:SetKeyValue("smokematerial", "swarm/particles/particle_smokegrenade1.vmt")
			dragTorn:SetKeyValue("rendercolor", "130, 10, 130" )
			dragTorn:SetKeyValue("targetname","dragTorn")
			dragTorn:SetKeyValue("basespread","400")
			dragTorn:SetKeyValue("spreadspeed","300")
			dragTorn:SetKeyValue("speed","300")
			dragTorn:SetKeyValue("startsize","20")
			dragTorn:SetKeyValue("endzide","0")
			dragTorn:SetKeyValue("rate","500")
			dragTorn:SetKeyValue("jetlength","1000")
			dragTorn:SetKeyValue("twist","100")
			dragTorn:SetPos(pos + Vector(0,0,100) + ang*-300)
			dragTorn:Spawn()
			dragTorn:Fire("turnon","",0)
			dragTorn:Fire("Kill","",2.8)



			local dragEff = ents.Create("dragon_eff")
			dragEff:SetPos(pos+ Vector(0,0,240)+ ang*-300)
			dragEff:DrawShadow(false)
			dragEff:SetOwner( own )
			dragEff:SetAngles(Angle(260,self.Owner:GetAngles().y,0))
			dragEff:Spawn()
			dragEff:Activate()

			timer.Simple(0.3,function()
				if IsValid(own) and IsValid(self) then 

					local drag = ents.Create("dragon_head")
					drag:SetPos(pos)
					drag:DrawShadow(false)
					drag:SetOwner( own )
					drag:SetAngles(Angle(260,self.Owner:GetAngles().y,0))
					drag:Spawn()
					drag:Activate()

					util.ScreenShake( drag:GetPos() + Vector(0,0,100), 40, 8, 4, 800 )
					drag:EmitSound("npc/fast_zombie/fz_alert_close1.wav",100,30)

					timer.Create("wallup"..drag:EntIndex(),0.01,40,function()
						if IsValid(drag) then
							drag:SetPos(drag:GetPos()+Vector(0,0,20))
						end
					end)
		
					timer.Simple(config.tmp,function()
						timer.Create("wallup"..drag:EntIndex(),0.01,40,function()
							if IsValid(drag)  then
								drag:SetPos(drag:GetPos()-Vector(0,0,20))
							end
						end)
					end)
				end
			end)
			

			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
end

function SWEP:SecondaryAttack()
	return false
end

-------------------------------------------------------------------------------------------------------------


function SWEP:Holster()

	return true
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "drag"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/mailer/wow_props/hunter_dragonhead.mdl" )
		self:SetModelScale(10,0.3)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE)
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed(self,config.tmp+2.5)

		local own = self.Owner
		for k,v in pairs(ents.FindInSphere(self:GetPos() + Vector(0,0,50) ,500)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( self )
				dmginfo:SetInflictor( self )
				v:TakeDamageInfo(dmginfo)
			end
		end  
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			
		end
	end
	scripted_ents.Register( ENT, "dragon_head" )
end
if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "drageff"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE)
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed(self,config.tmp+1)
	end
	function ENT:Think() if !SERVER then return end self:NextThink(CurTime()+0.2)
	local own = self.Owner
	for k,v in pairs(ents.FindInSphere(self:GetPos() ,500)) do
		if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_GENERIC  )
			dmginfo:SetDamage( math.random(config.dmgzone1,config.dmgzone2) )
			dmginfo:SetDamagePosition( self:GetPos()  )
			dmginfo:SetAttacker( own )
			dmginfo:SetInflictor( own )
			v:TakeDamageInfo(dmginfo)
		end
	end  
	return true
end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "drag_zone_effect", ef )
			end
		end
	end
	scripted_ents.Register( ENT, "dragon_eff" )
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
				for i=1, 15 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 ) - Vector(0,0,130)
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 8, 12 )
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
						particle:SetColor( 10, 10, 10 )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 5 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 ) - Vector(0,0,130)
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
						particle:SetColor( 130, 10, 130 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 20 do
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 10, 600 )- Vector(0,0,130))
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
				dlight.Pos = own:WorldSpaceCenter() - Vector(0,0,130)
				dlight.r = 255
				dlight.g = 255
				dlight.b = 255
				dlight.Brightness = 5
				dlight.Size = 500
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "drag_zone_effect" )
end