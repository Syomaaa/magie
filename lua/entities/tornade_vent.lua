AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "tornadeVent"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Owner = nil
function ENT:Initialize()
    self:DrawShadow( false ) if !SERVER then return end
    self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_NONE ) 
    self:SetRenderMode( RENDERMODE_NORMAL )
    self:SetModelScale(0.7,0.1)
    SafeRemoveEntityDelayed(self,2)
    self.dmgTor = 0
end
function ENT:Think() 
    if !SERVER then return end
    self:SetPos(self.Owner:GetPos())

    if self.dmgTor < CurTime() then
        for k,v in pairs(ents.FindInSphere(self.Owner:GetPos() ,500)) do
            if IsValid(v) and v != self.Owner then
                local dmginfo = DamageInfo()
                dmginfo:SetDamageType( DMG_GENERIC  )
                dmginfo:SetDamage( math.random(75,75) )
                dmginfo:SetDamagePosition( self.Owner:GetPos() )
                dmginfo:SetAttacker( self.Owner )
                dmginfo:SetInflictor( self.Owner )
                v:TakeDamageInfo(dmginfo)
            end
        end
        self.dmgTor = CurTime() + 0.3
    end

    self:NextThink(CurTime())
    return true
end
if CLIENT then
    function ENT:Draw()
        if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
            local ef = EffectData()
            ef:SetEntity( self )
            util.Effect( "tornade_vent_eff", ef )
            self:DrawShadow( false )
        end
    end
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  
		self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  
		self.NextEmit = CurTime() 
		self.zone = 100
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
		ent.RenderOverride = function( ent )
			render.SuppressEngineLighting( true ) ent:DrawModel() render.SuppressEngineLighting( false )
		end
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
					local particle = self.Emitter:Add( "vent/vent"..math.random(1,4)..".vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 70, self.zone ) + Vector(0,0,math.random(0,200)))
					if particle then  local size = math.Rand( 2, 4 )
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 100 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.4, 0.6) )
						particle:SetStartAlpha( 200 )
						particle:SetEndAlpha( 100 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 90 ) )
						particle:SetColor( 230,255, 230 )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 100 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
					for i=1, 3 do
						local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 70, self.zone ) + Vector(0,0,math.random(0,200)))
						if particle then  local size = math.Rand( 5, 10 )
							particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 100 )
							particle:SetLifeTime( 0 )
							particle:SetDieTime( math.Rand( 0.4, 0.6) )
							particle:SetStartAlpha( 200 )
							particle:SetEndAlpha( 100 )
							particle:SetStartSize( size )
							particle:SetEndSize( size * 4 )
							particle:SetAngles( Angle( 0, 0, 90 ) )
							particle:SetColor( 200,255, 200 )
							particle:SetGravity( Vector( 0, 0, 100 ) )
							particle:SetAirResistance( 100 )
							particle:SetCollide( false )
							particle:SetBounce( 0 )
						end
					end

				
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 70, self.zone )+ Vector(0,0,math.random(0,200))
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp )
					if particle then
						particle:SetVelocity( VectorRand( -1, 1 ):GetNormal() * 100 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 0.4, 0.6 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 160 )
						particle:SetStartSize( math.Rand( 5, 10 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 200, 255, 200 )
						particle:SetGravity( Vector( 0, 0, 400 ) )
						particle:SetAirResistance( 100 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
					self.zone = self.zone+1
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render()
		
	end
	effects.Register( EFFECT, "tornade_vent_eff" )
end