AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( "models/balle_mercure/Iceball2.mdl" )
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(true);
	end
	self.Trail = util.SpriteTrail(self.Entity, 0, currentcolor, false, 15, 1, 0.2, 1/(15+1)*0.5, "trails/laser.vmt") 
end

function ENT:Think()
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 100;
	local ent = ents.Create("ent_");
	ent:SetPos(SpawnPos);
	ent:Spawn();
	ent:Activate();
	ent:SetOwner(ply)
	return ent;
end

function ENT:PhysicsCollide(data)
	local pos = self.Entity:GetPos() --Get the position of the snowball
	local effectdata = EffectData()
	data.HitObject:ApplyForceCenter(self:GetPhysicsObject():GetVelocity() * 20000)
	if(damageactivated == 1) then
		data.HitObject:GetEntity():TakeDamage(1000);	
	end
	for k,v in pairs(ents.FindInSphere(self:GetPos() ,500)) do
		if IsValid(v) and v != self.Owner then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_GENERIC  )
			dmginfo:SetDamage( math.random(35,35) )
			dmginfo:SetDamagePosition( self:GetPos() )
			dmginfo:SetAttacker( self.Owner )
			dmginfo:SetInflictor( self.Owner )
			v:TakeDamageInfo(dmginfo)
		end
	end
	effectdata:SetStart( pos )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( 1.5 )
	self:EmitSound("hit.wav")
	//util.Effect( "watersplash", effectdata ) -- effect
	util.Effect( "inflator_magic", effectdata ) -- effect
	util.Effect( "WheelDust", effectdata ) -- effect
	util.Effect( "GlassImpact", effectdata ) -- effect
	self.Entity:Remove(); --Remove the snowball
end 