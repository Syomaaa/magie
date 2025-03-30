AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local config = {}
config.dmg1 = 125 
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
	self:NetworkVar( "Int", 0, "epeeenbois" )
	if (SERVER) then
		self:Setepeeenbois( 1 )
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

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 100, 200 ) ) do 
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

config.magiedmg1 = 35
config.magiedmg2 = 35 -- dmg de .. à ..
config.zone = 300
config.nb = 10 -- nb de fois de dgt
config.interval = 0.1 -- interval entre chaque dgt
SWEP.Cooldown2 = 15
SWEP.ActionDelay2 = 0.2
SWEP.NextAction2 = 0
SWEP.CooldownDelay2 = 0

function SWEP:SecondaryAttack()
	if self.NextAction2 > CurTime() then return end
	if self.CooldownDelay2 < CurTime() then if !SERVER then return end
		if SERVER then
			local pos = self.Owner:GetEyeTrace().HitPos
			
			local entmagieberserker3 = ents.Create("magieberserker3")
			entmagieberserker3:SetPos(pos)
			entmagieberserker3.Owner = self.Owner
			entmagieberserker3:Spawn()
			SafeRemoveEntityDelayed(entmagieberserker3,1)

			local own = self.Owner
		
			timer.Create("dmgberserker3"..self.Owner:EntIndex(),config.interval,config.nb,function()
				for k,v in pairs(ents.FindInSphere(pos ,config.zone)) do
					if IsValid(v) and v != ent4 and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_ENERGYBEAM  )
						dmginfo:SetDamage( math.random(config.magiedmg1,config.magiedmg2) )
						v:AddEFlags("-2147483648" )
						dmginfo:SetDamagePosition( pos  )
						dmginfo:SetAttacker( own )
						dmginfo:SetInflictor( own )
						v:TakeDamageInfo(dmginfo)
						v:RemoveEFlags("-2147483648" )
					end
				end 
			end)

		end
		self.CooldownDelay2 = CurTime() + self.Cooldown2
		self.NextAction2 = CurTime() + self.ActionDelay2
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .."s de cooldown !" )
	end
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "berserker3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/plates/plate6x7.mdl" )
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )

		local idx = "bbbbbbbbbbbbeeeerrrrrrrrrsssssssskkkkk3"..self:EntIndex()
			timer.Create(idx,0.02,0,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "[7]_moontrap_add", 1, self, 1 )
				else
					timer.Remove(idx)
				end
			end)
		
		SafeRemoveEntityDelayed( self, 1 )
	end
	if CLIENT then
		function ENT:Draw()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "[7]_moontrap", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "magieberserker3" )
end

/*---------------------------------------------------------
	Initialisation Reload bouton
---------------------------------------------------------*/
SWEP.Spinning = 0

function SWEP:Reload()
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
