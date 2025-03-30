
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
			particle2 = emitter:Add( "particles/smokey", vOffset )
			if (particle2) then
				
				local Vec2 = VectorRand()
				particle2:SetVelocity( Vector(Vec2.x, Vec2.y, math.Rand(0.1,1.5)) * 300)
				
				particle2:SetLifeTime( 0 )
				particle2:SetDieTime( 1.5 )
				
				particle2:SetStartAlpha( 250 )
				particle2:SetEndAlpha( 0 )
				
				particle2:SetStartSize( 20 )
				particle2:SetEndSize( 30 )
				
				particle2:SetColor(150,150,140)
				
				particle2:SetAirResistance( 250 )
				
				particle2:SetGravity( Vector( 100, 100, -80 ) )
				
				particle2:SetLighting( true )
				particle2:SetCollide( true )
				particle2:SetBounce( 0.5 )
			end
		end
		for i=0, 35 do
			local particle3
			if math.random(1,2) == 1 then
				particle3 = emitter:Add( "effects/fire_cloud1", vOffset )
			else
				particle3 = emitter:Add( "effects/fire_cloud2", vOffset )
			end
			if (particle3) then
				local size = math.random(10,15)
				local sizeend = math.random(20,30)
				local Vec3 = VectorRand()
				particle3:SetVelocity( Vector(Vec3.x, Vec3.y, math.Rand(0.1,1.5)) * 100)
					
				particle3:SetLifeTime( 0 )
				particle3:SetDieTime( 0.5 )
				
				particle3:SetStartAlpha( 255 )
				particle3:SetEndAlpha( 0 )
					
				particle3:SetStartSize( size )
				particle3:SetEndSize( sizeend )
				
				particle3:SetColor(255,140,100)					
				particle3:SetRoll( math.Rand(0, 360) )
				particle3:SetRollDelta( math.Rand(-2, 2) )
					
				particle3:SetAirResistance( 80 )
				
				particle3:SetGravity( Vector( math.Rand(-200,200), math.Rand(-200,200), -200 ) )					
				particle3:SetCollide( true )
				particle3:SetBounce( 1 )
			end
		end
	emitter:Finish()
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

function ParticleThink( part )

	if part:GetLifeTime() > 0.18 && part.nextsmoke <= CurTime() then 
		part.nextsmoke = CurTime() + 0.05
		local vOffset = part:GetPos()	
		local emitter = ParticleEmitter( vOffset )
	
		if emitter == nil then return end
		local particle = emitter:Add( "particles/smokey", vOffset )
		
		if (particle) then
		
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 3.5 - part:GetLifeTime() * 2 )
				
			particle:SetStartAlpha( 150 )
			particle:SetEndAlpha( 0 )
				
			particle:SetStartSize( (90 - (part:GetLifeTime() * 100)) / 2 )
			particle:SetEndSize( 100 - (part:GetLifeTime() * 100) )
				
			particle:SetColor(150,150,140)
				
			particle:SetRoll( math.Rand(-0.5, 0.5) )
			particle:SetRollDelta( math.Rand(-0.5, 0.5) )
				
			particle:SetAirResistance( 250 )
				
			particle:SetGravity( Vector( 200, 200, -100 ) )
				
			particle:SetLighting( true )
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )

		end		
		emitter:Finish()
	end
	
	part:SetNextThink( CurTime() + 0.1 )
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end
