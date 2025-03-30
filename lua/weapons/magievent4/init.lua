AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local config = {}
config.dmg1 = 150 
config.dmg2 = 150 --dgt de base entre .. et ..

config.Cooldown = 1
config.ActionDelay = 0.2
config.NextAction = 0		--cooldown pour siwtch de selection
config.CooldownDelay = 0

config.canSwitch = true


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
	self:NetworkVar( "Int", 0, "magievent4" )
	if (SERVER) then
		self:Setmagievent4( 1 )
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
	config.canatk = true

end

local delay = CurTime()

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
		end

		if self.OldSpin == 1 then
			self.Owner:SetEyeAngles( Angle(0, self.Owner:EyeAngles().y + 22.154, 0) )
		end
	end

	self:Fly()
end

/*---------------------------------------------------------
	Primary Attack (Sword Swinging)
---------------------------------------------------------*/

function SWEP:DoCombo( hitsound, combonumber, force, attackdelay, anim, viewbob, primarystuntime, stuntime, sound, sounddelay, hastrail, haspush, push, pushdelay ,pushenemy)
	local ply = self.Owner
	self.back = false
	self.combo = combonumber
	self:SetHoldType(anim)
	ply:ViewPunch(viewbob)
	self.backtime = CurTime() + stuntime

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
		if IsValid(self) and self:GetOwner():Alive() and SERVER then
			local k, v

			local dmg = DamageInfo()
			dmg:SetDamage( force ) 
			dmg:SetDamageType(DMG_GENERIC)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 35, 135 ) ) do 
				if v:IsValid() and self.Owner:Alive() and  v != self.Owner then
					if v:IsNPC() or type( v ) == "NextBot" then
						if SERVER then
							v:EmitSound(hitsound, 75, 80, 0.2, CHAN_AUTO)
							v:TakeDamageInfo( dmg )	
							ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
						end
					end

					if v:IsPlayer() and SERVER then
						v:EmitSound(hitsound, 75, 80,0.2, CHAN_AUTO)
						v:TakeDamageInfo( dmg )	
						ParticleEffect("blood_advisor_puncture",v:GetPos() + v:GetForward() * 0 + Vector( 0, 0, 40 ),Angle(0,45,0),nil)
					end
				end	
			end
		end
	end)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.8 )
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1 )

	if self.combo == 0 then
		return 
	end

	if self.Owner:KeyDown(IN_WALK) and self.Owner:KeyDown(IN_ATTACK) and (self.Owner:KeyDown(IN_BACK) or self.Owner:KeyDown(IN_FORWARD)) then
	else
		if self.Owner:IsOnGround() then
			if self.combo == 11 then
				timer.Simple(0.01, function()
				self:DoCombo( AttackHit1, 11, math.random(config.dmg1,config.dmg2), 0.16, "g_combo3", Angle(3, -3, 0),0.4, 0.6, Combo1, 0.14, false, true, 150, 0.2 )
				self.combo = 12
				end)
				
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 12 then
							self.combo = 11 
						end
					end
				end)
			end
			if self.combo == 12 then
				timer.Simple(0.01, function()
				self:DoCombo( AttackHit2, 12, math.random(config.dmg1,config.dmg2), 0.15, "g_combo2", Angle(1, 3, 0), 0.3, 0.7, Combo4, 0.12, false, true, 230, 0.2 )
				self.combo = 13
				end)
				
				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						if self.combo == 13 then
							self.combo = 11
						end
					end
				end)
			end
			if self.combo == 13 then
				timer.Simple(0.01, function()
				self:DoCombo( AttackHit1, 13, math.random(config.dmg1,config.dmg2),  0.17, "g_combo1", Angle(-2, -3, 0),0.3, 0.8, Combo2, 0.17, false, true, 300, 0.2 )
				self.combo = 14
				end)
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
			end
			if self.combo == 14 then
				self.Owner:EmitSound(Ready)
				timer.Simple(0.01, function()
				self:DoCombo( Stapout, 14, math.random(config.dmg1*2,config.dmg2*2), 0.4, "g_combo4", Angle(3, -5, 0), 1.3, 1.1, Combo3, 0.4, true, true, 600, 0.3, false, true )
				self.combo = 11
				self.Owner:EmitSound(Cloth)
				end)
			end
		end
		if not self.Owner:IsOnGround() then
			if self.combo == 11 then
				timer.Simple(0.01, function()
				self:DoCombo( AttackHit2, 21, math.random(config.dmg1,config.dmg2), 0.16, "a_combo1", Angle(3, -3, 0), 0.25, 0.6, Combo1, 0.14, false, false, 150, 0.2 , true)
				self.combo = 12
				end)
				timer.Simple(0.6, function()
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
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay3 < CurTime() then if !SERVER then return end

			self.Owner:SetVelocity(self.Owner:GetForward() * 1000 )

			self.CooldownDelay3 = CurTime() + self.Cooldown3
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown3 .."s de cooldown !" )
		end
end


/*---------------------------------------------------------
	Initialisation Reload bouton
---------------------------------------------------------*/
SWEP.Spinning = 0
function SWEP:Reload()
	if !SERVER then return end
	if self:Getmagievent4() == 1 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:BourasqueAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else	
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown avant le prochain spell !" )
		end
	elseif self:Getmagievent4() == 2 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:TornadeVentAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else	
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown avant le prochain spell !" )
		end
	end
end

/*---------------------------------------------------------
	Dimansion Slash
---------------------------------------------------------*/
function SWEP:TornadeVentAttack()
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
					antitornade:SetKeyValue("smokematerial", "swarm/particles/particle_smokegrenade1.vmt")
					antitornade:SetKeyValue("rendercolor", "200 240 200" )
					antitornade:SetKeyValue("targetname","antitornade")
					antitornade:SetKeyValue("basespread","250")
					antitornade:SetKeyValue("spreadspeed","350")
					antitornade:SetKeyValue("speed","500")
					antitornade:SetKeyValue("startsize","50")
					antitornade:SetKeyValue("endzide","100")
					antitornade:SetKeyValue("rate","500")
					antitornade:SetKeyValue("jetlength","400")
					antitornade:SetKeyValue("twist","600")
					antitornade:SetPos(pos)
					antitornade:SetParent(self.Owner)
					antitornade:Spawn()
					antitornade:Fire("turnon","",0.1)
					antitornade:Fire("Kill","",2)

					local pluieprop = ents.Create( "tornade_vent" )
					pluieprop:SetPos( self.Owner:GetPos()) 
					pluieprop:SetOwner( self.Owner ) 
					pluieprop:Spawn() 
					pluieprop:Activate()
				end

			end

			timer.Simple(1.4, function()
				if IsValid(self) and self:GetOwner():Alive() then
					self:SetHoldType("g_restart")
					self.Owner:SetAnimation( PLAYER_ATTACK1 )
				end
				config.canSwitch = true
			end)

			self.CooldownDelay3 = CurTime() + self.Cooldown2
			self.NextAction = CurTime() + self.ActionDelay
		else		
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .."s de cooldown pour la tornade !" )
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
	SlashAttack
---------------------------------------------------------*/
function SWEP:BourasqueAttack()
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay1 < CurTime() then if !SERVER then return end
	
		config.canatk = false
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

			config.canSwitch = false
				
				timer.Simple(0.2, function()
					if IsValid(self) and self:GetOwner():Alive() then
						timer.Simple(0.15, function()
							if(IsValid(self) && self:GetOwner():Alive()) then
								local own = self:GetOwner()
								local ang = Angle(own:EyeAngles().X, own:EyeAngles().Yaw, 0)
								local pos = own:GetShootPos() + own:GetAimVector() * 40,10
								local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*50
								
								local slash2 = ents.Create( "bourasque" )
								slash2:EmitSound( Combo3 )
								slash2:SetPos( pos )
								slash2:SetAngles( ang ) slash2:SetOwner( own )
								slash2:Spawn() slash2:Activate() own:DeleteOnRemove( slash2 )
								slash2:GetPhysicsObject():EnableGravity( false )
								slash2:GetPhysicsObject():SetVelocity( dir/3 )
								slash2:SetPhysicsAttacker( own )
							end
						end)
						self:DoCombo( AttackHit1, 11, 0, 0.16, "g_combo1", Angle(3, -3, 0),0.3, 0.7, Combo1, 0, false, true, 150, 0.2 )
					end
				end)
				

				timer.Simple(0.6, function()
					if IsValid(self) and self:GetOwner():Alive() then
						timer.Simple(0.15, function()
							if(IsValid(self) && self:GetOwner():Alive()) then
								local own = self:GetOwner()
								local ang = Angle(own:EyeAngles().X, own:EyeAngles().Yaw, 10)
								local pos = own:GetShootPos() + own:GetAimVector() * 40,10
								local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*50
								
								local slash2 = ents.Create( "bourasque" )
								slash2:SetPos( pos )
								slash2:EmitSound( Combo3 )
								slash2:SetAngles( ang ) slash2:SetOwner( own )
								slash2:Spawn() slash2:Activate() own:DeleteOnRemove( slash2 )
								slash2:GetPhysicsObject():EnableGravity( false )
								slash2:GetPhysicsObject():SetVelocity( dir/3 )
								slash2:SetPhysicsAttacker( own )
							end
						end)
						self:DoCombo( AttackHit2, 12, 0, 0.15, "g_combo2", Angle(1, 3, 0), 0.4, 0.8, Combo4, 0, false, true, 230, 0.2 )
					end
				end)


				timer.Simple(1, function()
					if IsValid(self) and self:GetOwner():Alive() then
						timer.Simple(0.15, function()
							if(IsValid(self) && self:GetOwner():Alive()) then
								local own = self:GetOwner()
								local ang = Angle(own:EyeAngles().X, own:EyeAngles().Yaw, -30)
								local pos = own:GetShootPos() + own:GetAimVector() * 40,10
								local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*50
								
								local slash2 = ents.Create( "bourasque" )
								slash2:SetPos( pos )
								slash2:EmitSound( Combo3 )
								slash2:SetAngles( ang ) slash2:SetOwner( own )
								slash2:Spawn() slash2:Activate() own:DeleteOnRemove( slash2 )
								slash2:GetPhysicsObject():EnableGravity( false )
								slash2:GetPhysicsObject():SetVelocity( dir/3 )
								slash2:SetPhysicsAttacker( own )
							end
						end)
						self:DoCombo( AttackHit1, 11, 0,  0.15, "g_combo3", Angle(1, 3, 0),0.3, 0.9, Combo2, 0, false, true, 230, 0.2 )
					end
				end)

				timer.Simple(1.5, function()
					if IsValid(self) and self:GetOwner():Alive() then
						self:SetHoldType("rollsword")
						self.Owner:SetAnimation( PLAYER_ATTACK1 )
						config.canSwitch = true
						config.canatk = true
					end
				end)
								
				self.combo = 0
				self.CooldownDelay1 = CurTime() + self.Cooldown1
				self.NextAction = CurTime() + self.ActionDelay
			else	
				self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown1 .."s de cooldown !" )
			end

    return true
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


hook.Add("PlayerButtonDown", "magievent4binds", function( ply, button )
	if config.canSwitch == true then if !SERVER then return end
	if button == ply:GetInfoNum( "TouchesBind5", 15) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "magievent4" then
					ply:GetActiveWeapon():Setmagievent4(1)
			end
		end
	elseif button == ply:GetInfoNum( "TouchesBind6", 28) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "magievent4" then
					ply:GetActiveWeapon():Setmagievent4(2)
			end
		end
	end
	end
end)

