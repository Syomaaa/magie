AddCSLuaFile()

SWEP.PrintName 		      = "Miroir 2" 
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
config.dmg1 = 10
config.dmg2 = 20  -- dmg de .. à ..

SWEP.Cooldown = 4

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

SWEP.TravelDistance = 30000
SWEP.TravelTime = 0.12
SWEP.TravelSpeed = 4000

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end


-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	local own = self.Owner

	local tp = ents.Create( "tp" )
	tp:SetPos( own:GetPos() + own:GetForward()*50 )
	tp:SetAngles( own:GetAngles() - Angle(0,180,0) ) 
	tp:SetOwner( own )
	tp:Spawn() 
	tp:Activate()

	timer.Simple(0.1,function()
		local tra = util.TraceLine( {
			start = own:EyePos(), 
			endpos = own:EyePos() + own:EyeAngles():Forward()*600,
			mask = MASK_NPCWORLDSTATIC, 
			filter = { self, own }
		} )  
		
		local ptt = tra.HitPos + tra.HitNormal
		if self:GetPos():Distance( ptt ) > 10 then 
			own:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*600 ) 
		end
	end)

	timer.Simple(0.1,function()
		local tp = ents.Create( "tp" )
		tp:SetPos( own:GetPos() + own:GetForward()* -50 )
		tp:SetAngles( own:GetAngles() ) 
		tp:SetOwner( own )
		tp:Spawn() 
		tp:Activate()
	end)

	own:EmitSound("ambient/machines/slicer4.wav", 100, 100, 0.8)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else		
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
    return true

end

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "miroir"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/blueflytrap/darksouls2/weapons/mirror_shield.mdl" )
		self:SetSolid( SOLID_NONE ) self:SetMoveType( MOVETYPE_NONE )
		self:SetTrigger( true )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:UseTriggerBounds( true, 0 )
		self:SetColor( Color( 255,100,255,255 ) )
		self:SetModelScale( 1, 0.2 ) local own = self.Owner
		SafeRemoveEntityDelayed( self,1 )
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			local ef = EffectData()
			ef:SetEntity( self )
			util.Effect( "tp_effect", ef )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "tp" )
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
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 1
				for i=0,1 do
					local particle2 = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)) )
					if particle2 then  local size = math.Rand( 3, 6 )
						particle2:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 50 )
						particle2:SetLifeTime( 0 )
						particle2:SetDieTime( math.Rand( 0.1, 0.5 ) )
						particle2:SetStartAlpha( 255 )
						particle2:SetEndAlpha( 0 )
						particle2:SetStartSize( size )
						particle2:SetEndSize( size * 4 )
						particle2:SetAngles( Angle( 0, 0, 0 ) )
						particle2:SetRoll( 180 )
						particle2:SetRollDelta( 6 )
						particle2:SetColor(255, 150, 250 )
						particle2:SetGravity( Vector( 0, 0, 25 ) )
						particle2:SetAirResistance( 10 )
						particle2:SetCollide( false )
						particle2:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()

	end
	effects.Register( EFFECT, "tp_effect" )
end