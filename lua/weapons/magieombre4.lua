AddCSLuaFile()
 
SWEP.PrintName 		      = "Ombre 4" 
SWEP.Author 		      = "Brounix" 
SWEP.Instructions 	      = "" 
SWEP.Contact 		      = "" 
SWEP.AdminSpawnable       = true 
SWEP.Spawnable 		      = true 
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV 	      = 85
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.AutoSwitchFrom       = true 
SWEP.DrawAmmo             = false 
SWEP.Base                 = "weapon_base" 
SWEP.Slot 			      = 2
SWEP.SlotPos              = 1 
SWEP.HoldType             = "magic"
SWEP.DrawCrosshair        = true 
SWEP.Weight               = 0 

SWEP.Category             = "Ombre"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "None"

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.Minion = nil

---------------------------------------------------------------------------------------------------------

SWEP.Cooldown = 60

SWEP.ActionDelay = 1

SWEP.NextAction = 0
SWEP.CooldownDelay = 0

local config = {}
config.dmg1 = 20
config.dmg2 = 20
config.hitbox = 200
config.zoneBall = 300
config.cooldownball = 1

config.dmgzone1 = 20
config.dmgzone2 = 20
config.zone = 500
config.cooldownzone = 0.5

config.tmp = 30  -- temps de l atk

---------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )

end

---------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()
		
	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if CLIENT then return end


		local own = self.Owner
		if IsValid( feePet ) then 
			own:PrintMessage( HUD_PRINTCENTER, "Un seul minion à la fois !" )
			return 
		end

		local zone = ents.Create( "demon_zone" )
		zone:SetPos( own:GetPos() )
		zone:SetOwner( own )
		zone:Spawn() 
		zone:Activate() 
		own:DeleteOnRemove( zone )
		zone:SetPhysicsAttacker( own )
		undo.Create( "zone" )
		undo.AddEntity( zone ) 
		undo.SetPlayer( own ) 
		undo.Finish()


		timer.Create("demon"..self:EntIndex(),0.6,4,function()
			if self:IsValid() then
				local demon = ents.Create( "demon" )
				demon:SetPos( own:GetShootPos() +own:EyeAngles():Forward()*40 )
				demon:SetAngles( own:EyeAngles() ) 
				demon:SetOwner( own )
				demon:Spawn() 
				demon:Activate() 
				demon:EmitSound( "npc/ichthyosaur/water_growl5.wav" )
				own:DeleteOnRemove( demon )
				demon:SetPhysicsAttacker( own )

				undo.Create( "demon" )
				undo.AddEntity( demon ) 
				undo.SetPlayer( own ) 
				undo.Finish()
			end
		end)



		self.CooldownDelay = CurTime() + self.Cooldown
		self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end

end

---------------------------------------------------------------------------------------------------------

function SWEP:SecondaryAttack()
	return true
end

function SWEP:Holster()
	return true
end

function GhostAttack( tar, atk, per, fce, own )
	if !isvector( fce ) or ( isnumber( tar.Immune ) and tar.Immune > CurTime() ) then fce = Vector( 0, 0, 0 ) end fce = fce * 0.1
	if tar:IsOnFire() then tar:Extinguish() end if isnumber( per ) and atk != tar then

		local pos = own:GetPos()
		local ball = ents.Create( "ombre_ball" )
		ball:SetPos( pos )
		ball:SetAngles( own:EyeAngles() + Angle(0,150,0) ) 
		ball:SetOwner( atk or own )
		ball:Spawn() 
		ball:Activate() 
		own:DeleteOnRemove( ball )
		ball:GetPhysicsObject():SetVelocity( fce * 20 )
		ball:SetPhysicsAttacker( own )
	end
end

if true then
	local ENT = {}
	ENT.PrintName = "demon"
	ENT.Base = "base_anim"
	ENT.hp = 1000
	ENT.Tick = 0  
	ENT.Dead = false
	ENT.Owner = nil  
	ENT.Enemy = nil  
	ENT.NextFind = 0

	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end 
		self:SetModel( "models/ori_u_npc.mdl" )
		self:SetMoveType( MOVETYPE_NOCLIP ) 
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON ) 
		self:DrawShadow( false )
		self:SetColor(Color(10,10,10,200))
		self:SetModelScale(3,0)
		self:SetBloodColor( DONT_BLEED )
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:UseTriggerBounds( self:OBBMins(), self:OBBMaxs() )
		self:SetMaxHealth( self.hp ) 
		self:SetHealth( self:GetMaxHealth() )
		SafeRemoveEntityDelayed( self, config.tmp )


	end
	function ENT:Think() self:NextThink( CurTime() ) self.Tick = self.Tick + 0.01  local tic = self.Tick
		if SERVER then
	
		end
		if SERVER and IsValid( self.Owner ) then 
			local own = self.Owner
			if self:IsOnFire() then 
				self:Extinguish() 
			end 
			if own:IsOnFire() then 
				own:Extinguish() 
			end
			local top = Vector( math.sin( tic *4 )*own:OBBMaxs().x*12, math.cos( tic *4)*own:OBBMaxs().x*12, own:OBBMaxs().z +math.sin( tic*2 )*10 + 100)
			local tr = util.TraceLine( {
				start = own:EyePos(),
				endpos = own:EyePos() + top,
				filter = { own, self },
				mask = MASK_SHOT_HULL
			} )
			local vel = tr.HitPos + tr.HitNormal*20  
			local ang = self:GetVelocity():Angle().yaw 
			vel = ( vel - self:EyePos() )  
			local spd = math.max( vel:Length(), 0 )
			vel:Normalize() 
			self:SetLocalVelocity( vel * spd * 10 ) 
			if self:WorldSpaceCenter():Distance( own:EyePos() + top ) >= 2048 then
				self:SetPos( own:EyePos() + top ) 
			end
			local def = self:GetAngles().yaw  
			def = Lerp( 0.2, def, ang  )  
			self:SetAngles( Angle( 0, def, 0 ) )

			if self.NextFind < CurTime() then self.NextFind = CurTime() + config.cooldownball
				local tar = nil  local dis = -1
				for k, v in pairs( ents.FindInSphere( self:WorldSpaceCenter(), 1000 ) ) do
					if IsValid( v ) and ( v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and v != own and v != self then
						local ddd = v:WorldSpaceCenter():DistToSqr( self:WorldSpaceCenter() )
						
						if dis == -1 or ddd < dis then
							local tr = util.TraceLine( {
								start = self:WorldSpaceCenter(),
								endpos = v:WorldSpaceCenter(),
								filter = { own, self },
							} )
							if !tr.Hit or tr.Entity == v then dis = ddd  tar = v end
						end
					end
				end 
				self.Enemy = tar 
				self.anime = false
				if IsValid( self.Enemy ) then
					local ppp = ( self.Enemy:WorldSpaceCenter() - self:WorldSpaceCenter() + Vector(0,0,20)):GetNormal()*1000
					GhostAttack( self.Enemy, self.Owner, 5, ppp, self)
				end
			end
		end 
		return true
	end
	function ENT:OnRemove()
        
    end
	if CLIENT then 
		function ENT:Draw() 
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end 
	end
	scripted_ents.Register( ENT, "demon" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "demon zone"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.NextFind = 0
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel( "models/props/slow/smoke_effect/slow_smoke_effect.mdl" )
		self:SetSolid( SOLID_NONE )  
		self:SetMoveType( MOVETYPE_NONE )
		self:SetColor(Color(60,255,60,255))
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetPos( self:GetPos() ) 

		local par = ents.Create( "info_particle_system" ) 
		par:SetKeyValue( "effect_name", "[3]_cursed_ground_add_6" )
		par:SetKeyValue( "start_active", "1" )
		par:SetParent(self)
		par:SetPos( self:GetPos() ) 
		par:SetAngles( self:GetAngles() )
		par:Spawn() 
		par:Activate() 

		SafeRemoveEntityDelayed( self, config.tmp)
	end
	function ENT:Think()
		if SERVER then
			if self.NextFind < CurTime() then self.NextFind = CurTime() + config.cooldownzone
				for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
					if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") and self:IsValid() then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmgzone1,config.dmgzone2) )
						dmginfo:SetDamagePosition( self:GetPos()  )
						dmginfo:SetAttacker( self.Owner )
						dmginfo:SetInflictor( self.Owner )
						v:TakeDamageInfo(dmginfo)
					end
				end  
			end
		end

		self:SetPos(self.Owner:GetPos())
		self:NextThink( CurTime()) 
		return true
	end
	if CLIENT then
		function ENT:Draw()

		end
	end
	scripted_ents.Register( ENT, "demon_zone" )
end



if true then
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_anim"
	ENT.PrintName = "ombre1"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/maxofs2d/hover_classic.mdl")
			self:PhysicsInit( SOLID_VPHYSICS )
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )
			self:SetRenderMode( RENDERMODE_TRANSCOLOR )
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:DrawShadow(false)
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:EnableGravity(false)
			end

			local par = ents.Create( "info_particle_system" ) 
			par:SetKeyValue( "effect_name", "[3]_dark_tornado_ground_trail" )
			par:SetKeyValue( "start_active", "1" )
			par:SetParent(self)
			par:SetPos( self:GetPos() ) 
			par:SetAngles( self:GetAngles() )
			par:Spawn() 
			par:Activate() 

			SafeRemoveEntityDelayed(self,2)
		end
	end
	function ENT:PhysicsCollide( data, phys )
		self:GetPhysicsObject():EnableMotion( false )
		SafeRemoveEntityDelayed( self, 0 )
	end
	function ENT:Think() if !SERVER then return end
		self:GetPhysicsObject():AddVelocity( self:GetPhysicsObject():GetVelocity():GetNormal()*2000 ) 
		self:NextThink( CurTime() ) return true
	end
	function ENT:OnRemove()
		if SERVER then

			ParticleEffect("[3]_buff_aura",self:GetPos(),Angle(0,0,0),self)


			local own = self.Owner
			for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zoneBall)) do
                if IsValid(v) and v != own and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType( DMG_GENERIC  )
					dmginfo:SetDamage( math.random(config.dmg1,config.dmg1) )
					dmginfo:SetDamagePosition( self:GetPos()  )
					dmginfo:SetAttacker( own )
					dmginfo:SetInflictor( own )
					v:TakeDamageInfo(dmginfo)
				end
			end  
		end
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "ombre_ball" )
end