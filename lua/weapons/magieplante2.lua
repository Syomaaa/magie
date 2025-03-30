AddCSLuaFile()

SWEP.PrintName 		      = "Plante 2" 
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
config.atk1 = 10
config.atk2 = 10

SWEP.ActionDelay = 0.2 -- Time in between each action.

SWEP.NextAction = 0

SWEP.CooldownDelay = 0

SWEP.Cooldown = 11.5

config.tmpfreeze = 1.5

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
				timer.Create("plant2".. self:EntIndex(),0.09,math.random(config.atk1,config.atk1),function()
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
							
							local plant = ents.Create("ent_entangling_roots")

								plant:SetAngles(Angle(0,0,0))
								plant:SetPos(trw.HitPos)
								plant:SetOwner(owner)
								plant:Spawn()
								plant:Activate()

							local function delete()
							plant:Remove();
								
						end

						timer.Simple( 5, delete );
				
						for k,v in pairs(ents.FindInSphere(trw.HitPos,500)) do
							if IsValid(v) and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != self.Owner then
								local dmginfo = DamageInfo()
								dmginfo:SetDamageType( DMG_GENERIC  )
								dmginfo:SetDamage( 25 )
								dmginfo:SetDamagePosition( self.Owner:GetPos() )
								v:AddEFlags("-2147483648" )
								dmginfo:SetAttacker( self.Owner )
								dmginfo:SetInflictor( self )
								v:TakeDamageInfo(dmginfo)
								v:RemoveEFlags("-2147483648" )

								if IsValid(v) and v != self.Owner and (v:IsPlayer())  then
									v:SetMoveType(MOVETYPE_NONE)
									v:Freeze(true)
									timer.Simple(config.tmpfreeze,function()
										if IsValid(v) then
											v:SetMoveType(MOVETYPE_WALK)
											v:Freeze(false)
										end
									end)
								end
								if IsValid(v) and v:IsNPC() and v != self.Owner then
									v:SetCondition( 67 )
									timer.Simple(config.tmpfreeze,function()
										if IsValid(v) then
											v:SetCondition( 68 )
										end
									end)
								end

							end
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