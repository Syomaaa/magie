AddCSLuaFile()

SWEP.PrintName 		      = "Songe 4" 
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

SWEP.Category             = "Songe"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

local config = {}

SWEP.Cooldown = 30

SWEP.ActionDelay = 0.2

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 15
config.dmg2 = 20 -- dmg de .. à ..
config.tmp = 10 -- temps de l'attaque

config.zone = 500 -- zone de tp
config.dgttmp = 0.3 -- degat tout les ... s 

-- donc si tu veux 750dgt tu te demerde pour que ce soit correct mdr : t'as le temps de zone / degats toutes les .. s / et les degats

config.pos =  Vector(1191.203857, -4060.561035, -14652.122070)

config.slow = 2 -- vitesse divise par ..

config.switch = true

Songe4Active = false

playerPositionsSonge = {}

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

function SWEP:Think()
end
-------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if infini4Active == true or Songe4Active == true then self.Owner:PrintMessage( HUD_PRINTCENTER, "Il y a déjà une dimension créée !" ) return false end

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

		if SERVER then

			config.switch = true

			local own = self:GetOwner()

			local pos = config.pos
			local size = Vector(1500, 1500, 1500)

			local explo = ents.Create("base_anim")
			explo:SetModel( "models/hunter/misc/sphere175x175.mdl" )
			explo:SetMaterial("models/shiny")
			explo:SetSolid( SOLID_NONE ) 
			explo:SetMoveType( MOVETYPE_NONE )
			explo:PhysicsInit(SOLID_NONE)
			explo:SetRenderMode( RENDERMODE_TRANSCOLOR )
			explo:SetColor( Color( 190,10,130,255 ) )
			explo:SetModelScale(10,0.5)
			explo:SetPos(pos)
			explo:SetParent(own)
			explo:Spawn()
			explo:Activate()
			SafeRemoveEntityDelayed( explo, 0.5 )

			
			timer.Simple(0.5,function()
				if IsValid(self) && IsValid(own) then

					for k,v in pairs(ents.FindInSphere(self:GetPos(),config.zone)) do
						if IsValid(v) and (v:IsPlayer() or v:IsNPC()) then
							playerPositionsSonge[v] = v:GetPos() -- Stocke la position initiale du joueur dans la table
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

					local flooreff = ents.Create("flooreff")
					flooreff:SetModel("models/cgi_joe/terrain/trodden_soil.mdl")
					flooreff:SetPos(pos - Vector(0,0,40))
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

					timer.Create("toy"..flooreff:EntIndex(), 0.1, config.tmp*10, function()
						if (IsValid(flooreff) && IsValid(self) && self:GetOwner():Alive() ) then
							local air = flooreff:GetPos() - Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-600,-20))
							local pluie = ents.Create("songe4_prop")
							pluie:SetPos(air)
							pluie:SetOwner(self:GetOwner())
							pluie:Activate()
							pluie:Spawn()
						end
					end)

					if IsValid(self) then
						for k,v in pairs(ents.FindInSphere(flooreff:GetPos(),1500)) do
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
							for k,v in pairs(ents.FindInSphere(self:GetPos(),1500)) do
								if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC()) and own:Alive() then
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

					timer.Simple(config.tmp-0.5,function()
						-- Boucle sur tous les joueurs présents dans la table playerPositionsSonge
						for k,v in pairs(playerPositionsSonge) do
							if IsValid(k) then
								-- Téléporter le joueur à sa position initiale
								k:SetPos(v)
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

-------------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	if config.switch == false then
		return false
	else
		return true
	end
end

-- Fonction appelée lorsqu'un joueur meurt
hook.Add("PlayerDeath", "RemovePlayerFromTable", function(victim, _, attacker)
    -- Vérifier que le joueur mort est présent dans la table playerPositionsSonge
    if playerPositionsSonge[victim] then
        -- Supprimer le joueur de la table playerPositionsSonge
        playerPositionsSonge[victim] = nil
    end
	-- Vérifier que le joueur mort est présent dans la table playerPositionsInfini
	if playerPositionsInfini[victim] then
		-- Supprimer le joueur de la table playerPositionsInfini
		playerPositionsInfini[victim] = nil
	end
end)

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "songe3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/cgi_joe/terrain/trodden_soil.mdl" )
		self:SetMaterial("models/shiny")
		self:SetSolid( SOLID_NONE ) 
		self:SetMoveType( MOVETYPE_NONE )
		self:PhysicsInit(SOLID_NONE)
		self:SetModelScale(15,0.1)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 190,10,130,255 ) )
		local own = self.Owner
		SafeRemoveEntityDelayed( self, config.tmp )
		
		local celling = ents.Create("songe4")
		celling:SetPos(self:GetPos())
		celling:SetParent(self)
		celling:SetOwner(own)
		celling.Owner = own
		celling:Spawn()
		celling:Activate()

		
	end

	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "flooreff" )
end

if true then
	local toy = {
		"models/roblox/a_very_special_monster.mdl",
		"models/roblox/blue_sleepy_koala.mdl",
		"models/roblox/cat_of_the_week__bat_cat.mdl",
		"models/roblox/shoulder_shark_cat.mdl",
		"models/roblox/owl_of_the_week__witch_owl.mdl",
		"models/roblox/friendly_swamp_monster.mdl",
		"models/roblox_assets/the_bird_says____.mdl",
		"models/roblox/skeleton_owl.mdl",
		"models/roblox/snowboarding_penguin.mdl",
		"models/roblox_assets/from_the_vault_dozens_of_dinosaurs_dinosaur.mdl",
		"models/roblox_assets/frog_king.mdl",
		"models/roblox/sophisiticated_crow.mdl",
		"models/roblox/sophisticated_bat.mdl",
		"models/roblox_assets/ghostly_monster_friend.mdl",
		"models/roblox_assets/rocket_cat.mdl"
	} 
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "songe3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Effect = false  ENT.XDEBZ_Hit = false  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( toy[ math.random( #toy ) ] )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetModelScale(math.Rand(8,15),0.1)
		self:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableGravity(true)
		self:GetPhysicsObject():SetMass(0.01)
		SafeRemoveEntityDelayed( self, 3 )
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	if CLIENT then
		function ENT:Draw()
			self:DrawModel()
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "songe4_prop" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "songe3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/hunter/plates/plate32x32.mdl" )
		self:SetMaterial("phoenix_storms/pro_gear_top2")
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:GetPhysicsObject():EnableMotion(false)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 190,10,130,0 ) )
		local own = self.Owner
		SafeRemoveEntityDelayed( self, config.tmp )
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			
		end
	end
	scripted_ents.Register( ENT, "floor" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "songe3"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/jackjack/props/circle3.mdl" )
		self:SetMaterial("models/shiny")
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:GetPhysicsObject():EnableMotion(false)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetColor( Color( 190,10,130,255 ) )
		local own = self.Owner
		Songe4Active = true
		SafeRemoveEntityDelayed( self, config.tmp )	
	end
	function ENT:OnRemove()
		Songe4Active = false
		playerPositionsSonge = {}
	end
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
			if !self.XDEBZ_Effect then self.XDEBZ_Effect = true
				local ef = EffectData()
				ef:SetEntity( self )
				util.Effect( "songe4_effect", ef )
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "songe4" )
end

if SERVER then return end

if true then
	local EFFECT = {}
	function EFFECT:Init( data )
		local ent = data:GetEntity()  if !IsValid( ent ) then return end
		self.Owner = ent  self.Emitter = ParticleEmitter( self.Owner:WorldSpaceCenter() )  self.NextEmit = CurTime()
		self.Emitte2 = ParticleEmitter( self.Owner:WorldSpaceCenter(), true )
		self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )  self.NextLight = CurTime()
	end
	function EFFECT:Think() local ent = self.Owner
		if IsValid( ent ) then self:SetRenderBoundsWS( ent:GetPos() + ent:OBBMaxs(), ent:GetPos() + ent:OBBMins() )
			self.Emitter:SetPos( ent:WorldSpaceCenter() ) self.Emitte2:SetPos( ent:WorldSpaceCenter() )
			if self.NextEmit < CurTime() then self.NextEmit = CurTime() + 0.01
				for i=1, 10 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 50, 100 )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp+ Vector(math.random(-1500,1500),math.random(-1500,1500),-500) )
					if particle then  local size = math.Rand( 20, 30 )
						particle:SetVelocity( VectorRand():GetNormal() * 10 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 3,5 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 190, 10, 130  )
						particle:SetGravity( Vector( 0, 0, 150 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 6 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 50, 100 )
					local particle = self.Emitter:Add( "swarm/particles/particle_smokegrenade1.vmt", ppp+ Vector(math.random(-1500,1500),math.random(-1500,1500),-500) )
					if particle then  local size = math.Rand( 50, 60 )
						particle:SetVelocity( VectorRand():GetNormal() * 300 )
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 5,7 ) )
						particle:SetStartAlpha( 100 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( size )
						particle:SetEndSize( size * 4 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 255, 255, 255  )
						particle:SetGravity( Vector( 100, 100, 100 ) )
						particle:SetAirResistance( 300 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 10 do
					local ppp = ent:WorldSpaceCenter() + Angle( 0, math.Rand( 0, 360 ), 0 ):Forward()*math.Rand( 50, 100 )
					local particle = self.Emitter:Add( "swarm/particles/particle_glow_04.vmt", ppp + Vector(math.random(-1500,1500),math.random(-1500,1500),-500))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetDieTime( math.Rand( 3,5 ) )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( math.Rand( 2, 10 ) )
						particle:SetEndSize( 0 )
						particle:SetAngles( Angle( 0, 0, 0 ) )
						particle:SetRoll( 180 )
						particle:SetRollDelta( 12 )
						particle:SetColor( 190, 10, 130  )
						particle:SetGravity( Vector( 0, 0, 100 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
				for i=1, 10 do
					local particle = self.Emitte2:Add( "swarm/particles/particle_smokegrenade1.vmt", ent:WorldSpaceCenter() + Vector(math.random(-1500,1500),math.random(-1500,1500/1.3),-500))
					if particle then
						particle:SetLifeTime( 0 )
						particle:SetAngles( Angle( 90, CurTime() * 10, 0 ) )
						particle:SetDieTime( 0.5 )
						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetStartSize( 255 )
						particle:SetEndSize( 100 )
						particle:SetColor(190, 10, 130  )
						particle:SetGravity( Vector( 0, 0, 0 ) )
						particle:SetAirResistance( 10 )
						particle:SetCollide( false )
						particle:SetBounce( 0 )
					end
				end
			end
			return true
		end
		if self.Emitter then self.Emitter:Finish() end return false
	end
	function EFFECT:Render() local own = self.Owner
		if IsValid( own ) and self.NextLight < CurTime() then self.NextLight = CurTime() + 0.01
			local dlight = DynamicLight( own:EntIndex() ) if dlight then
				dlight.Pos = own:WorldSpaceCenter()
				dlight.r = 255
				dlight.g = 30
				dlight.b = 200
				dlight.Brightness = 5
				dlight.Size = 1500
				dlight.Decay = 0
				dlight.DieTime = CurTime() + 0.2
			end
		end
	end
	effects.Register( EFFECT, "songe4_effect" )
end