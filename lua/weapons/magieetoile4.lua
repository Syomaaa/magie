AddCSLuaFile()

SWEP.PrintName 		      = "Etoile 4" 
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

SWEP.Category             = "Etoile"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

config.dmg1 = 20
config.dmg2 = 20


--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
	return true
end


function SWEP:Think()
    local own = self.Owner

	if !IsValid(own) and !IsAlive(own) and !IsValid(self) then return end

    if own:KeyDown(IN_ATTACK) then
      	local eyePos = own:EyePos()
        local eyeForward = own:EyeAngles():Forward()
        local tr = util.TraceLine({
            start = eyePos,
            endpos = eyePos + eyeForward * 5000,
			mask = MASK_NPCWORLDSTATIC, 
        })

        local pos = tr.HitPos + tr.HitNormal*8
        local effectdata = EffectData()
        effectdata:SetStart(pos)
        effectdata:SetOrigin(eyePos + eyeForward * 100)
        util.Effect("laser_etoile_small", effectdata)

		local tr = util.TraceHull({
			start = eyePos,
			endpos = eyePos + eyeForward * 5000,
			filter = function(ent)
				if ent == own then return end
	
				if ent:IsValid() then
					ent:TakeDamage(math.random(config.dmg1, config.dmg2), own, self)
					if ent:IsValid() then
						return false
					end
				end
			end,
			mins = Vector(-20, -20, -20),
			maxs = Vector(20, 20, 20),
			mask = MASK_SHOT_HULL
		})

			
		if !SERVER then return end

		timer.Simple(0,function()
			if IsValid(self) and IsValid(own) then
				if !IsValid(self.etoile1) and !IsValid(self.etoile2) and !IsValid(self.etoile3) and !IsValid(self.etoile4) then
					self.etoile1 = ents.Create( "etoile4_boule" )
					self.etoile1:SetPos( own:GetPos() + Vector(0,0,80) + own:GetForward()*60 + own:GetRight()*30 )
					self.etoile1:SetAngles( Angle(0,0,0) ) 
					self.etoile1:SetParent(own)
					self.etoile1:SetOwner( own )
					self.etoile1:Spawn() 
					self.etoile1:Activate() 
				
					self.etoile2 = ents.Create( "etoile4_boule" )
					self.etoile2:SetPos( own:GetPos() + Vector(0,0,80) + own:GetForward()*60 + own:GetRight()*-30 )
					self.etoile2:SetAngles( Angle(0,0,0) ) 
					self.etoile2:SetParent(own)
					self.etoile2:SetOwner( own )
					self.etoile2:Spawn() 
					self.etoile2:Activate() 
				
					self.etoile3 = ents.Create( "etoile4_boule" )
					self.etoile3:SetPos( own:GetPos() + Vector(0,0,30) + own:GetForward()*60 + own:GetRight()*30 )
					self.etoile3:SetAngles( Angle(0,0,0) ) 
					self.etoile3:SetParent(own)
					self.etoile3:SetOwner( own )
					self.etoile3:Spawn() 
					self.etoile3:Activate() 
				
					self.etoile4 = ents.Create( "etoile4_boule" )
					self.etoile4:SetPos( own:GetPos() + Vector(0,0,30) + own:GetForward()*60 + own:GetRight()*-30 )
					self.etoile4:SetAngles( Angle(0,0,0) ) 
					self.etoile4:SetParent(own)
					self.etoile4:SetOwner( own )
					self.etoile4:Spawn() 
					self.etoile4:Activate() 
				
				end
			end
		end)

		timer.Simple(0,function()
			if IsValid(self) and IsValid(own) then
				local effectdata1 = EffectData()
				effectdata1:SetStart(eyePos + eyeForward * 100)
				effectdata1:SetOrigin(self.etoile1:GetPos())
				util.Effect("laser_etoile_small", effectdata1)

				local effectdata2 = EffectData()
				effectdata2:SetStart(eyePos + eyeForward * 100)
				effectdata2:SetOrigin(self.etoile2:GetPos())
				util.Effect("laser_etoile_small", effectdata2)

				local effectdata3 = EffectData()
				effectdata3:SetStart(eyePos + eyeForward * 100)
				effectdata3:SetOrigin(self.etoile3:GetPos())
				util.Effect("laser_etoile_small", effectdata3)

				local effectdata4 = EffectData()
				effectdata4:SetStart(eyePos + eyeForward * 100)
				effectdata4:SetOrigin(self.etoile4:GetPos())
				util.Effect("laser_etoile_small", effectdata4)
			end
		end)

    end

	if !own:KeyDown(IN_ATTACK) then
		SafeRemoveEntity(self.etoile1)
		SafeRemoveEntity(self.etoile2)
		SafeRemoveEntity(self.etoile3)
		SafeRemoveEntity(self.etoile4)
	end

    self:NextThink(CurTime())
    return true
end


function SWEP:Holster()
	if !IsValid(self.etoile1) and !IsValid(self.etoile2) and !IsValid(self.etoile3) and !IsValid(self.etoile4) then return true end
	SafeRemoveEntity(self.etoile1)
	SafeRemoveEntity(self.etoile2)
	SafeRemoveEntity(self.etoile3)
	SafeRemoveEntity(self.etoile4)
	return true
end


-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "etoile4_boule"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_NONE )
			self:SetMoveType( MOVETYPE_NONE )
			self:SetSolid( SOLID_NONE )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
			self:DrawShadow(false)

			ParticleEffectAttach( "[12]_light", 1, self, 1 )
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "etoile4_boule" )
end