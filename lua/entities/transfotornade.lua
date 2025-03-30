AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName        = "Transformation Tornage"
ENT.Category         = "Transformation"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:AddEffects(EF_NODRAW)
		self:GetPhysicsObject():EnableGravity( false )
  	local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
	end

	if CLIENT then
		ParticleEffectAttach( "[18]_wins_slashes_around", 1, self, 1 )
	end
end

function ENT:Think() if !SERVER then return end

    self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 

    local own = self:GetOwner()
    for k,v in pairs(ents.FindInSphere(self:GetPos() ,200)) do
        if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
            local dmginfo = DamageInfo()
            dmginfo:SetDamageType( DMG_GENERIC  )
            dmginfo:SetDamage( math.random(300,500) )
            dmginfo:SetDamagePosition( self:GetPos()  )
            dmginfo:SetAttacker( own )
            dmginfo:SetInflictor( own )
            v:TakeDamageInfo(dmginfo)
            self:GetPhysicsObject():EnableMotion( false )
            SafeRemoveEntityDelayed( self, 0 )
        end
    end  
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:PhysicsCollide()
	self:Remove()
end