AddCSLuaFile()

SWEP.PrintName 		      = "Miroir 4" 
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

SWEP.Cooldown = 20

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 95
config.dmg2 = 95

config.tmp = 1

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

if CLIENT then
	CreateClientConVar("pc_effect_type","1",true, true)
	CreateClientConVar("pc_effect_length","8.40",true, true)
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if CLIENT then return end

		local playertrace = self.Owner:GetEyeTrace()
		local trace = {}
		trace.start = playertrace.HitPos
		trace.endpos = trace.start + Vector(0,0,80000)
		trace.filter = function(ent) if !ent:IsWorld() then return false end end
			local traceworld = util.TraceLine(trace)
				if traceworld.HitSky then
					local Ang = self.Owner:GetAngles()
					Ang.pitch = 0
					Ang.roll = Ang.roll
					Ang.yaw = Ang.yaw - 180
					local ent
					local pos
					local tracesensor = {}
					tracesensor.start = playertrace.HitPos
					tracesensor.endpos = tracesensor.start + Vector(0,0,4200)
					tracesensor.filter = function(ent) if !ent:IsWorld() then return false end 
				end
				local traceworldsensor = util.TraceLine(tracesensor)
				if traceworldsensor.HitSky then
					pos = traceworldsensor.HitPos - Vector(0,0,40)
				else
					pos = playertrace.HitPos + Vector(0,0,4000)
				end
				local height = 4200
				self.SensorEnt = ents.Create("prop_dynamic")
				self.SensorEnt:SetPos(pos)
				self.SensorEnt:SetAngles(Ang)
				self.SensorEnt:SetModel("models/gibs/gunship_gibs_sensorarray.mdl")
				self.SensorEnt:Spawn()
				self.SensorEnt:Activate()
				self.SensorEnt.IsSensorEntPC = true
				self.SensorEnt.BeamType = tonumber(self.Owner:GetInfo("pc_effect_type"))
				self.SensorEnt.EntHeight = height
				self.SensorEnt:SetMaterial("models/effects/vol_light001")
				if IsValid(self) and IsValid(self.Owner) then
					self.SensorEnt.Caller = self.Owner
				else
					self.SensorEnt.Caller = game:GetWorld()
				end
					self.SensorEnt.BeamDamageCooldown = 0
				if SERVER then
					if IsValid(self.SensorEnt) then
						self.SensorEnt.BeamTurnedOn = true
					end
					local tracebeam = {}
					tracebeam.start = trace.start
					tracebeam.endpos = trace.start - Vector(0,0,90000)
					tracebeam.filter = function(ent) if !ent:IsWorld() then return false end 
				end
				local traceworldbeam = util.TraceLine(tracebeam)
				if traceworldbeam.Hit then
					if game.SinglePlayer() then
						local LaserBeam = EffectData()
						LaserBeam:SetStart(self.SensorEnt:GetPos())
						LaserBeam:SetOrigin(traceworldbeam.HitPos)
						LaserBeam:SetEntity(self.SensorEnt)
						if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
							util.Effect("pc_particle_cannon",LaserBeam)
						end
						local LaserParticle = EffectData()
						LaserParticle:SetStart(self.SensorEnt:GetPos())
						LaserParticle:SetOrigin(traceworldbeam.HitPos)
						LaserParticle:SetNormal(traceworldbeam.HitNormal)
						LaserParticle:SetEntity(self.SensorEnt)
						if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
							util.Effect("pc_particle_cannon_particle",LaserBeam)
						end
					else
						timer.Simple(0.002,function()
							if IsValid(self.SensorEnt) then
								local LaserBeam = EffectData()
								LaserBeam:SetStart(self.SensorEnt:GetPos())
								LaserBeam:SetOrigin(traceworldbeam.HitPos)
								LaserBeam:SetEntity(self.SensorEnt)	
								if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
									util.Effect("pc_particle_cannon",LaserBeam)
								end
								local LaserParticle = EffectData()
								LaserParticle:SetStart(self.SensorEnt:GetPos())
								LaserParticle:SetOrigin(traceworldbeam.HitPos)
								LaserParticle:SetNormal(traceworldbeam.HitNormal)
								LaserParticle:SetEntity(self.SensorEnt)
								if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
									util.Effect("pc_particle_cannon_particle",LaserBeam)		
								end
							end
						end)
					end
					self.Target = ents.Create( "info_target" )
					self.Target:SetPos(traceworldbeam.HitPos)
					self.Target:Spawn()
					self.Shake = ents.Create( "env_shake" )
					self.Shake:SetPos( traceworldbeam.HitPos )
					self.Shake:SetKeyValue( "amplitude", "5" )
					self.Shake:SetKeyValue( "radius", "1000" )
					self.Shake:SetKeyValue( "duration", "3" )
					self.Shake:SetKeyValue( "frequency", "255" )
					self.Shake:SetKeyValue( "spawnflags", "4" )
					self.Shake:Spawn()
					self.Shake:Activate()
					self.Shake:Fire( "StartShake", "", 0 )
					self.particle = ents.Create("info_particle_system")
					self.particle:SetAngles(self.Shake:GetAngles())
					if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
						self.particle:SetKeyValue("start_active",tostring(1))
					end
					self.particle:Spawn()
					self.particle:Activate()
					self.particle:SetPos(self.Shake:GetPos())
					self.particle:SetParent(self.Shake)

				end
			end
		else
			if IsValid(self.SensorEnt) then
				self.SensorEnt:Remove()
			end
			self.Owner:SendLua("surface.PlaySound('common/wpn_denyselect.wav')")
		end

		SafeRemoveEntityDelayed(self.SensorEnt,config.tmp)

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
	
end

-------------------------------------------------------------------------------------------------------------

function SWEP:Think()
	if IsValid(self.Owner) and self.Owner:KeyReleased(IN_ATTACK) and SERVER then
		if IsValid(self.SensorEnt) then
			self.SensorEnt:Remove()
		end
		if IsValid(self.particle) then
			if ( self.particle.BeamSound ) then 
				self.particle.BeamSound:ChangeVolume( 0, 0.02 ) 
				self.particle.BeamSound:Stop() 
				self.particle.BeamSound = nil
				self.particle:Remove()
			end
		end
	end
	if IsValid(self.Owner) and self.Owner:KeyDown(IN_ATTACK) and SERVER then
		if IsValid(self.SensorEnt) then
			local pos
			local num = 0
			local checkforlag = 0
			self.haspath = false
			while !self.haspath  do
				local tracesensor = {}
				tracesensor.start = self.Owner:GetEyeTrace().HitPos + Vector(0,0,num)
				tracesensor.endpos = tracesensor.start + Vector(0,0,4200)
				tracesensor.filter = function(ent) if !ent:IsWorld() then return false end 
			end
			local traceworldsensor = util.TraceLine(tracesensor)
			if traceworldsensor.HitSky then
				pos = traceworldsensor.HitPos - Vector(0,0,40)
				self.haspath = true
				break
			else
			if !traceworldsensor.HitSky then
				num = num + 84
				if num >= self.SensorEnt.EntHeight then
					pos = self.Owner:GetEyeTrace().HitPos + Vector(0,0,4000)
					self.haspath = true
					break
				end
				checkforlag = checkforlag + 1
				if checkforlag >= 50 then
					break
				end
			end
		end
	end
	if IsValid(self.SensorEnt) then
		self.SensorEnt:SetPos(LerpVector( math.Clamp((1 - math.Clamp(self.SensorEnt:GetPos():Distance(pos)/1200,0,1))/20,0.005,1), self.SensorEnt:GetPos(), pos ))
			local tracebeam = {}
			tracebeam.start = self.SensorEnt:GetPos()
			tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
			tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
			local traceworldbeam = util.TraceLine(tracebeam)
			if traceworldbeam.Hit then
				if self.NextBeamEffect == nil then
					self.NextBeamEffect = 0
				end
				if self.NextBeamEffect < CurTime() then
					self.NextBeamEffect = CurTime() + 0.5
					if game.SinglePlayer() then
						local pc_particle = EffectData()
						pc_particle:SetEntity(self.SensorEnt)
						if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
							util.Effect("pc_particle_cannon_particle2",pc_particle)
						end
					else
						timer.Simple(0.002,function()
							if IsValid(self) and IsValid(self.SensorEnt) and IsValid(self.Owner) then
								local pc_particle = EffectData()
								pc_particle:SetEntity(self.SensorEnt)
								if tonumber(self.Owner:GetInfo("pc_effect_type")) == 1 then
									util.Effect("pc_particle_cannon_particle2",pc_particle)
								end
							end
						end)
					end
				end
				if self.NextBeamAttack == nil then
					self.NextBeamAttack = 0
				end
					if self.NextBeamAttack < CurTime() then
						self.NextBeamAttack = CurTime() + 0.1
						
						for k,v in pairs(ents.FindInSphere(traceworldbeam.HitPos,330)) do
							local own = self.Owner
							if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
								local dmginfo = DamageInfo()
								dmginfo:SetDamageType( DMG_ENERGYBEAM  )
								dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
								dmginfo:SetDamagePosition( traceworldbeam.HitPos )
								dmginfo:SetAttacker( self.Owner )
								dmginfo:SetInflictor( self.SensorEnt )
								v:TakeDamageInfo(dmginfo)
							end
						end
					end
					if IsValid(self.Shake) then
						self.Shake:SetPos(traceworldbeam.HitPos)
						if self.NextShake == nil then
							self.NextShake = 0
						end
						if self.NextShake < CurTime() then
							self.NextShake = CurTime() + 0.2
							self.Shake:Fire( "StartShake", "", 0 )
						end
					end
				end
			end
		end
	end
end

if SERVER then return end

local sparks = Material("effects/spark")
local solarmuzzle = Material("effects/splashwake1")
local solarmuzzle2 = Material("effects/yellowflare")
local particlecannonbeam = Material( "effects/pc_beam" )
local glow = CreateMaterial("glow01", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 3, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
local glow2 = Material( "particle/particle_glow_04_additive" )

local EFFECT={}

function EFFECT:Init(data)
self.ParentEntity = data:GetEntity()
self.BeamWidth = 20
self.BeamSpriteSize = 80
self.MinSize = 500
self.MinSize2 = 480
end

function EFFECT:Think()
if self.ParentEntity != NULL then
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
end
if !IsValid(self.ParentEntity) then return false end
return true
end

function EFFECT:Render( )
if self.ParentEntity == NULL then return end
self.StartPos = self.ParentEntity:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos
self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))

self.BeamDistance = (self.StartPos - self.Orig):Length()


local start_pos = self.StartPos
local end_pos = self.Orig
local dir = ( end_pos - start_pos );
local mindist = math.Clamp(self.MinSize + dir:Length()/8,500,500)
local mindist2 = math.Clamp(self.MinSize2 + dir:Length()/8,480,480)
local maxdist = math.Clamp(dir:Length()/200,2,15)
local increment = dir:Length()  / (tonumber(LocalPlayer():GetInfo("pc_effect_length") or 8.95));
dir:Normalize();
 
// set material
render.SetMaterial( particlecannonbeam )
 
// start the beam with 14 points
for i=1,5 do
render.StartBeam( increment  );
//
local i;
for i = 1, 10 do
	// get point
	local point = start_pos + dir * ( (i - 1) * increment ) + VectorRand() * math.random( 1, maxdist )
    render.SetMaterial( particlecannonbeam )
	// texture coords
	local tcoord = 0.5;
 
	// add point
	render.AddBeam(
		point + VectorRand()*10,
		mindist2,
		tcoord,
		Color( 255,255,255,255 )
	);
 
end
 
// finish up the beam
render.EndBeam();

end
end

effects.Register(EFFECT, "pc_particle_cannon", true)


local EFFECT2={}

function EFFECT2:Init(data)
	self.ParentEntity = data:GetEntity()
	self.Orig = data:GetOrigin()
	self.Norm = data:GetNormal()
	self.ParticleLife = CurTime() + 2
	self.ParticleTime = 0
	self.ParticleNum = 0
	self.MuzzleSize = 50
	self.MuzzleSize2 = 50
end

function EFFECT2:Think()
	if self.ParentEntity != NULL then
	self.StartPos = self.ParentEntity:GetPos()
	local tracebeam = {}
	tracebeam.start = self.StartPos
	tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
	tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
	local traceworldbeam = util.TraceLine(tracebeam)
	self.Orig = traceworldbeam.HitPos
	self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
	if self.ParticleTime < CurTime() then
	local emmiter = ParticleEmitter(self.Orig,false)
	for i=0,math.Rand(2,6) do
	local velocity = ( Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(30,70)) ):GetNormalized()
	velocity:Mul( math.Rand( 100, 125 ) )
	local particle = emmiter:Add( "effects/energysplash", self.Orig )
	particle:SetVelocity( velocity*5 )
	particle:SetDieTime( math.Rand(2,4) )
	particle:SetStartSize( math.Rand( 10, 25 ) )
	particle:SetEndSize( 2 )
	particle:SetStartAlpha( 255 )
	particle:SetEndAlpha( 0 )
	particle:SetStartLength( math.random(80,100) )
	particle:SetEndLength( math.random(30,50) )
	particle:SetAirResistance( 5 )
	particle:SetGravity( Vector(0,0,math.Rand(-200,-100)) )
	particle:SetColor( 255,255,255 )
end

self.ParticleTime = CurTime() + 0.4
end
end
if !IsValid(self.ParentEntity) then
return false 
end
return true
end

function EFFECT2:Render( )
	if self.ParentEntity == NULL then return end
	self.StartPos = self.ParentEntity:GetPos()
	local tracebeam = {}
	tracebeam.start = self.StartPos
	tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
	tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
	local traceworldbeam = util.TraceLine(tracebeam)
	self.Orig = traceworldbeam.HitPos
	self.Norm = traceworldbeam.HitNormal
	self:SetRenderBoundsWS(self.StartPos + Vector(0,0,90000), self.Orig + Vector(0,0,-90000))
	self.ParticleNum = math.Clamp(self.ParticleNum + (FrameTime()*40),0,200)
	self.MuzzleSize = math.Clamp(self.MuzzleSize + FrameTime()*1600*2,0,1000)
	self.MuzzleSize2 = math.Clamp(self.MuzzleSize2 + FrameTime()*1600*2,0,2500)
	render.SetMaterial(solarmuzzle)
	render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize,self.MuzzleSize,Color(255,255,255,255),CurTime()*-720)
	render.SetMaterial(solarmuzzle2)
	render.DrawQuadEasy(self.Orig + self.Norm*2,self.Norm,self.MuzzleSize2,self.MuzzleSize2,Color(255,255,255,255),CurTime()*-720)
	render.SetMaterial(glow)
	render.DrawSprite(self.Orig + Vector(0,0,20),1000,1000,Color(255,255,255,255))
	render.SetMaterial(glow2)
	render.DrawQuadEasy(self.StartPos,self.ParentEntity:GetAngles():Up()*-1,self.MuzzleSize,self.MuzzleSize,Color(255,255,255,255),CurTime()*-720)
end

	effects.Register(EFFECT2, "pc_particle_cannon_particle", true)


local EFFECT={}
    
function EFFECT:Init( data )
        self.Ent = data:GetEntity()
        self:SetModel("models/XQM/Rails/gumball_1.mdl")
		self:SetMaterial("lights/White002")
		self:SetRenderMode( 4 )
		self.Alpha = 120
		self.Alpha2 = 255
		self:SetColor(Color(229,0,255,self.Alpha))
		self.LifeTime = CurTime() + 4
		self.Size = 4
        self.CircleSize = 4		
end
	
function EFFECT:Think( )
    if !(self.LifeTime < CurTime()) then
	if self.Ent != NULL then
	self.StartPos = self.Ent:GetPos()
	local tracebeam = {}
	tracebeam.start = self.StartPos
	tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
	tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
	local traceworldbeam = util.TraceLine(tracebeam)
	self.Orig = traceworldbeam.HitPos

	self:SetPos(self.Orig)
	end
		if self.Size >= 40 then 
	    self.Size = -1
		self:SetModelScale( self.Size, 0 )
		return false
	    end
	return true 
	end
	return false 
end
local circle = Material("particle/particle_ring_wave_additive")
function EFFECT:Render() 
if self.Ent != NULL then
self.StartPos = self.Ent:GetPos()
local tracebeam = {}
tracebeam.start = self.StartPos
tracebeam.endpos = tracebeam.start - Vector(0,0,90000)
tracebeam.filter = function(ent) if !ent:IsWorld() then return false end end
local traceworldbeam = util.TraceLine(tracebeam)
self.Orig = traceworldbeam.HitPos

self:SetPos(self.Orig)

if self.CircleSize > -1 and self.CircleSize < 1000 then
self.CircleSize = math.Clamp(self.CircleSize + FrameTime()*800,4,1000)
end
if self.Size >= 1000 then
self.CircleSize = -1
end

self.Alpha2 = math.Clamp(self.Alpha2 - FrameTime()*160,0,255)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,5),self.Ent:GetAngles():Up(),self.CircleSize,self.CircleSize,Color(255,0,191,self.Alpha2),0)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,150),self.Ent:GetAngles():Up(),self.CircleSize - 50,self.CircleSize - 50,Color(255,0,191,self.Alpha2),0)
render.SetMaterial(circle)
render.DrawQuadEasy(self.Orig + Vector(0,0,240),self.Ent:GetAngles():Up(),self.CircleSize - 300,self.CircleSize - 300,Color(255,0,191,self.Alpha2),0)

self.Alpha = math.Clamp(self.Alpha - FrameTime()*80,0,120)
self:SetColor(Color(229,0,255,self.Alpha))
if self.Size > -1 and self.Size < 40 then
self.Size = math.Clamp(self.Size + FrameTime()*20,4,40)
self:SetModelScale( self.Size, 0 )
else
self:Remove()
end
if self.Size != 40 and self.Size != -1  then
self:DrawModel()
else
self:SetNoDraw(true)
self:Remove()
end
render.SetShadowColor( 255, 255, 255 )
end
end
effects.Register(EFFECT,"pc_particle_cannon_particle2")