
/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.vOffset = data:GetOrigin()
	local vOffset = data:GetOrigin()
	local vNorm = data:GetStart()
	
	local emitter = ParticleEmitter( vOffset )
	if emitter == nil then return end
		for i=0, 30 do	
			particle2 = emitter:Add( "particle/particle_smokegrenade", vOffset )
			if (particle2) then
				
				local Vec2 = VectorRand()
				particle2:SetVelocity( Vector(Vec2.x, Vec2.y, math.Rand(0.1,0.5)) * 2000)
				
				particle2:SetLifeTime( 0 )
				particle2:SetDieTime( 3 )
				
				particle2:SetStartAlpha( 250 )
				particle2:SetEndAlpha( 0 )
				
				particle2:SetStartSize( 120 )
				particle2:SetEndSize( 180 )
				
				particle2:SetColor(200,200,200)
				
				particle2:SetAirResistance( 250 )
				
				particle2:SetGravity( Vector( 100, 100, -80 ) )
				
				particle2:SetLighting( true )
				particle2:SetCollide( false )
				particle2:SetBounce( 0 )
			end
		end
		
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end
