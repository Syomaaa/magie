SWEP.PrintName 		      = "Infini 4" 
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

SWEP.Category             = "Infini"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}
config.dmg1 = 15
config.dmg2 = 20 -- dmg de .. à ..
config.tmp = 10 -- temps de l'attaque

config.zone = 500 -- zone de tp
config.dgttmp = 0.3 -- degat tout les ... s 

-- donc si tu veux 750dgt tu te demerde pour que ce soit correct mdr : t'as le temps de zone / degats toutes les .. s / et les degats

config.pos =  Vector(1191.203857, -4060.561035, -14652.122070)

config.slow = 2 -- vitesse divise par ..

SWEP.Cooldown = 30

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

infini4Active = false

local playerPositionsInfini = {}

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

--------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if infini4Active == true or Songe4Active == true  then self.Owner:PrintMessage( HUD_PRINTCENTER, "Il y a déjà une dimension créée !" ) return false end

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		if SERVER then

			config.switch = true

			local own = self:GetOwner()

			local pos = config.pos
			local size = Vector(1500, 1500, 1500)

			timer.Simple(0.01,function()
				if IsValid(self) && IsValid(own) then

					for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
						if IsValid(v) and (v:IsPlayer() or v:IsNPC()) then
							playerPositionsInfini[v] = v:GetPos() -- Stocke la position initiale du joueur dans la table
							local x = math.random(-500, 500) -- Valeur aléatoire pour l'axe x
							local y = math.random(-500, 500) -- Valeur aléatoire pour l'axe y
							local z = 50 -- Valeur fixe pour l'axe z (le sol)
							
							v:SetPos(pos + Vector(x, y, z)) -- Téléporte le joueur à la nouvelle position
						end
					end

					local floor_thickness = 4 
					local floor_size = Vector(size.x / 2, size.y / 2, floor_thickness / 2)
					
					for i = 1, 4 do
						local floor = ents.Create("floor")
						if i == 1 then
							floor:SetPos(pos + Vector(floor_size.x, floor_size.y, -50 - floor_size.z))
						elseif i == 2 then
							floor:SetPos(pos + Vector(-floor_size.x, floor_size.y, -50 - floor_size.z))
						elseif i == 3 then
							floor:SetPos(pos + Vector(floor_size.x, -floor_size.y, -50 - floor_size.z))
						else
							floor:SetPos(pos + Vector(-floor_size.x, -floor_size.y, -50 - floor_size.z))
						end
						floor:Spawn()
						floor:Activate()
						
						floor:SetParent(floor)
						SafeRemoveEntityDelayed( floor, config.tmp )
					end

					local flooreff = ents.Create("inf4")
					flooreff:SetPos(pos)
					flooreff:SetParent(floor)
					flooreff:Spawn()
					flooreff:Activate()

					local hide = ents.Create("base_anim")
					hide:SetModel( "models/hunter/misc/sphere175x175.mdl" )
					hide:SetMaterial("debug/env_cubemap_model")
					hide:SetSolid( SOLID_NONE ) 
					hide:SetMoveType( MOVETYPE_NONE )
					hide:PhysicsInit(SOLID_NONE)
					hide:SetModelScale(50,0.1)
					hide:SetPos(pos)
					hide:SetParent(floor)
					hide:Spawn()
					hide:Activate()
					SafeRemoveEntityDelayed( hide, config.tmp+3 )

					if IsValid(self) then
						for k,v in pairs(ents.FindInSphere(flooreff:GetPos(),1550)) do
							if v:IsPlayer() and v:Alive() then -- Vérifier si le joueur est en vie et n'a pas déjà été affecté
								local runSpeed = v:GetRunSpeed()
								local walkSpeed = v:GetWalkSpeed()
								local jumpPower = v:GetJumpPower()
								v:SetRunSpeed(runSpeed / config.slow)
								v:SetWalkSpeed(walkSpeed / config.slow)
								v:SetJumpPower(jumpPower / config.slow)
								own:GodEnable()
								timer.Simple(config.tmp, function()
									if IsValid(v) and v:Alive() then -- Vérifier si le joueur est toujours en vie avant de rétablir sa vitesse
										v:SetRunSpeed(runSpeed)
										v:SetWalkSpeed(walkSpeed)
										v:SetJumpPower(jumpPower)
									end
									own:GodDisable()
								end)
							end
						end
					end

					timer.Create("dgt"..flooreff:EntIndex(), config.dgttmp, config.tmp/config.dgttmp*10, function()
						if (IsValid(flooreff) && IsValid(self) && self:GetOwner():Alive() ) then
							for k,v in pairs(ents.FindInSphere(flooreff:GetPos(),1550)) do
								if IsValid(v) and (v:IsPlayer() or v:IsNPC()) and v != own  and own:Alive() then
									local dmginfo = DamageInfo()
									dmginfo:SetDamageType( DMG_GENERIC  )
									dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
									dmginfo:SetDamagePosition( self:GetPos() )
									dmginfo:SetAttacker(own )
									dmginfo:SetInflictor( own )
									v:TakeDamageInfo(dmginfo)
								end
							end
						end
					end)
					
					timer.Simple(config.tmp - 0.5, function()
						for k, v in pairs(playerPositionsInfini) do
							if IsValid(k) then

								-- Vérifiez si le joueur est toujours dans la zone en parcourant les entités voisines
								local isInZone = false
								for _, ent in pairs( ents.FindInSphere(flooreff:GetPos(), 1550)) do
									if ent == k then
										isInZone = true
										break
									end
								end
					
								if isInZone then
									k:SetPos(v)
								end
							end
						end
					end)	
					
					
				end
			end)

			timer.Simple(config.tmp,function()
				config.switch = true
			end)

		end

		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

--------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	return true
end

function SWEP:SecondaryAttack()
	return false
end

if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "inf4"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/cgi_joe/terrain/trodden_soil.mdl")
			self:SetMaterial("random-space")
			self:PhysicsInit( SOLID_NONE )
			self:SetMoveType( MOVETYPE_NONE )
			self:SetSolid( SOLID_NONE )
			self:SetModelScale(14)
			self:SetPos(self:GetPos()-Vector(0,0,30))
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:EmitSound("ambient/fire/firebig.wav",60,100,0.8)
			self:DrawShadow( false )

			local celling = ents.Create("infi41")
			celling:SetPos(self:GetPos()+Vector(0,0,-100))
			celling:SetParent(self)
			celling:SetOwner(own)
			celling.Owner = own
			celling:Spawn()
			celling:Activate()

			local idx = "inf4"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "[5]simple_galaxy", 1, self, 1 )
				end
			end)
		
			SafeRemoveEntityDelayed(self,config.tmp)
		end
	end
	function ENT:OnRemove()
		self:StopSound("ambient/fire/firebig.wav")
	end
	function ENT:Think()
		self:SetAngles(self:GetAngles() + Angle(0,1,0))

		self:NextThink(CurTime() + 0.06)
		return true
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel( )
		end
	end
	scripted_ents.Register( ENT, "inf4" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "infi41"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/jackjack/props/circle3.mdl" )
		self:SetMaterial("random-space")
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:PhysicsInit(SOLID_VPHYSICS)
		--self:GetPhysicsObject():EnableMotion(false)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		local own = self.Owner
		infini4Active = true
		SafeRemoveEntityDelayed( self, config.tmp )	
	end
	function ENT:OnRemove()
		infini4Active = false
	end
	function ENT:Think()
		self:SetAngles(self:GetAngles() + Angle(0,0.1,0))
		self:NextThink(CurTime() + 0.03)
		return true
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "infi41" )
end