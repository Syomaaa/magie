if (SERVER) then
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= false
end

if (CLIENT) then
	SWEP.PrintName		= "Anti Magie 3"
	SWEP.DrawAmmo		= false
	SWEP.DrawCrosshair	= true
	SWEP.ViewModelFOV	= 70
	SWEP.ViewModelFlip	= false
	SWEP.CSMuzzleFlashes	= false
end

/*---------------------------------------------------------
	Main SWEP Setup
---------------------------------------------------------*/
SWEP.Author		= "Brounix"
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true
SWEP.Category		= "Anti Magie"

SWEP.WorldModel		= "models/epee_asta/epee_asta2.mdl"
SWEP.ViewModel		= ""
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ReloadRate		= 1
SWEP.JumpRefire		= false
SWEP.OldSpin		= 0
SWEP.HoldType		= "rollsword"

local config = {}
config.dmg1 = 135  
config.dmg2 = 160 --dgt de base entre .. et ..

config.dmgup1 = 150
config.dmgup2 = 200 --dgt click droit saut entre .. et ..

config.dmgleap1 = 150
config.dmgleap2 = 200 --dgt click droit en avant entre .. et ..

config.dmgslh1 = 350
config.dmgslh2 = 350 --dgt slash entre .. et ..

config.tmpShield = 6

config.dmgspin1 = 35
config.dmgspin2 = 35 --dgt tornade entre .. et ..

SWEP.Cooldown = 15 --cooldown general pour utiliser une atk spe 
SWEP.CooldownDelay = 0

config.canSwitch = true

SWEP.Cooldown1 = 26 --cooldown shield
SWEP.Cooldown2 = 15 --cooldown slash
SWEP.Cooldown3 = 15 --cooldown tornade

SWEP.ActionDelay = 0.2
SWEP.NextAction = 0

SWEP.CooldownDelay = 0
SWEP.CooldownDelay1 = 0
SWEP.CooldownDelay2 = 0
SWEP.CooldownDelay3 = 0

local AttackHit2 = Sound( "custom characters/attack_hit2.wav")
local AttackHit1 = Sound( "custom characters/attack_hit.wav")
local Hitground2 = Sound( "custom characters/attack4_hit.mp3")
local Hitground = Sound( "custom characters/sword_crash.wav")
local Ready = Sound( "custom characters/sword_ready.wav")
local Stapout = Sound( "custom characters/sword_stapouthit.wav")
local Stapin = Sound( "custom characters/sword_stabinhit.wav")
local Stap = Sound( "custom characters/sword_stap.wav")
local Cloth = Sound( "custom characters/player_cloth.wav")
local Roll = Sound( "npc/combine_soldier/gear2.wav")
local Combo1 = Sound( "custom characters/sword_swim1.wav")
local Combo2 = Sound( "custom characters/sword_swim2.wav")
local Combo3 = Sound( "custom characters/sword_swim3.wav")
local Combo4 = Sound( "custom characters/sword_swim4.wav")
local SwordTrail = Sound ( "custom characters/sword_trail.mp3" )

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "AntiMagie3" )
	if (SERVER) then
		self:SetAntiMagie3( 1 )
	end
end

function SWEP:Initialize()
	self.combo = 11
	self:SetHoldType("g_combo1")
	self.duringattack = false
	self.backtime = 0
	self.duringattacktime = 0
	self.dodgetime = 0
	self.plyindirction = false
	self.DownSlashed = true
	self.downslashingdelay = 0
	self.back = true
end

/*---------------------------------------------------------
	SWEP:Think Operations
---------------------------------------------------------*/
function SWEP:Think()
	local ply = self.Owner

	if self.duringattacktime < CurTime() then
		self.duringattack = true
	elseif self.duringattacktime > CurTime() then
		self.duringattack = false
	end

	if ply:IsOnGround() then
		self.DownSlashed = true
	end

	if  self.duringattacktime == CurTime() then
		self.back = true
	end

	if  self.duringattacktime < CurTime() and self.back == false and self.Owner:IsOnGround() then
		self.back = true
		self:SetHoldType("g_restart")
		ply:SetAnimation( PLAYER_ATTACK1 )
	end

	if self.Spinning == 1 then
		if self.OldSpin == 0 then
			self.Owner:SetEyeAngles( Angle(0, self.Owner:EyeAngles().y + 11.0773, 0) )
			for k,v in pairs(ents.FindInSphere(self.Owner:GetPos() ,250)) do
				if IsValid(v) and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmgspin1,config.dmgspin2) )
					dmginfo:SetDamagePosition( self.Owner:GetPos() )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)
				end
			end
		end

		if self.OldSpin == 1 then
			self.Owner:SetEyeAngles( Angle(0, self.Owner:EyeAngles().y + 22.154, 0) )
			for k,v in pairs(ents.FindInSphere(self.Owner:GetPos() ,250)) do
				if IsValid(v) and v != self.Owner then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmgspin1,config.dmgspin2) )
					dmginfo:SetDamagePosition( self.Owner:GetPos() )
					dmginfo:SetAttacker( self.Owner )
					dmginfo:SetInflictor( self.Owner )
					v:TakeDamageInfo(dmginfo)
				end
			end
		end
	end
end

/*---------------------------------------------------------
	Primary Attack (Sword Swinging)
---------------------------------------------------------*/
function SWEP:KillMove()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.3 )
	local ply = self.Owner
	self:SetHoldType("g_combo32")
	ply:SetAnimation( PLAYER_ATTACK1 )
	self.duringattack = true
	self.duringattacktime = CurTime() + 1.2
	self.dodgetime = CurTime() + 1.3
	self.Owner:ViewPunch(Angle(5, 1, 0))

	timer.Simple(0.2, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			ply:SetVelocity((self.Owner:GetForward() * 1) * 500 + Vector(0,0,50) )	
			ply:EmitSound(Combo2, 75, 80, 0.2, CHAN_AUTO)
			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmg1,config.dmg2)/3 ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
			
			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 100, 200 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					ply:EmitSound(Stap, 75, 80, 0.2, CHAN_AUTO)
					if v:IsNPC() or type( v ) == "NextBot" then
						if SERVER then
							v:EmitSound(Stapin, 75, 80, 0.2, CHAN_AUTO)					
							v:SetVelocity((self.Owner:GetForward() * 1) * 100  )	
							ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
						end
					end
					if v:IsPlayer() then
						v:EmitSound(Stapin, 75, 80, 0.2, CHAN_AUTO)					
						v:SetVelocity((self.Owner:GetForward() * 1) * 100 )	
						ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
					end
					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)

	timer.Simple(0.75, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			ply:SetVelocity((self.Owner:GetForward() * 1) * -400 + Vector(0,0,50) )	
			ply:EmitSound(Combo3, 75, 80, 0.2, CHAN_AUTO)
			ply:EmitSound(Stap, 75, 80, 0.2, CHAN_AUTO)
			self.Owner:ViewPunch(Angle(-5, -1, 0))
			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmg1,config.dmg2)*3) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 100, 200 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() or type( v ) == "NextBot" then
						if SERVER then
							v:EmitSound(Stapout, 75, 80, 0.2, CHAN_AUTO)					
							v:SetVelocity((self.Owner:GetForward() * 1) * 100  )	
							ParticleEffect("blood_advisor_puncture_withdraw",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
						end
					end
					if v:IsPlayer() then--
						v:EmitSound(Stapout, 75, 80, 0.2, CHAN_AUTO)		
						v:SetVelocity((self.Owner:GetForward() * 1) * 100 )	
						ParticleEffect("blood_advisor_puncture_withdraw",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
					end
					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)
end

function SWEP:DoCombo( hitsound, combonumber, force, attackdelay, anim, viewbob, primarystuntime, stuntime, sound, sounddelay, hastrail, haspush, push, pushdelay ,pushenemy)
	local ply = self.Owner
	self.back = false
	self.combo = combonumber
	self:SetHoldType(anim)
	ply:ViewPunch(viewbob)
	self.backtime = CurTime() + stuntime

	if haspush == true then
		timer.Simple(pushdelay, function()
			if IsValid(self) and self:GetOwner():Alive() then
				ply:SetVelocity((self.Owner:GetForward() * 1) * push + Vector(0,0,50) )	
			end
		end)
	end
	timer.Simple(sounddelay, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			ply:EmitSound(sound, 75, 80, 0.2, CHAN_AUTO)
			if hastrail == true then
				ply:EmitSound(SwordTrail, 75, 80, 0.2, CHAN_AUTO)
			end
		end
	end)

	self.dodgetime = CurTime() + primarystuntime
	ply:SetAnimation( PLAYER_ATTACK1 )
	self.duringattack = true
	self.duringattacktime = CurTime() + stuntime
	self.Weapon:SetNextPrimaryFire(CurTime() + primarystuntime )

	timer.Simple(attackdelay, function()
		if IsValid(self) and self:GetOwner():Alive() then
			local k, v

			local dmg = DamageInfo()
			dmg:SetDamage( force ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 100, 200 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() or type( v ) == "NextBot" then
						if SERVER then
							v:EmitSound(hitsound, 75, 80, 0.2, CHAN_AUTO)
							v:TakeDamageInfo( dmg )	ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
						end
					end

					if v:IsPlayer() then
						v:EmitSound(hitsound, 75, 80,0.2, CHAN_AUTO)
						v:TakeDamageInfo( dmg )	ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
					end
				end	
			end
		end
	end)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.6 )

	if self.combo == 0 then
		return 
	end

	if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyDown(IN_ATTACK) and (self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_FORWARD)) then
	else
		if self.Owner:IsOnGround() then
			if self.combo == 11 then
				self:DoCombo( AttackHit1, 11, math.random(config.dmg1,config.dmg2), 0.16, "g_combo1", Angle(3, -3, 0),0.3, 0.7, Combo1, 0.14, false, true, 150, 0.2 )
				self.combo = 12
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 12 then
							self.combo = 11 
						end
					end
				end)
			elseif self.combo == 12 then
				self:DoCombo( AttackHit2, 12, math.random(config.dmg1,config.dmg2), 0.15, "g_combo2", Angle(1, 3, 0), 0.4, 0.8, Combo4, 0.12, false, true, 230, 0.2 )
				self.combo = 13
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 13 then
							self.combo = 11
						end
					end
				end)
			elseif self.combo == 13 then
				self:DoCombo( AttackHit1, 13, math.random(config.dmg1,config.dmg2),  0.17, "g_combo3", Angle(-2, -3, 0),0.3, 0.9, Combo2, 0.17, false, true, 300, 0.2 )
				self.combo = 14
				timer.Simple(0.8, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 14 then
							self.combo = 15
							timer.Simple(0.7, function()
								if IsValid(self) and self:GetOwner():Alive() then
									if self.combo == 15 then
										self.combo = 11
									end
								end
							end)
						end
					end
				end)
			elseif self.combo == 14 then
				self.Owner:EmitSound(Ready)
				self:DoCombo( Stapout, 14, math.random(config.dmg1*2,config.dmg2*2), 0.4, "g_combo4", Angle(3, -5, 0), 1.3, 1.2, Combo3, 0.4, true, true, 600, 0.3, false, true )
				self.combo = 11
				self.Owner:EmitSound(Cloth)
			elseif self.combo == 15 then
				self:KillMove()
				self.combo = 14
				timer.Simple(1.8, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 14 then
							self.combo = 11
						end
					end
				end)
			end
		end
		if not self.Owner:IsOnGround() then
			if self.combo == 11 then
				self:DoCombo( AttackHit2, 21, math.random(config.dmg1,config.dmg2), 0.16, "a_combo1", Angle(3, -3, 0), 0.25, 0.7, Combo1, 0.14, false, false, 150, 0.2 , true)
				self.combo = 12
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 12 then
							self.combo = 11 
						end
					end
				end)
			end
		end
	end
end

/*---------------------------------------------------------
	Secondary Attack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if !SERVER then return end
	if not self.Owner:IsOnGround() then
		self:SlashDown()
		self.Weapon:SetNextSecondaryFire(CurTime() + 4 )
	else
		if self.Owner:KeyDown( IN_FORWARD ) then
			self:LeapAttack()
			self.Weapon:SetNextSecondaryFire(CurTime() + 4)
		end
	end
end

function SWEP:SlashDown()
	local ply = self.Owner
	self.Owner:ViewPunch(Angle(-4, 4, 6))
	config.reset = false

	self.Weapon:SetNextPrimaryFire(CurTime() + 1.5 )

	timer.Simple(0.01,function()
		self:SetHoldType("slashdown")
		ply:SetAnimation( PLAYER_ATTACK1 )
	end)

	self.duringattack = true
	self.duringattacktime = CurTime() + 1
	self.dodgetime = CurTime() + 1.2

	local pl = self.Owner
	local ang = pl:GetAngles()
	local forward, right = ang:Forward(), ang:Right()		
	local vel = -1 * pl:GetVelocity()
	vel = vel + Vector(0, 0, 200)
	local spd = pl:GetMaxSpeed()
			
	if pl:KeyDown(IN_FORWARD) then
		vel = vel + forward * spd
	elseif pl:KeyDown(IN_BACK) then
		vel = vel - forward * spd
	end
			
	if pl:KeyDown(IN_MOVERIGHT) then
		vel = vel + right * spd
	elseif pl:KeyDown(IN_MOVELEFT) then
		vel = vel - right * spd
	end
			
	pl:SetVelocity(vel) 

	timer.Simple(0.4, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			if SERVER then
				ply:EmitSound(Hitground)
			end
			self.combo = 11
			self.DownSlashed = false
			self.Owner:ViewPunch(Angle(4, -1, 0))

			local pl = self.Owner
			local ang = pl:GetAngles()
			local forward, right = ang:Forward(), ang:Right()
			local vel = -1 * pl:GetVelocity()
				
			vel = vel + Vector(0, 0, -2500)
				
			local spd = pl:GetMaxSpeed()
				
			if pl:KeyDown(IN_FORWARD) then
				vel = vel + forward * spd
			elseif pl:KeyDown(IN_BACK) then
				vel = vel - forward * spd
			end
				
			if pl:KeyDown(IN_MOVERIGHT) then
				vel = vel + right * spd
			elseif pl:KeyDown(IN_MOVELEFT) then
				vel = vel - right * spd
			end
				
			pl:SetVelocity(vel)
		end
	end)

	timer.Simple(0.3, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			if SERVER then
				ply:EmitSound(AttackHit2)
			end
			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmgup1,config.dmgup2) ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)
			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() + (self.Owner:GetForward() * 1) * 50, 120 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() then		
						if SERVER then
							v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,-2500) + (ply:GetForward() * 1) * 101 )	
						end
					end
					if v:IsPlayer() then		
						v:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,-2500) + (ply:GetForward() * 1) * 100 )	
					end
					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )
					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)
	timer.Simple(1,function()
		if(IsValid(self) && self:GetOwner():Alive()) then
			self:EmitSound( Stap )
			self:SetHoldType("rollsword")	
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Owner:GodDisable()
		end
	end)
end

function SWEP:LeapAttack()
	if !SERVER then return end
	self.Owner:ViewPunch(Angle(3, 4, 3))
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.5 )
	self.back = false
	local ply = self.Owner
	
	self:SetHoldType("leap")
	ply:SetAnimation( PLAYER_ATTACK1 )
	if SERVER then
		ply:EmitSound(Ready)
		ply:EmitSound(Cloth)
	end
	self.duringattack = true
	self.duringattacktime = CurTime() + 1
	self.dodgetime = CurTime() + 1.2
	ply:SetVelocity((self.Owner:GetForward() * 1) * 1 + Vector(0,0,200) )	

	timer.Simple(0.05, function()
		if IsValid(self) and self:GetOwner():Alive() then
			ply:SetVelocity((self.Owner:GetForward() * 1) * 2000 + Vector(0,0,-100) )
			self:SetHoldType("leapattack")
			ply:SetAnimation( PLAYER_ATTACK1 )
		end
	end)

	timer.Simple(0.3, function() 
		if IsValid(self) and self:GetOwner():Alive() then
			if SERVER then
				ply:EmitSound(Hitground)	
			end
			self.Owner:ViewPunch(Angle(-6, -5, 0))

			local k, v
			local dmg = DamageInfo()
			dmg:SetDamage( math.random(config.dmgleap1,config.dmgleap2) ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 50, 140 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() then
						if SERVER then
							v:EmitSound(AttackHit1)		
							v:SetVelocity((self.Owner:GetForward() * 1) * 80 + Vector(0,0,50) )	
						end
					end

					if v:IsPlayer() then
						v:EmitSound(AttackHit1)		
						v:SetVelocity((self.Owner:GetForward() * 1) * 80 + Vector(0,0,50) )	
					end

					dmg:SetDamageForce( ( v:GetPos() - self.Owner:GetPos() ):GetNormalized() * 100 )

					if SERVER then
						v:TakeDamageInfo( dmg )
					end
				end	
			end	
		end
	end)
	timer.Simple(1, function()
		if IsValid(self) and self:GetOwner():Alive() then
			config.Reset = true
		end
	end)
end

/*---------------------------------------------------------
	Initialisation Reload bouton
---------------------------------------------------------*/
SWEP.Spinning = 0
function SWEP:Reload()
	if self:GetAntiMagie3() == 1 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay1 < CurTime() then
			self:BlockAttack()
			self.CooldownDelay1 = CurTime() + self.Cooldown1
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown1 .."s de cooldown avant le prochain spell !" )
		end
	elseif self:GetAntiMagie3() == 2 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:SlashAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown avant le prochain spell !" )
		end
	elseif self:GetAntiMagie3() == 3 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:TornadeAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown avant le prochain spell !" )
		end
	end
end

/*---------------------------------------------------------
	BlockAttack
---------------------------------------------------------*/
function SWEP:BlockAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay1 < CurTime() then if !SERVER then return end

		self.Weapon:SetNextSecondaryFire(CurTime() + config.tmpShield)
		self.Weapon:SetNextPrimaryFire(CurTime() + config.tmpShield)
		config.canSwitch = false
		self.Owner:GodEnable()

		local own = self:GetOwner()
		local shield = ents.Create( "shield2" ) 

		self:EmitSound( Cloth )
		self:SetHoldType("rollsword")
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		local pos = own:GetPos() + Vector(0,0,40)
		local ang = Angle(own:GetAngles().x,own:GetAngles().y,own:GetAngles().z):Forward()

		shield:SetPos( pos + ang)
		pos=pos+(ang*10)
		shield:SetParent(own)
		shield:SetAngles( Angle( ang.pitch, ang.yaw, 0 ) ) shield.Owner = own
		shield:Spawn() shield:Activate() own:DeleteOnRemove( shield )

		timer.Simple(config.tmpShield,function()
			if(IsValid(self) && self:GetOwner():Alive()) then
				config.canSwitch = true
				self:EmitSound( Stap )
				self:SetHoldType("rollsword")	
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				self.Owner:GodDisable()
			end
		end)

		if( !self:GetOwner():Alive()) then
			SafeRemoveEntityDelayed(self,0)
		end
		
		self.CooldownDelay1 = CurTime() + self.Cooldown1
		self.NextAction = CurTime() + self.ActionDelay
	else	
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown1 .."s de cooldown avant le bouclier !" )
	end
	return true
end

/*---------------------------------------------------------
	SlashAttack
---------------------------------------------------------*/
function SWEP:SlashAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay2 < CurTime() then if !SERVER then return end
 
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.8)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.8)


		timer.Simple(0.15, function()
			if(IsValid(self) && self:GetOwner():Alive()) then
				self:SetHoldType( "g_combo1" )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				timer.Simple(0.15, function()
					if(IsValid(self) && self:GetOwner():Alive()) then
						local own = self:GetOwner()
						local ang = Angle(0, own:EyeAngles().Yaw, 0)
						local pos = own:GetShootPos() + own:GetAimVector() * 40,10
						local dir = own:EyeAngles():Forward()*10000 +VectorRand():GetNormal()*50
						self:EmitSound( Combo3 )
						local slash2 = ents.Create( "slash2" )
						slash2:SetPos( pos )
						slash2:SetAngles( ang ) slash2:SetOwner( own )
						slash2:Spawn() slash2:Activate() own:DeleteOnRemove( slash2 )
						slash2:GetPhysicsObject():EnableGravity( false )
						slash2:GetPhysicsObject():SetVelocity( dir )
						slash2:SetPhysicsAttacker( own )
					end
				end)
			end
		end)
		timer.Simple(1, function()
			if IsValid(self) and self:GetOwner():Alive() and not self.Owner:KeyDown(IN_ATTACK) then
				self:SetHoldType("rollsword")
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
			end
		end)

	self.CooldownDelay2 = CurTime() + self.Cooldown2
	self.NextAction = CurTime() + self.ActionDelay
	else	
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .."s de cooldown avant le slash !" )
	end
    return true
end

/*---------------------------------------------------------
	TornadeAttack
---------------------------------------------------------*/
function SWEP:TornadeAttack()
	if IsValid(self) and self:GetOwner():Alive() then
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay3 < CurTime() then if !SERVER then return end

		config.canSwitch = false

		self.Weapon:SetNextSecondaryFire(CurTime() + 0.8)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.8)

		timer.Simple(0.01,function()
			self:SetHoldType( "leapattack" )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
		end)

		if SERVER then
			self.Owner:EmitSound(SwordTrail)
		end

		if self.OldSpin == 1 then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self.Owner:DoAttackEvent()
			self.ReloadRate = 0

			timer.Simple(0.98, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end
			end)
			timer.Simple(3, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end  
			end)  
			
			self.Spinning = 1
		end

		if self.OldSpin == 0 then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self.Owner:DoAttackEvent()
			self.ReloadRate = 0

			timer.Simple(1, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end
			end)
			timer.Simple(3, function() 
				if IsValid(self) and self:GetOwner():Alive() then
					self.Weapon:TornadeAttackReset() 
				end  
			end)  
			self.Spinning = 1

			if SERVER then 
				local own = self:GetOwner()
				local pos = own:GetPos()

				local antitornade = ents.Create("env_smokestack")
				antitornade:SetKeyValue("smokematerial", "effects/fire_cloud2.vmt")
				antitornade:SetKeyValue("rendercolor", "255 20 20" )
				antitornade:SetKeyValue("targetname","antitornade")
				antitornade:SetKeyValue("basespread","100")
				antitornade:SetKeyValue("spreadspeed","100")
				antitornade:SetKeyValue("speed","500")
				antitornade:SetKeyValue("startsize","50")
				antitornade:SetKeyValue("endzide","100")
				antitornade:SetKeyValue("rate","200")
				antitornade:SetKeyValue("jetlength","200")
				antitornade:SetKeyValue("twist","600")
				antitornade:SetPos(pos)
				antitornade:SetParent(self.Owner)
				antitornade:Spawn()
				antitornade:Fire("turnon","",0.1)
				antitornade:Fire("Kill","",1.2)

				local antitornade2 = ents.Create("env_smokestack")
				antitornade2:SetKeyValue("smokematerial", "particles/smokey.vmt")
				antitornade2:SetKeyValue("rendercolor", "20 20 20" )
				antitornade2:SetKeyValue("targetname","antitornade2")
				antitornade2:SetKeyValue("basespread","100")
				antitornade2:SetKeyValue("spreadspeed","100")
				antitornade2:SetKeyValue("speed","500")
				antitornade2:SetKeyValue("startsize","50")
				antitornade2:SetKeyValue("endzide","100")
				antitornade2:SetKeyValue("rate","200")
				antitornade2:SetKeyValue("jetlength","200")
				antitornade2:SetKeyValue("twist","600")
				antitornade:SetPos(pos)
				antitornade:SetParent(self.Owner)
				antitornade2:Spawn()
				antitornade2:Fire("turnon","",0.1)
				antitornade2:Fire("Kill","",1.2)

			end
		end

		timer.Simple(1.4, function()
			if IsValid(self) and self:GetOwner():Alive() then
				self:SetHoldType("g_restart")
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				
			end
			config.canSwitch = true
		end)

		self.CooldownDelay3 = CurTime() + self.Cooldown3
		self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown3 .."s de cooldown avant la tornade !" )
	end
	end
	return true
end

function SWEP:TornadeAttackReset()
	self.Spinning = 0
	if SERVER then
	end
end

function SWEP:TornadeAttackReset2()
	self.ReloadRate = 1
end

/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	if (IsValid(self) && self:GetOwner():Alive()) then
		if SERVER then 
			self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav", 256, 75)
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end
	end
	return true
end

/*---------------------------------------------------------
	Holster
---------------------------------------------------------*/
function SWEP:Holster()
	if SERVER then
		if config.canSwitch == true then
			if (IsValid(self) && self:GetOwner():Alive()) then
				self.Owner:GodDisable()
			elseif (IsValid(self) && !self:GetOwner():Alive()) then
				self.Owner:GodDisable()
			end
			return true
		else
			if (IsValid(self) && !self:GetOwner():Alive()) then
				self.Owner:GodDisable()
				config.canSwitch = true
			end
			return false
		end
		config.canSwitch = true
		self.Owner:GodDisable()
	end
end

/*---------------------------------------------------------
	OnDrop
---------------------------------------------------------*/
function SWEP:OnDrop()
	return false
end

/*---------------------------------------------------------
	Draw HUD
---------------------------------------------------------*/
function SWEP:DrawHUD()
 
	local ScrW = ScrW()
	local ScrH = ScrH()
	
	local color = Color(210,30,0)

	local icon = 60
	local icongap = 2
	local gap = 5
 
	local bar = 4
	
	local powername = 16
	
	local Font = "Trebuchet18"

	if ( ESPSelectPower ) then
		icon = 128
		icongap = 3
		bar = 8
		bar2 = 24
		powername = 20
		Font = "Trebuchet24"
	end
	
	local FrameW = gap + ( ( icon + gap ) * 3 )
	local FrameH = (gap*3) + icon
	
	local FrameWPos = ScrW/2 - (FrameW/2)
	local FrameHPos = ScrH - ( FrameH + gap )
	
	draw.RoundedBox( 0, FrameWPos, FrameHPos, FrameW, FrameH, Color( 20,20,20, 100 ) )
	
	---- power icon
	 
	local iconWPos = FrameWPos + gap
	local iconslot = 1
	local SelectedPower = self:GetAntiMagie3()
	local IconCaseColor = Color(20,20,20, 150 )
	
	
	for id, t in pairs( AntiMagie3 ) do
		IconCaseColor = Color(20,20,20, 150 )
		if SelectedPower == iconslot then
			IconCaseColor = color
			draw.RoundedBox( 0, ScrW/2 - (icon + gap/2 ), FrameHPos - ( gap + powername ), (icon*2) + gap, powername, Color(20,20,20, 150 ) )
			draw.SimpleText( t.name, Font, ScrW/2 , FrameHPos - ( gap + powername/2 ), Color( 255, 255, 255, 255), 1, 1 )
		end
		
		draw.RoundedBox( 0, iconWPos, FrameHPos + gap, icon, icon, IconCaseColor )
		if (ESPSelectPower) then
			local TextColor = Color(255,255,255,255)
			if iconslot == 2 and self:GetZone() then
				TextColor = Color(50,255,50,255)
			elseif iconslot == 1 and self:GetBarrier() then
				TextColor = Color(50,255,50,255)
			end
			draw.SimpleText( iconslot, Font, iconWPos + icongap, FrameHPos + gap + icongap, TextColor, 0, 3 )
		end
		
		surface.SetMaterial( t.material )
		surface.SetDrawColor( Color(255,255,255) )

		render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )
			surface.DrawTexturedRect( iconWPos + icongap, FrameHPos + gap + icongap , icon - (icongap * 2), icon - (icongap * 2) )
		render.PopFilterMag()
		render.PopFilterMin()
		
		iconWPos = iconWPos + icon + gap
		iconslot = iconslot + 1
	end
end

/*---------------------------------------------------------
	Hook et Bouton
---------------------------------------------------------*/

function SWEP:CalcView( ply, pos, angles, fov )
	if not IsValid( ply ) or ply:GetViewEntity() ~= ply or not ply:Alive() then return end

	ply._lscsCalcViewTime = CurTime() + 0.1 -- this is used to detect if its broken
  
	return ply:lscsGetViewOrigin(), ply:EyeAngles(), fov
end

hook.Add( "ShouldDrawLocalPlayer", "AntiMagieThirdPDraw4", function (ply)
	if ply:GetActiveWeapon():IsValid() then
		if ply:IsPlayer() && ply:Alive() && ply:GetActiveWeapon():GetClass() == "antimagie4" then
			return true
		end
	end
end)

hook.Add("PlayerButtonDown", "AntiMagie3binds", function( ply, button )
	if config.canSwitch == true then if !SERVER then return end
	if button == ply:GetInfoNum( "TouchesBind1", 15) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "antimagie4" then
					ply:GetActiveWeapon():SetAntiMagie3(1)
			end
		end
	elseif button == ply:GetInfoNum( "TouchesBind2", 28) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "antimagie4" then
					ply:GetActiveWeapon():SetAntiMagie3(2)
			end
		end
	elseif button == ply:GetInfoNum( "TouchesBind3", 15) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "antimagie4" then
					ply:GetActiveWeapon():SetAntiMagie3(3)
			end
		end
	end
	end
end)

/*---------------------------------------------------------
	ent et effect
---------------------------------------------------------*/

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "slash2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		local own =  self:GetOwner()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/slash/slash.mdl" )
		self:SetMaterial("models/shadertest/shader4")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetAngles(Angle(0,own:EyeAngles().Yaw + 90,0))
		self:SetModelScale( 2.5, 0 )
		self:ManipulateBoneScale(self:EntIndex(),Vector(10,10,10))
		self:SetSolid( SOLID_NONE ) self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 180,20,20,230 ) )
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 1 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*3000 ) 
		end 
		local own = self:GetOwner()
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,250)) do
			if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
				local dmginfo = DamageInfo()
				dmginfo:SetDamageType( DMG_GENERIC  )
				dmginfo:SetDamage( math.random(config.dmgslh1,config.dmgslh2) )
				dmginfo:SetDamagePosition( self:GetPos()  )
				dmginfo:SetAttacker( own )
				dmginfo:SetInflictor( own )
				v:TakeDamageInfo(dmginfo)
				self:EmitSound( Hitground2 )
				self:GetPhysicsObject():EnableMotion( false )
				SafeRemoveEntityDelayed( self, 0 )
			end
		end  
	end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "slash2_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "slash2" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "shield2"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		local own = self.Owner
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/tubes/tube4x4x2c.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:PhysicsInit(SOLID_NONE)
		self:SetTrigger( true )
		self:SetAngles(Angle(0,own:EyeAngles().y + 180,0))
		self:SetMaterial( "models/shadertest/shader4" ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		SafeRemoveEntityDelayed( self, config.tmpShield+0.1  )
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "shield2_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "shield2" )
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
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter()  + Vector(math.random(-50,50),math.random(-50,50),0) )
					if particle then  local size = math.Rand( 2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.3, 0.5 ) )
						particle:SetStartAlpha( 160 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 230, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 20 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter()  + Vector(math.random(-50,50),math.random(-50,50),0) )
					if particle then  local size = math.Rand( 2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.3, 0.5 ) )
						particle:SetStartAlpha( 160 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 20, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 20 )
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

	end
	effects.Register( EFFECT, "slash2_effect" )
end

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
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-50,50)) )
					if particle then  local size = math.Rand(2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.2, 0.3 ) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 230, 20, 20 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle = self.Emitter:Add( "particles/smokey", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-50,50)) )
					if particle then  local size = math.Rand(2,3 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.2, 0.3 ) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 6 )
						particle:SetColor( 20, 20, 20 )
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

	end
	effects.Register( EFFECT, "shield2_effect" )
end