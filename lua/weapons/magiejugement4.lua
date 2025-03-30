AddCSLuaFile()

SWEP.PrintName 		      = "Jugement 4" 
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

SWEP.Cooldown = 60

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 350
config.dmg2 = 350

config.dmgpunch1 = 350
config.dmgpunch2 = 350

config.zonePunch = 350

config.zone = 500
config.push = 300

config.tmp = 30 -- temps du pet

config.switch = false

local ENT = {}
ENT.PrintName = "monster"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true  ENT.Tick = 0  ENT.Dead = false
ENT.Effect = false  ENT.Owner = nil  ENT.Gre = 1  ENT.NextSnd = CurTime() + math.Rand( 3, 5 )
ENT.Enemy = nil  ENT.NextFind = 0  ENT.ClBeam = false

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
   
	self:SetHoldType( "magic" )
end

--------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	config.switch = false

	local own = self.Owner
	local pos = own:GetShootPos()
	if IsValid( own.Minion ) then own:PrintMessage( HUD_PRINTCENTER, "Un seul minion à la fois !" ) return end
		
		local monster = ents.Create( "monster_jugement" )
		if SERVER then
			monster:EmitSound( "npc/ichthyosaur/water_growl5.wav" )
		end
		monster:SetPos( own:GetShootPos() +own:EyeAngles():Forward()*40 )
		monster:SetAngles( own:EyeAngles() ) 
		monster:SetOwner( own )
		monster:Spawn() 
		monster:Activate()
		own:DeleteOnRemove( monster )
		monster:SetPhysicsAttacker( own )
		self.demon = monster
		own.Minion = monster 
		own:SetNWEntity( "Mint2", monster )
		undo.Create( "monster" ) undo.AddEntity( monster ) undo.SetPlayer( own ) undo.Finish()

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

function SWEP:Holster()
	return true
end

--------------------------------------------------------------------------------------------------------------

function CoupAttack( tar, atk, per, fce, own )
	if !isvector( fce ) or ( isnumber( tar.Immune ) and tar.Immune > CurTime() ) then fce = Vector( 0, 0, 0 ) end fce = fce * 0.1
	if tar:IsOnFire() then tar:Extinguish() end if isnumber( per ) and atk != tar then

		for k,v in pairs(ents.FindInSphere(tar:GetPos(),config.zonePunch)) do
			if IsValid(v) and v != atk then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmgpunch1,config.dmgpunch2) )
				dmginfo:SetDamagePosition( tar:GetPos() )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
			end
		end

		local ex = EffectData()
		ex:SetOrigin(atk:GetPos() + atk:GetAngles():Forward()*(config.zonePunch/2))
		util.Effect("wall",ex) 

		local physExplo = ents.Create( "env_physexplosion" )
		physExplo:SetPos( atk:GetPos() + atk:GetAngles():Forward()*(config.zonePunch/2))
		physExplo:SetKeyValue( "magnitude", config.push )
		physExplo:SetKeyValue( "radius", config.zonePunch* 3)
		physExplo:SetKeyValue( "spawnflags", "2" )
		physExplo:Spawn()
		physExplo:Fire( "Explode", "", 0 )

		local Shake = ents.Create( "env_shake" )
		Shake:SetPos( atk:GetPos() + atk:GetAngles():Forward()*(config.zonePunch/2) )
		Shake:SetKeyValue( "amplitude", "4" )
		Shake:SetKeyValue( "radius", config.zonePunch*3 )
		Shake:SetKeyValue( "duration", "2" )
		Shake:SetKeyValue( "frequency", "255" )
		Shake:SetKeyValue( "spawnflags", "4" )
		Shake:Spawn()
		Shake:Activate()
		Shake:Fire( "StartShake", "", 0 )

		sound.Play( "ambient/explosions/explode_2.wav",  tar:GetPos() , 80, 180,0.5) 
	end
end

function ChaineAttack( tar, atk, per, fce, own )
	if !isvector( fce ) or ( isnumber( tar.Immune ) and tar.Immune > CurTime() ) then fce = Vector( 0, 0, 0 ) end fce = fce * 0.1
	if tar:IsOnFire() then tar:Extinguish() end if isnumber( per ) and atk != tar then

			local pos_tab = {
				Vector(185/2,0,-140),
				Vector(160/2,70/2,-140),
				Vector(90/2,100/2,-140),
				Vector(19/2,75/2,-140),
				Vector(-20/2,10/2,-140),
				Vector(5/2,-70/2,-140),
				Vector(75/2,-100/2,-140),
				Vector(150/2,-75/2,-140)
			}
			local pos_ang = {
				Angle(120,0,0),
				Angle(120,40,0),
				Angle(120,90,0),
				Angle(120,130,0),
				Angle(120,170,0),
				Angle(120,230,0),
				Angle(120,270,0),
				Angle(120,310,0)
			}

			for i=1,8 do
				local spike = ents.Create("prop_physics")
				spike:SetModel("models/heroes/pudge/pudge_chain.mdl")
				spike:SetModelScale(3,0.3)
				spike:SetPos( tar:GetPos() + pos_tab[i] - Vector(40,0,-30))
				spike:SetAngles(pos_ang[i])
				spike:Spawn()

				spike.IsEarthMagicProp = true
				spike.IsShield = true
				spike.Owner = atk
				spike:StopSound( ")npc/roller/blade_out.wav" ) 
				spike:EmitSound( ")npc/roller/blade_out.wav" ,70,100,0.6) 
				sound.Play( "ambient/explosions/explode_2.wav",  spike:GetPos() , 80, 180,0.5) 

				undo.AddEntity( spike )

				spike.RockOwner = atk
				spike:GetPhysicsObject():EnableMotion(false)

				local plyang = atk:GetAngles()
				plyang.pitch = -90
				plyang.roll = plyang.roll
				plyang.yaw = plyang.yaw

				local DustAngle = plyang
				local BigDust = EffectData()
				BigDust:SetOrigin(spike:GetPos() + Vector(0,0,100))
				BigDust:SetNormal(DustAngle:Forward())
				BigDust:SetScale(100)
				util.Effect("ThumperDust",BigDust)
				util.ScreenShake( atk:GetPos(), 2, 7, 1, 400 )

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
							spike:Remove()
						end	
					end)
				end)
			end

			for k,v in pairs(ents.FindInSphere(tar:GetPos(),600)) do
				if IsValid(v) and v != atk then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(350,350) )
					dmginfo:SetDamagePosition( tar:GetPos() )
					dmginfo:SetDamageForce((tar:GetPos() - v:GetPos())*-100 + Vector(0,0,20*1000))
					dmginfo:SetAttacker( atk )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end
	end
end

if true then

	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/asterius/asterius.mdl" )
		self:SetMoveType( MOVETYPE_NOCLIP ) 
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON ) 
		self:DrawShadow( false )
		self:SetModelScale(2,0.2)
		self:SetBloodColor( DONT_BLEED )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:UseTriggerBounds( self:OBBMins(), self:OBBMaxs() )
		self.Light = ents.Create( "light_dynamic" )
		self.Light:SetPos( self:WorldSpaceCenter() ) 
		self.Light:SetAngles( self:GetAngles() ) 
		self.Light:SetKeyValue( "_light", "80 0 130 255" )
		self.Light:SetKeyValue( "brightness", "5" ) 
		self.Light:SetOwner( self ) self.Light:SetParent( self )
		self.Light:SetKeyValue( "distance", "100" )
		self.Light:Spawn() 
		self.Light:Activate() self:DeleteOnRemove( self.Light )
		self.Light:Fire( "TurnOn" )
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	function ENT:Think() self:NextThink( CurTime() ) 
		self.Tick = self.Tick + 0.01  
		local tic = self.Tick
		if self.Dead then return end

		if self.anime != true then 
			self.sequence = self:LookupSequence("idle")
		end
		self.nbAtk = math.random(0,1)
		if SERVER and ( !IsValid( self.Owner ) or !self.Owner:IsPlayer() or !self.Owner:Alive() or !IsValid( self.Owner.Minion ) or self.Owner.Minion != self ) then
			self:monsterKill() return
		end
		if SERVER and IsValid( self.Owner ) then local own = self.Owner
			if self:IsOnFire() then self:Extinguish() end if own:IsOnFire() then own:Extinguish() end
			if self.NextFind < CurTime() then self.NextFind = CurTime() + 2
				local tar = nil  local dis = -1
				for k, v in pairs( ents.FindInSphere( self:WorldSpaceCenter(), 700 ) ) do
					if !IsValid( v ) or ( !v:IsPlayer() and !v:IsNPC() ) or ( ( v:IsPlayer() and !v:Alive() ) or ( v:IsNPC() and v:GetNPCState() == NPC_STATE_DEAD ) )
					or v == own or v == self then continue end local ddd = v:WorldSpaceCenter():DistToSqr( self:WorldSpaceCenter() )
					
					if dis == -1 or ddd < dis then
						local tr = util.TraceLine( {
							start = self:WorldSpaceCenter(),
							endpos = v:WorldSpaceCenter(),
							filter = { own, self },
						} )
						if !tr.Hit or tr.Entity == v then dis = ddd  tar = v end
					end
				end 
				self.Enemy = tar 
				self.anime = false
				if IsValid( self.Enemy ) then
					local ppp = ( self.Enemy:WorldSpaceCenter() - self:WorldSpaceCenter() - Vector(0,0,70)):GetNormal()*1000
					if self.nbAtk == 0 then
						self.sequence = self:LookupSequence("attack_melee2")
						self:SetSequence(self.sequence)
						timer.Simple(1,function()
							if IsValid(self) then
								ChaineAttack( self.Enemy, self.Owner, 5, ppp, self)
								self.sequence = self:LookupSequence("idle")
							end
						end)
						timer.Simple(1,function()
							if IsValid(self) then
								self.sequence = self:LookupSequence("idle")
							end
						end)
					else
						self.sequence = self:LookupSequence("attack_melee")
						self:SetSequence(self.sequence)
						timer.Simple(4,function()
							if IsValid(self) then
								CoupAttack( self.Enemy, self.Owner, 5, ppp, self)
							end
						end)
						timer.Simple(1,function()
							if IsValid(self) then
								self.sequence = self:LookupSequence("idle")
							end
						end)
					end
					self.anime = true
				end
			end
			local top = Vector( math.sin( tic )*own:OBBMaxs().x*4, math.cos( tic )*own:OBBMaxs().x*4, own:OBBMaxs().z +math.sin( tic*2 )*5 )
			local enm = self.Enemy  if IsValid( enm ) then
				local psp = ( enm:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormal()*own:OBBMaxs().x*4
				
			end
			local tr = util.TraceLine( {
				start = own:GetPos(),
				endpos = own:GetPos() + own:GetAngles():Forward()*-150,
				filter = { own, self },
				mask = MASK_SHOT_HULL
			} )
			local vel = tr.HitPos + tr.HitNormal*60  
			local ang = self:GetVelocity():Angle().yaw 
			if IsValid( enm ) then 
				ang = ( enm:WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormal():Angle().yaw 
			end
			vel = ( vel - self:EyePos() )  
			local spd = math.max( vel:Length(), 0 )
			vel:Normalize() 
			self:SetLocalVelocity( vel * spd * 5 ) 
			if self:WorldSpaceCenter():Distance( own:EyePos() ) >= 2048 then
				self:SetPos( own:GetPos() ) 
				self:SetParent( own )  
			end
			local def = self:GetAngles().yaw  
			def = Lerp( 0.2, def, ang )  
			self:SetAngles( Angle( 0, def , 0 ) )
		end 
		if SERVER then
			self:ResetSequence(self.sequence)
			self:SetPlaybackRate( math.Clamp( self:GetVelocity():Length(), 50, 150 )/100 )
		end
		return true
	end
	function ENT:Use( act ) if self.Dead then return end local own = self.Owner
		if IsValid( own ) and act == own then self:monsterKill() end
	end
	function ENT:monsterKill()
		if self.Dead then return end local own = self.Owner
		self.Dead = true self:EmitSound( "Underwater.BulletImpact" )
		SafeRemoveEntityDelayed( par, 1 )  self:Remove()
	end
	function ENT:OnRemove()
        config.switch = true
    end
	
	scripted_ents.Register( ENT, "monster_jugement" )
end

-----------------------------------------------------------------------------------------------------------------------

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end