if (SERVER) then
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= false
end

if (CLIENT) then
	SWEP.PrintName		= "Ténèbres 4"
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
SWEP.Category		= "Ténèbres"

SWEP.WorldModel		= "models/epee_yami/epee_yami.mdl"
SWEP.ViewModel		= ""

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
config.dmg1 = 150 
config.dmg2 = 150 --dgt de base entre .. et ..

config.dmgslh1 = 166
config.dmgslh2 = 166 --dgt slash entre .. et ..
config.zoneMultiSlash = 300

config.dmgSuperSlh1 = 500
config.dmgSuperSlh2 = 500 --dgt tornade entre .. et ..
config.zoneDimSlash = 300

config.canSwitch = true

SWEP.Cooldown = 20 --cooldown general pour utiliser une atk spe
SWEP.Cooldown1 = 1 --cooldown dimension
SWEP.Cooldown2 = 1 --cooldown multi slash
SWEP.Cooldown3 = 10 --cooldown click gauche

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
	self:NetworkVar( "Int", 0, "magietenebre4" )
	if (SERVER) then
		self:Setmagietenebre4( 1 )
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
		if IsValid(self) and self:GetOwner():Alive() and SERVER then
			local k, v

			local dmg = DamageInfo()
			dmg:SetDamage( force ) 
			dmg:SetDamageType(DMG_SLASH)
			dmg:SetAttacker(self.Owner) 
			dmg:SetInflictor(self.Owner)

			for k, v in pairs ( ents.FindInSphere( self.Owner:GetPos() +  Vector(0,0,40) + (self.Owner:GetForward() * 1) * 35, 135 ) ) do 
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
				self:DoCombo( AttackHit1, 11, math.random(config.dmg1,config.dmg2), 0.16, "g_combo3", Angle(3, -3, 0),0.5, 0.7, Combo1, 0.14, false, true, 150, 0.2 )
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
				self:DoCombo( AttackHit1, 13, math.random(config.dmg1,config.dmg2),  0.17, "g_combo1", Angle(-2, -3, 0),0.3, 0.9, Combo2, 0.17, false, true, 300, 0.2 )
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

    if self.NextAction > CurTime() then return end
    if self.CooldownDelay3 < CurTime() then if !SERVER then return end

	self.Owner:SetVelocity( self.Owner:GetAimVector() * 750 + Vector( 0, 0, 250 ) )

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
	if self:Getmagietenebre4() == 1 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:MultiSlashAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
	elseif self:Getmagietenebre4() == 2 then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay < CurTime() then
			self:DimensionSlashAttack()
			self.CooldownDelay = CurTime() + self.Cooldown
			self.NextAction = CurTime() + self.ActionDelay
		else
			self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
		end
	end
end

/*---------------------------------------------------------
	Dimansion Slash
---------------------------------------------------------*/
function SWEP:DimensionSlashAttack()
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay1 < CurTime() then if !SERVER then return end
 
		config.canatk = false

		timer.Simple(0.2, function()
			if(IsValid(self) && self:GetOwner():Alive()) then
				self:SetHoldType( "slashdown" )
				self:EmitSound( Combo3 )
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				timer.Simple(0.2, function()
					if(IsValid(self) && self:GetOwner():Alive()) then
						local own = self:GetOwner()
						local ang = Angle(own:EyeAngles().x, own:EyeAngles().Yaw, 90)
						local pos = own:GetShootPos() + own:GetAimVector() * 40,10
						local dir = own:EyeAngles():Forward()*3000 +VectorRand():GetNormal()*50
						self.Weapon:EmitSound(SwordTrail, 50, 100)
						local slash2 = ents.Create( "dimension_slash_tenebre" )
						slash2:SetPos( pos )
						slash2:SetAngles( ang ) slash2:SetOwner( own )
						slash2:Spawn() slash2:Activate() own:DeleteOnRemove( slash2 )
						slash2:GetPhysicsObject():SetVelocity( dir/0.1 )
						slash2:GetPhysicsObject():EnableGravity( false )
						slash2:SetPhysicsAttacker( own )
					end
				end)
			end
		end)
		timer.Simple(1, function()
			if IsValid(self) and self:GetOwner():Alive() and not self.Owner:KeyDown(IN_ATTACK) then
				self:SetHoldType("rollsword")
				self.Owner:SetAnimation( PLAYER_ATTACK1 )
				config.canatk = true
			end
		end)

	self.CooldownDelay1 = CurTime() + self.Cooldown1
	self.NextAction = CurTime() + self.ActionDelay
	else	
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown1 .."s de cooldown !" )
	end
    return true
end

/*---------------------------------------------------------
	SlashAttack
---------------------------------------------------------*/
function SWEP:MultiSlashAttack()
	if self.Owner:IsOnGround() then
		if self.NextAction > CurTime() then return end
		if self.CooldownDelay2 < CurTime() then if !SERVER then return end
	
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
								self:EmitSound( Combo3 )
								local slash2 = ents.Create( "slash_tenebre" )
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
								self:EmitSound( Combo3 )
								local slash2 = ents.Create( "slash_tenebre" )
								slash2:SetPos( pos )
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
								self:EmitSound( Combo3 )
								local slash2 = ents.Create( "slash_tenebre" )
								slash2:SetPos( pos )
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
					if IsValid(self) and self:GetOwner():Alive() and not self.Owner:KeyDown(IN_ATTACK) then
						self:SetHoldType("rollsword")
						self.Owner:SetAnimation( PLAYER_ATTACK1 )
						config.canatk = true
					end
					config.canSwitch = true
				end)
								
				self.combo = 0
				self.CooldownDelay2 = CurTime() + self.Cooldown2
				self.NextAction = CurTime() + self.ActionDelay
			else	
				self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .."s de cooldown !" )
			end
	end
    return true
end

/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
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

function SWEP:OnRemove()
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
 
	local bar = 2
	
	local powername = 16
	
	local Font = "Trebuchet18"

	if ( ESPSelectPower ) then
		icon = 128
		icongap = 2
		bar = 8
		bar2 = 24
		powername = 20
		Font = "Trebuchet24"
	end
	
	local FrameW = gap + ( ( icon + gap ) * 2 )
	local FrameH = (gap*3) + icon
	
	local FrameWPos = ScrW/2 - (FrameW/2)
	local FrameHPos = ScrH - ( FrameH + gap )
	
	draw.RoundedBox( 0, FrameWPos, FrameHPos, FrameW, FrameH, Color( 20,20,20, 100 ) )
	
	---- power icon
	 
	local iconWPos = FrameWPos + gap
	local iconslot = 1
	local SelectedPower = self:Getmagietenebre4()
	local IconCaseColor = Color(20,20,20, 200 )
	
	
	for id, t in pairs( magietenebre4 ) do
		IconCaseColor = Color(20,20,20, 200 )
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


hook.Add("PlayerButtonDown", "magietenebre4binds", function( ply, button )
	if config.canSwitch == true then if !SERVER then return end
	if button == ply:GetInfoNum( "TouchesBind5", 15) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "magietenebre4" then
					ply:GetActiveWeapon():Setmagietenebre4(1)
			end
		end
	elseif button == ply:GetInfoNum( "TouchesBind6", 28) and ply:IsValid() then
		if ply:GetActiveWeapon():IsValid() then
			if ply:GetActiveWeapon():GetClass() == "magietenebre4" then
					ply:GetActiveWeapon():Setmagietenebre4(2)
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
		self:SetModel( "models/mtod12/slash_effect.mdl" )
		self:SetMaterial("poke/props/plainshiny")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetModelScale( 4, 0 )
		self:ManipulateBoneScale(self:EntIndex(),Vector(10,10,10))
		self:SetSolid( SOLID_NONE	 ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 20,20,20,200 ) )
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 2 )
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		end 
		local own = self:GetOwner()
		for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zoneMultiSlash)) do
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
				util.Effect( "slash_tenebre_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "slash_tenebre" )
end

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
		self:SetModel( "models/mtod12/slash_effect.mdl" )
		self:SetMaterial("poke/props/plainshiny")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetModelScale( 20, 0.1 )
		self:ManipulateBoneScale(self:EntIndex(),Vector(10,10,10))
		self:SetSolid( SOLID_NONE ) 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 20,20,20,200 ) )
		self:GetPhysicsObject():EnableGravity( false )
		SafeRemoveEntityDelayed( self, 3 )
		self.cooldownSlash=0
	end
	function ENT:Think() if !SERVER then return end
		if !self.XDEBZ_Hit then 
			self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		end 
		local own = self.Owner
		if self.cooldownSlash < CurTime() then
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zoneDimSlash)) do
				if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmgSuperSlh1,config.dmgSuperSlh2) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
					self:EmitSound( Hitground2 )
					self.cooldownSlash = CurTime() + 1
				end
			end
		end
	end
	if CLIENT then
		function ENT:Draw() self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "dimension_slash_tenebre_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "dimension_slash_tenebre" )
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
					local particle = self.Emitter:Add( "particles/smokey", ent:GetPos()  + Vector(math.random(-50,50),math.random(-50,50),0) )
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
						particle:SetColor( 10, 10, 10 )
						particle:SetGravity( Vector( 0, 0, 25 ) )
						particle:SetAirResistance( 20 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 3 do
					local particle = self.Emitter:Add( "particles/smokey",ent:GetPos()  + Vector(math.random(-50,50),math.random(-50,50),0) )
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
						particle:SetColor( 10, 10, 10 )
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
	effects.Register( EFFECT, "slash_tenebre_effect" )
end

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
				for i=1, 20 do
					local ppp = ent:GetPos() + Angle( 0, math.Rand( 0, 360 ), 0 ):Right()*math.Rand( 0, 50 )+Vector(0,0,math.random(-600,600))
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp )
					if particle then  local size = math.Rand( 5, 10 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.5, 1 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 10, 10, 10 )
						particle:SetGravity( Vector( 0, 0, 10 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 15 do
					local ppp = ent:GetPos() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 0, 50 ) +Vector(0,0,math.random(-600,600))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.8, 1.5 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 1, 2 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 10, 10, 10 )
						particle:SetGravity( Vector( 0, 0, 10 ) )
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
	effects.Register( EFFECT, "dimension_slash_tenebre_effect" )
end