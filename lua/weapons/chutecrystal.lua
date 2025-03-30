SWEP.PrintName 				= "Crystal 4"
SWEP.Slot 					= 4
SWEP.SlotPos 				= 0
SWEP.DrawAmmo 				= false
SWEP.DrawCrosshair 			= true

SWEP.Author					= "tomlap77"
SWEP.Instructions			= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Category				= "Crystal"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.HoldType 				= "magic"
SWEP.ViewModel 				= "models/weapons/c_arms.mdl"
SWEP.WorldModel 			= ""
SWEP.UseHands 				= true

SWEP.Primary.Delay			= 0.2
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= false
SWEP.Primary.Ammo         	= "RPG_Round"

SWEP.Cooldown = 20
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

function SWEP:Initialize()
	self:SetHoldType("magic")
end

if SERVER then 
util.AddNetworkString("123boom")
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()

    if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end
	
		if SERVER then 

		tr = self.Owner:GetEyeTrace()
		hitpos = tr.HitPos

			local spike = ents.Create("prop_physics")
			spike:SetModel("models/props_xen/crystal1_rotate.mdl")
               spike:SetModelScale(35)

			spike:SetPos( hitpos + Vector(0,0,150) )
			spike:SetAngles(Angle(0,0,0))
			spike:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
			spike:Spawn()
			spike:EmitSound("Breakable.Concrete")
			local phys = self:GetPhysicsObject()

					net.WriteEntity(spike)
					net.Broadcast()

					for _,vic in pairs(ents.FindInSphere(hitpos, 500)) do
                        if IsValid(vic) then
						if (vic:IsNPC() or vic:IsPlayer() or type(vic) == "NextBot") and (vic != self.Owner) then
							local dmginfo = DamageInfo()
								dmginfo:SetAttacker( self.Owner )
								dmginfo:SetInflictor( self.Owner:GetActiveWeapon() )
								dmginfo:SetDamage( 500 )
								dmginfo:SetDamageType( DMG_SHOCK )
								vic:TakeDamageInfo( dmginfo )
							end
						end
					end
	end
     self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
     else
	self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
     end
end

function SWEP:Think()
end