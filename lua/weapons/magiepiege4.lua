AddCSLuaFile()

SWEP.PrintName 		      = "Piège 4" 
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

SWEP.Category             = "Piège"

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
config.dmg1 = 250
config.dmg2 = 250    -- degat en continue de zone
config.flame1 = 30
config.flame2 = 40     --nombre de flame entre .. et ..
config.tmp = 15     -- temps du piege
config.tmpAct = 1.3     -- delai entre chaque activation de flamme
config.zone = 500


--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

game.AddParticles( "particles/firemagic01.pcf" )
PrecacheParticleSystem( "firemagic_shield" )
PrecacheParticleSystem( "spell_fireball_small_red" )
PrecacheParticleSystem( "asplode_hoodoo" )

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

			local own = self:GetOwner()
			local pos = own:GetEyeTrace().HitPos
			local ang = Angle(0,own:GetAngles().y,0)

			local piege_zone = ents.Create( "piege4" ) 
			piege_zone:SetAngles(  Angle( ang.pitch, ang.yaw, 0 ) ) 
			piege_zone:SetPos( pos + ang) 
			piege_zone.Owner = own
			piege_zone:Spawn() 
			piege_zone:Activate() 
			own:DeleteOnRemove( piege_zone )
			piege_zone:EmitSound( "weapons/fx/nearmiss/bulletLtoR07.wav" )


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

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = ""
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale( 0, 0 )
		self:SetModelScale( config.zone/83.3, 0.7 ) 
		self:SetColor( Color( 220,200,10,255 ) )
		local own = self.Owner
		config.alp = 255
		SafeRemoveEntityDelayed( self, config.tmp )
		
	end
	function ENT:Think()
		local own = self.Owner
		if SERVER then
			timer.Create("alpha"..self:EntIndex(),0.1,25.5,function()
				if IsValid(self) && config.alp > 10 then
					config.alp = config.alp - 10
					self:SetColor( Color( 220,200,10,config.alp ) )
				end
			end)
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					if IsValid(self) then
						if IsValid(self) and self:WaterLevel() == 0 then
							for i=1,math.random(config.flame1,config.flame2) do
								if IsValid(self) then
									local startpos = self:GetPos() + Vector(math.Rand(-config.zone/1.5,config.zone/1.5),math.Rand(-config.zone/1.5,config.zone/1.5),0)
									local traceworld = {}
									traceworld.start = startpos
									traceworld.endpos = traceworld.start - Vector(0,0,400)
									traceworld.fliter = function(ent) if !ent:IsWorld() then return false end end
									traceworld.mask = MASK_SOLID_BRUSHONLY
									local trw = util.TraceLine(traceworld)
									if trw.HitWorld then 
										ParticleEffect( "firemagic_shield", trw.HitPos,Angle(0,0,0))
										local randfire = math.random(1,2)
										if randfire == 1 then
											sound.Play( "ambient/fire/mtov_flame2.wav" , trw.HitPos, 75, 100, 0.7 )
										else
											sound.Play( "ambient/fire/ignite.wav" , trw.HitPos, 75, 100, 0.7 )
										end
										local decpos1 = trw.HitPos + trw.HitNormal
										local decpos2 = trw.HitPos - trw.HitNormal
										local dmginfo = DamageInfo()
										config.alp = 180
										for k,v in pairs(ents.FindInSphere(v:GetPos(),50)) do
											if (v:IsNPC() or v:IsPlayer() or type(v) == "NextBot") and !v:IsOnFire() then
												v:Ignite(10)
											end
										end
									end
								end
							end
						end
					end
				end
			end
			for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
				if IsValid(v) and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_BURN  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
					dmginfo:SetDamagePosition( self:GetPos() )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self )
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
		self:NextThink( CurTime() + config.tmpAct ) 
		return true
	end
	scripted_ents.Register( ENT, "piege4" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "tmpZone2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
		self:SetSolid( SOLID_NONE ) self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 255,255,255,255 ) )
		self:SetModelScale( 0, 0 ) local own = self.Owner
		SafeRemoveEntityDelayed( self, config.tmpAct )
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "piege_flame_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "piege_feu" )
end

if SERVER then return end

if CLIENT then
	local EFFECT={}
		
	function EFFECT:Init( data )
		self.Origin = data:GetOrigin()
		self.Scale = data:GetScale()
		self.Ent = data:GetEntity()
		for i=1,2 do
			local em = ParticleEmitter( self.Origin )
			local particle = em:Add( "particle/newfire" .. math.random(1,6), self.Origin  )
			particle:SetVelocity(VectorRand()*50)
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local matrand = math.random(30,50)
			particle:SetStartSize(matrand)
			particle:SetEndSize( matrand + 5 )
			particle:SetRoll( math.Rand( -255,255  ) )
			particle:SetRollDelta(math.Rand( -10, 10 ))
			if math.random(1,2) < 2 then
				particle:SetColor( 255, 191, 0 )
			else
				particle:SetColor( 255, 255, 255 )
			end
			particle:SetCollide( true )
			particle:SetBounce( 0.05 )   
			particle:SetAirResistance( 8 )
			em:Finish()
		end
	end
		
	function EFFECT:Think( )
		return false 
	end
		   
	function EFFECT:Render() 
	end
		
		
	effects.Register(EFFECT,"piege_flame_effect")
end