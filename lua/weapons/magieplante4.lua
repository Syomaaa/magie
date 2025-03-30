AddCSLuaFile()

SWEP.PrintName 		      = "Plante 4" 
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

SWEP.Category             = "Plante"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

----------------------------------------------------------------------------------------------------------------------

--[[------------------------------
Configuration
--------------------------------]]
local config = {}
config.tmp = 10 -- temps que reste les arbres et degats / pas mettre trop bas ou bug
config.tree1 = 30  
config.tree2 = 30  -- nombre d'arbres de .. à ..
config.dmg1 = 50
config.dmg2 = 50 -- degats de .. à ..


SWEP.ActionDelay = 1 -- Time in between each action.

SWEP.NextAction = 0

SWEP.CooldownDelay = 0

SWEP.Cooldown = 20

----------------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

----------------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then
	if !SERVER then return end

	if IsValid(self.Owner) and self.Owner:IsOnGround() and self:WaterLevel() == 0 then
		local pos = self.Owner:GetPos()
		timer.Create("trees"..self:EntIndex(),0.09,math.random(config.tree1,config.tree2),function()
			if(IsValid(self) && self:GetOwner():Alive()) then
				local startpos = self.Owner:GetPos() + Vector(math.Rand(-200,200),math.Rand(-200,200),0)
				local traceworld = {}
				traceworld.start = startpos
				traceworld.endpos = traceworld.start - Vector(0,0,100)
				traceworld.fliter = function(ent) if !ent:IsWorld() then return false end end
				traceworld.mask = MASK_SOLID_BRUSHONLY
				local trw = util.TraceLine(traceworld)

				if trw.HitWorld and !(self.Owner:GetPos():Distance(trw.HitPos) <= 100) then 
					local decpos1 = trw.HitPos + trw.HitNormal
					local decpos2 = trw.HitPos - trw.HitNormal
					
					local ag = math.random(0,360)
					local tree = ents.Create("ent_tree")
					tree:SetPos(trw.HitPos - Vector(0,0,10))
					tree:SetAngles(Angle(0,ag,0))
					tree:Spawn()
					tree:GetPhysicsObject()

					SafeRemoveEntityDelayed(tree,config.tmp)
				end
			end
		end)
		timer.Create("damage_continue".. self:EntIndex(),0.5,config.tmp*2,function()
			if(IsValid(self) && self:GetOwner():Alive()) then
				for k,v in pairs(ents.FindInSphere(pos,500)) do
					if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						dmginfo:SetDamagePosition( pos )
						dmginfo:SetAttacker( self.Owner )
						dmginfo:SetInflictor( self )
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
		end)
	end
	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown  ..  "s de cooldown !" )
	end
end

----------------------------------------------------------------------------------------------------------------------

function SWEP:Think()
end

function SWEP:SecondaryAttack()
end