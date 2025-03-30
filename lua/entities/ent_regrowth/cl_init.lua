ENT.Spawnable = true
ENT.AdminOnly = true

include('shared.lua')

game.AddParticles( "particles/wow_regrowth.pcf" )

function ENT:Initialize()

	local function spawneffect()
		if self:IsValid() == false then return end
		self:CreateParticleEffect( "green", 1, { 0, ent, Vector(0, 0, 0) } )
	end
	local function spawneffect1_2()
		if self:IsValid() == false then return end
		self:CreateParticleEffect( "green_thick", 1, { 0, ent, Vector(0, 0, 0) } )
	end
	local function spawneffect2()
		if self:IsValid() == false then return end
		self:CreateParticleEffect( "green_spark", 1, { 0, ent, Vector(0, 0, 0) } )
		self:CreateParticleEffect( "leaves", 1, { 0, ent, Vector(0, 0, 100) } )
	end
	local function spawneffect3()
		if self:IsValid() == false then return end
		self:CreateParticleEffect( "leaves2", 1, { 0, ent, Vector(0, 0, 100) } )
	end
	local function spawneffect4()
		if self:IsValid() == false then return end
		self:CreateParticleEffect( "leaves3", 1, { 0, ent, Vector(0, 0, 100) } )
	end
	local function spawneffect5()
		if self:IsValid() == false then return end
		self:CreateParticleEffect( "leaves4", 1, { 0, ent, Vector(0, 0, 100) } )
	end
	
	timer.Simple( 0, spawneffect );
	timer.Simple( 0.5, spawneffect1_2 );
	timer.Simple( 1, spawneffect2 );
	timer.Simple( 1.5, spawneffect3 );
	timer.Simple( 2, spawneffect4 );
	timer.Simple( 2, spawneffect5 );
	
end

function ENT:Think()
	if self.Owner:IsValid() == false then return end
	self.Entity:SetPos(self.Owner:GetPos())
end