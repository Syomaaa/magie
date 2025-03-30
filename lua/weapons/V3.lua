if SERVER then
    AddCSLuaFile ()
    SWEP.AutoSwitchTo        = true
    SWEP.AutoSwitchFrom        = true
	CreateConVar("mp_allow_playerinteraction","0",{FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_SERVER_CAN_EXECUTE})
elseif CLIENT then
    SWEP.DrawCrosshair        = true
    SWEP.PrintName            = "Roche 4"
    SWEP.BounceWeaponIcon   = false
end

game.AddParticles( "particles/stalactite.pcf" )

SWEP.Base = "weapon_base"
SWEP.Author          = "Hds46"
SWEP.Contact         = "http://steamcommunity.com/profiles/76561198065894505/"
SWEP.Purpose         = "Use earth magic and become the king of the surface."
SWEP.Instructions    = ""
SWEP.Category        = "Roche"

SWEP.Spawnable                = true
SWEP.AdminOnly           = false
SWEP.UseHands = false

SWEP.HoldType             = "melee"
SWEP.ViewModel            = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel            = "models/weapons/w_crowbar.mdl"
SWEP.Slot				= 0
SWEP.SlotPos			= 3
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "None" 

SWEP.Secondary.ClipSize        = -1 
SWEP.Secondary.DefaultClip    = -1 
SWEP.Secondary.Automatic    = true 
SWEP.Secondary.Ammo            = "none"
SWEP.NextAttackSound = 0
SWEP.NextAttackStop = 0
SWEP.NextUseShield = 0

SWEP.Cooldown = 0.4
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local function TretiaryImpact(ent,data)
	if data.HitEntity and data.HitEntity:IsNPC() and data.Speed > 80 and !ent.HitGround then
	ent.HitGround = true
	if data.HitEntity:IsNPC() and (data.HitEntity:GetClass()=="npc_antlionguard" or 
	data.HitEntity:GetClass()=="npc_gman" or
	data.HitEntity:GetClass()=="npc_alyx" or
	data.HitEntity:GetClass()=="npc_monk" or 
	data.HitEntity:GetClass()=="npc_vortigaunt") and SERVER then
	local dmginfo2 = DamageInfo()
	dmginfo2:SetDamage(50)
	dmginfo2:SetDamageType(DMG_GENERIC)
	if data.HitEntity:GetClass()=="npc_antlionguard" then
	dmginfo2:SetDamageType(DMG_GENERIC)
	end
	dmginfo2:SetDamageForce(ent:GetPhysicsObject():GetVelocity()*100)
	dmginfo2:SetDamagePosition(data.HitPos)
	dmginfo2:SetInflictor(ent)
	dmginfo2:SetAttacker(IsValid(ent:GetOwner()) and ent:GetOwner() or ent.RockOwner)
	data.HitEntity:TakeDamageInfo(dmginfo2)
	end
	end
end

local function SecondaryImpact(ent,data)
    if IsValid(ent) and !ent.HitGround then
	ent:EmitSound("novaprospekt.GateGroundCrunch", 60, 100,0.3)
	ent.HitGround = true
	if SERVER then
	for i=1,4 do
	local smoke = ents.Create("ar2explosion")
	if i==1 then
	smoke:SetPos(ent:GetPos() + Vector(0,200,0) )
	elseif i==2 then
	smoke:SetPos(ent:GetPos() + Vector(0,-200,0) )
	elseif i==3	then
	smoke:SetPos(ent:GetPos() + Vector(-200,0,0) )
	elseif i==4 then
	smoke:SetPos(ent:GetPos())
	end
	smoke:SetAngles(ent:GetAngles())
	smoke:SetOwner(ent)
	smoke:Spawn()
	smoke:Activate()
	smoke:Fire("kill","",15)
	end
	end
    end
	if data.HitEntity and data.HitEntity:IsNPC() and SERVER then
	if data.HitEntity:IsNPC() and (data.HitEntity:GetClass()=="npc_antlionguard" or 
	data.HitEntity:GetClass()=="npc_gman" or
	data.HitEntity:GetClass()=="npc_alyx" or
	data.HitEntity:GetClass()=="npc_monk" or
	data.HitEntity:GetClass()=="npc_vortigaunt") and SERVER then
	local dmginfo2 = DamageInfo()
	dmginfo2:SetDamage(50)
	dmginfo2:SetDamageType(DMG_GENERIC)
	if data.HitEntity:GetClass()=="npc_antlionguard" then
	dmginfo2:SetDamageType(DMG_GENERIC)
	end
	dmginfo2:SetDamageForce(ent:GetPhysicsObject():GetVelocity()*100)
	dmginfo2:SetDamagePosition(data.HitPos)
	dmginfo2:SetInflictor(ent)
	dmginfo2:SetAttacker(IsValid(ent:GetOwner()) and ent:GetOwner() or ent.RockOwner)
	data.HitEntity:TakeDamageInfo(dmginfo2)
	end
	end
end

local function PrimaryImpact(ent,data)
    if IsValid(ent) and (data.Speed > 60 and data.DeltaTime > 0.3) and ent.NextSound < CurTime() then
	if data.HitEntity and data.HitEntity:IsNPC() and SERVER then
	if data.HitEntity:IsNPC() and (data.HitEntity:GetClass()=="npc_antlionguard" or 
	data.HitEntity:GetClass()=="npc_gman" or
	data.HitEntity:GetClass()=="npc_alyx" or
	data.HitEntity:GetClass()=="npc_monk" or
	data.HitEntity:GetClass()=="npc_vortigaunt") then
	local dmginfo2 = DamageInfo()
	dmginfo2:SetDamage(50)
	dmginfo2:SetDamageType(DMG_GENERIC)
	if data.HitEntity:GetClass()=="npc_antlionguard" then
	dmginfo2:SetDamageType(DMG_GENERIC)
	end
	dmginfo2:SetDamageForce(ent:GetPhysicsObject():GetVelocity()*100)
	dmginfo2:SetDamagePosition(data.HitPos)
	dmginfo2:SetInflictor(ent)
	dmginfo2:SetAttacker(IsValid(ent:GetOwner()) and ent:GetOwner() or ent.RockOwner)
	data.HitEntity:TakeDamageInfo(dmginfo2)
	end
	end
	ent:EmitSound("Breakable.Concrete", 60, 100,0.3)
	ent.NextSound = CurTime() + 0.3
    end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Equip()
end

function SWEP:Holster()
if SERVER then
self.Owner:SetCanZoom( true )
end
return true
end

function SWEP:OnRemove()
if SERVER then
self.Owner:SetCanZoom( true )
self.Owner.HasShield = false
self.ShieldIsValid = false
self.NextUseShield = CurTime() + 1
for k,v in pairs(ents.FindByClass("prop_physics")) do
if IsValid(v) and v.IsShield and v.Owner == self.Owner then
v:Remove()
end
end
end
end

function SWEP:OnDrop()
if SERVER then
self.Owner:SetCanZoom( true )
self.Owner.HasShield = false
self.ShieldIsValid = false
self.NextUseShield = CurTime() + 1
for k,v in pairs(ents.FindByClass("prop_physics")) do
if IsValid(v) and v.IsShield and v.Owner == self.Owner then
v:Remove()
end
end
end
end

function SWEP:DrawWorldModel()
end

function SWEP:Deploy()
   self.Owner:DrawViewModel(false)
   if SERVER then
   self.Owner:SetCanZoom( false )
   end
end

function SWEP:PrimaryAttack()
if self.NextAction > CurTime() then return end
if self.CooldownDelay < CurTime() then if !SERVER then return end
if !( self:GetNextPrimaryFire() < CurTime() ) then return end
self.Owner:SetAnimation( PLAYER_ATTACK1 )
if CLIENT then return end
if self.NextAttackSound < CurTime() then
self.NextAttackStop = CurTime() + 1
self.Owner:EmitSound("novaprospekt.CaveInRumble", 60, 100,0.3)
self.NextAttackSound = CurTime() + 3
end
local rock = ents.Create("prop_physics")
local mathx = math.random(1,1)
if mathx == 1 then
rock:SetModel("models/rock/rock.mdl")
else
rock:SetModel("models/rock/rock.mdl")
end
rock:SetPos(self.Owner:LocalToWorld(Vector(0,math.random(-0,0),math.random(50,100))))
local Pos = self.Owner:GetEyeTrace().HitPos
local Pos2 = rock:GetPos()
local Ang = Pos - Pos2
Ang = Ang:Angle()
rock:SetAngles(Ang)
rock:Spawn()
rock.IsEarthMagicProj = true
rock.ToRockRemovalList = true
rock:Activate()
if !GetConVar("mp_allow_playerinteraction"):GetBool() then
rock:SetOwner(self.Owner)
else
rock.RockOwner = self.Owner
end
rock:SetPhysicsAttacker( self.Owner, 100 )
rock:GetPhysicsObject():SetMass(750)
rock:GetPhysicsObject():ApplyForceCenter(rock:GetForward()*(500*10000))
rock:GetPhysicsObject():AddAngleVelocity(Vector(0,360,0))
rock:AddCallback( "PhysicsCollide", TretiaryImpact )
SafeRemoveEntityDelayed( rock, 2 )
undo.Create( "Rocks" )
for k,v in pairs(ents.GetAll()) do
if v.ToRockRemovalList then
undo.AddEntity(v)
end
end
undo.SetPlayer( self.Owner )
undo.SetCustomUndoText("Undone Rocks")
undo.ReplaceEntity( rock, rock )
undo.Finish()
self.CooldownDelay = CurTime() + self.Cooldown
self.NextAction = CurTime() + self.ActionDelay
else		
self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
end
end
