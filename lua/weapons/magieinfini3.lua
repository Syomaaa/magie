SWEP.PrintName 		      = "Infini 3" 
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
config.dmg1 = 37.5
config.dmg2 = 37.5
config.tmp = 5
config.zone = 500

SWEP.Cooldown = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0

--------------------------------------------------------------------------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( "magic" )
end

--------------------------------------------------------------------------------------------------------------

function SWEP:PrimaryAttack()

	if self.NextAction > CurTime() then return end
	if self.CooldownDelay < CurTime() then if !SERVER then return end

	    config.switch = true

		local inf3u3 = ents.Create("inf3")
		inf3u3:SetPos(self.Owner:GetPos())
		inf3u3:SetOwner(self.Owner )
		inf3u3:Spawn()

		timer.Simple(config.tmp,function()
			config.switch = true
		end)

	self.CooldownDelay = CurTime() + self.Cooldown
	self.NextAction = CurTime() + self.ActionDelay
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
	end
end

--------------------------------------------------------------------------------------------------------------

function SWEP:Holster()
	if config.switch == false then
		return false
	else
		return true
	end
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
	ENT.PrintName = "inf3"
	ENT.Spawnable = false
	ENT.AdminOnly = false

	function ENT:Initialize()
		if SERVER then
			self:SetModel("models/hunter/misc/sphere2x2.mdl")
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

			local idx = "inf3"..self:EntIndex()
			timer.Create(idx,0.01,1,function()
				if IsValid(self) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetScale(1)
					effectdata:SetEntity(self)
					ParticleEffectAttach( "[7]_hollow_purple", 1, self, 1 )
				end
			end)

			SafeRemoveEntityDelayed(self,config.tmp)

			self.cdDelay = 0
			self.cdDelay2 = 0
		end
	end
	function ENT:Think()
		if SERVER then
			if self.cdDelay <= CurTime() then
				for k,v in pairs(ents.FindInSphere(self:GetPos() ,config.zone)) do
					if IsValid(v) and v != self.Owner and (v:IsPlayer() or v:IsNPC() or type( v ) == "NextBot") then
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType( DMG_GENERIC  )
						dmginfo:SetDamage( math.random(config.dmg1,config.dmg2) )
						v:AddEFlags("-2147483648" )
						dmginfo:SetDamagePosition( self:GetPos()  )
						dmginfo:SetAttacker( self.Owner )
						dmginfo:SetInflictor( self.Owner )
						v:TakeDamageInfo(dmginfo)
						v:RemoveEFlags("-2147483648" )
					end
				end  
				self.cdDelay = CurTime() + 0.2
			
			end
			if self.cdDelay2 <= CurTime() then
				local spawnPos = self:GetPos() + Vector(math.random(-400, 400), math.random(-400, 400), -500)

				local prop = ents.Create("inf3_1")
				prop:SetPos(spawnPos)
				prop:SetOwner(self)
				prop:Spawn()

				local phys = prop:GetPhysicsObject()
				phys:SetVelocity((self:GetPos() - prop:GetPos()):GetNormalized() * 3000)

				self.cdDelay2 = CurTime() + 0.05
			end
		end

		local own = self.Owner
		local tra = util.TraceLine( {
		start = own:EyePos(), 
		endpos = own:EyePos() + own:EyeAngles():Forward()*1000,
		mask = MASK_NPCWORLDSTATIC, 
		filter = { self, own } } )  
		local ptt = tra.HitPos + tra.HitNormal*10
		if self:GetPos():Distance( ptt ) > 100 then 
			self:SetPos( self:GetPos() + ( ptt - self:GetPos() ):GetNormal()*50 ) 
		end
		self:NextThink(CurTime())
		return true
	end
	function ENT:OnRemove()
	end
	if CLIENT then
		function ENT:Draw()
			if !self.Effect then self.Effect = true
				self:DrawShadow( false )
			end
		end
	end
	scripted_ents.Register( ENT, "inf3" )
end

if true then
	local ENT = {}
	ENT.Base = "base_anim"
	ENT.PrintName = "inf3_1"
	ENT.Spawnable = false
	ENT.RenderGroup = RENDERGROUP_BOTH
	ENT.XDEBZ_Broken = false  ENT.XDEBZ_FreezeTab = {}  ENT.XDEBZ_FreezeTic = 0  ENT.XDEBZ_Lap = 1  ENT.XDEBZ_Gre = 1
	function ENT:Initialize()
		self:DrawShadow( false ) if !SERVER then return end
		self:SetModel("models/rock/scattersmooth_04.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		self:GetPhysicsObject():Wake()
		SafeRemoveEntityDelayed( self, 1)
		self.touch = true
	end
	function ENT:Think()
		if SERVER then
			for k,v in pairs(ents.FindInSphere(self:GetPos() - Vector(0,0,150), 300)) do
				if IsValid(v) and IsValid(self) and v == self.Owner and self.touch then
					-- ... (le code de dommages que vous avez déjà)
					self.touch = false
					
					self:SetParent(self.Owner)
				end
			end
		end
		
		self:NextThink(CurTime() + 0.2)
		return true
	end
	
	function ENT:OnRemove()
		self:StopSound("physics/concrete/concrete_break"..math.random(2,3)..".wav")
		
		-- Supprimer le joint lorsque l'entité inf3_1 est supprimée
		if IsValid(self.WeldJoint) then
			self.WeldJoint:Remove()
		end
	end
	
	if CLIENT then
		function ENT:Draw()
			render.SuppressEngineLighting( true )
			self:DrawModel()
			render.SuppressEngineLighting( false )
		end
	end
	scripted_ents.Register( ENT, "inf3_1" )
end