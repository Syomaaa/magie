AddCSLuaFile()

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
    self:SetSolid( SOLID_NONE) 
    self:SetRenderMode( RENDERMODE_TRANSCOLOR )
    self:SetColor( Color( 200,240,200,200 ) )
    self:GetPhysicsObject():EnableGravity( false )
    SafeRemoveEntityDelayed( self, 2 )
end
function ENT:Think() if !SERVER then return end
    if !self.XDEBZ_Hit then
        self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
    end 
    local own = self:GetOwner()
    for k,v in pairs(ents.FindInSphere(self:GetPos() ,500)) do
		if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
            local dmginfo = DamageInfo()
            dmginfo:SetDamageType( DMG_GENERIC  )
            dmginfo:SetDamage( math.random(166,167) )
            dmginfo:SetDamagePosition( self:GetPos()  )
            dmginfo:SetAttacker( own )
            dmginfo:SetInflictor( own )
            v:TakeDamageInfo(dmginfo)
            self:EmitSound( "custom characters/attack4_hit.mp3" )
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
            util.Effect( "bourasque_effect", ef )
            self:DrawShadow( false )
        end
    end
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
						particle:SetColor( 200, 240, 200 )
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
						particle:SetColor( 200, 240, 200 )
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
	effects.Register( EFFECT, "bourasque_effect" )
end