
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
		for i=0, 20 do	
			particle2 = emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", vOffset )
			if (particle2) then
				
				local Vec2 = VectorRand()
				particle2:SetVelocity( Vector(Vec2.x, Vec2.y, math.Rand(-0.4,0.4)) * 1500)
				
				particle2:SetLifeTime( 0 )
				particle2:SetDieTime( 2 )
				
				particle2:SetStartAlpha( 250 )
				particle2:SetEndAlpha( 0 )
				
				particle2:SetStartSize( 60 )
				particle2:SetEndSize( 80 )
				
				particle2:SetColor(220,80,40)
				
				particle2:SetAirResistance( 300 )
				
				particle2:SetGravity( Vector( 100, 100, -80 ) )
				
				particle2:SetLighting( true )
				particle2:SetCollide( false )
				particle2:SetBounce( 0 )
			end
		end
		for i=0, 20 do	
			particle = emitter:Add( "effects/fire_cloud1", vOffset )
			if (particle) then
				
				local Vec2 = VectorRand()
				particle:SetVelocity( Vector(Vec2.x, Vec2.y, math.Rand(-0.4,0.4)) * 1000)
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 2 )
				
				particle:SetStartAlpha( 250 )
				particle:SetEndAlpha( 0 )
				
				particle:SetStartSize( 40 )
				particle:SetEndSize( 60 )
				
				particle:SetColor(200, 170, 170)
				
				particle:SetAirResistance( 300 )
				
				particle:SetGravity( Vector( 100, 100, -80 ) )
				
				particle:SetLighting( true )
				particle:SetCollide( false )
				particle:SetBounce( 0 )
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
