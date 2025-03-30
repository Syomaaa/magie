/*
	�2016 Metamorphics
	(STEAM_0:1:52851671 is the one and only author)
	Covered by Attribution-NonCommercial-NoDerivatives 4.0 International
	http://creativecommons.org/licenses/by-nc-nd/4.0/
	http://creativecommons.org/licenses/by-nc-nd/4.0/legalcode
*/

AddCSLuaFile()

SWEP.PrintName = "Temps 2"
SWEP.Author = "Metamorphics"
SWEP.Instructions = "Left click to control time of an individual. Right click to control time in the vacinity."
SWEP.Category = "Temps"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.Base = "weapon_base"
SWEP.HoldType = "magic"
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo	= "none"
SWEP.DrawAmmo = false

SWEP.Cooldown = 10
SWEP.Cooldown2 = 15
SWEP.ActionDelay = 0.2
SWEP.NextAction = 0
SWEP.CooldownDelay = 0
SWEP.CooldownDelay2 = 0

SWEP.PrimDel = CurTime()
SWEP.PulledThePin = 0
SWEP.DrawOnce = 0
SWEP.ThrowDel = CurTime()

SWEP.SecPickUpGren = 0
SWEP.PickUpDel = CurTime()
SWEP.TheSlowThing = NULL
SWEP.AnotherSlowThing = NULL

SWEP.ApplyForceDel = CurTime()

SWEP.PlayRewind = 0
SWEP.TimeTravelDel = CurTime()
SWEP.TimeTravel = NULL
SWEP.HandSound = NULL
SWEP.HandSDel = CurTime()

SWEP.TimeSwap = {}
SWEP.TimeSwapAng = {}
SWEP.TimeSwapVel = {}
SWEP.TimeNum = 0
SWEP.TimeNumTwo = 0
SWEP.TimeSwapDel = CurTime()
SWEP.RelDel = CurTime()

SWEP.DisableSecOnce = 0
SWEP.DisableFirstOnce = 0


/*
	Intialization
*/

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
    if SERVER then
        self:SetWeaponHoldType( "grenade" )
    end

    self.HandSound = CreateSound(self.Weapon,"TimeGrenade/HandTime.mp3") 
    self.TimeTravel = CreateSound(self.Weapon,"TimeGrenade/TimeTravel.mp3") 
end

/*
	Attacks
*/

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay < CurTime() then if !SERVER then return end
        local Owner = self.Owner
        local tr = Owner:GetEyeTrace()
        if (tr.HitNonWorld) and (IsValid(tr.Entity)) and tr.Entity:IsPlayer() and SERVER then
            tr.Entity:SetLaggedMovementValue(0.05)

            self.enemy = tr.Entity

            local temps_zone3 = ents.Create( "temps_zone2" ) 
			temps_zone3:SetPos( tr.Entity:GetPos())
            temps_zone3:SetParent( tr.Entity)
			temps_zone3:Spawn() 
			temps_zone3:Activate() 
            SafeRemoveEntityDelayed(temps_zone3,4)

            timer.Create(tr.Entity:EntIndex().."_gpow_TimeControl", 4, 1, function()
                tr.Entity:SetLaggedMovementValue(1)
                self.enemy = nil
            end)

        end
        self.CooldownDelay = CurTime() + self.Cooldown
        self.NextAction = CurTime() + self.ActionDelay
    else
        self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as " .. self.Cooldown .."s de cooldown !" )
    end
end

function SWEP:Think()
	if self.enemy then
		if self.enemy:IsPlayer() then
			local weapon = self.enemy:GetWeapon("keys")
			if IsValid(weapon) then
				self.enemy:SelectWeapon(weapon)
			end
		end
	end
end

function SWEP:SecondaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay2 < CurTime() then if !SERVER then return end
        local Owner = self.Owner
        for k,v in pairs(ents.FindInSphere(Owner:GetPos(), 500)) do
            if v ~= Owner and IsValid(v) and v:IsPlayer() and SERVER then
                v:SetLaggedMovementValue(0.05)

                local temps_zone3 = ents.Create( "temps_zone2" ) 
                temps_zone3:SetPos( v:GetPos())
                temps_zone3:SetParent( v)
                temps_zone3:Spawn() 
                temps_zone3:Activate() 
                SafeRemoveEntityDelayed(temps_zone3,4)

                timer.Create(v:EntIndex().."_gpow_TimeControl", 4, 1, function()
                    v:SetLaggedMovementValue(1)
                end)
            end
        end
        self.CooldownDelay2 = CurTime() + self.Cooldown2
        self.NextAction = CurTime() + self.ActionDelay
    else
        self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as 15s de cooldown !" )
    end
end

function SWEP:Think()
------TimeRewind
if self.TimeSwapDel < CurTime() and not ( self.Owner:KeyDown( IN_RELOAD  ) ) then
    self.PlayRewind = 0
    self.TimeTravelDel = CurTime()
    self.TimeTravel:Stop()
    self.TimeSwapDel = CurTime()+5
    self.TimeNum =  self.TimeNum + 1
    self.TimeNumTwo = self.TimeNum
    self.TimeSwap[self.TimeNum] = self.Owner:GetPos()
    self.TimeSwapAng[self.TimeNum] = self.Owner:EyeAngles( )
    self.TimeSwapVel[self.TimeNum] = self.Owner:Health()
    end
    
   ------TimeRewind END
       if not ( self.Owner:KeyDown( IN_ATTACK ) ) and self.PulledThePin == 1 and self.ThrowDel < CurTime() then
           self.DrawOnce = 0
           self.PulledThePin = 0
           self.PrimDel = CurTime() + 2
           self.Weapon:SendWeaponAnim(ACT_VM_THROW)
   
           self.Weapon:EmitSound("weapons/slam/throw.wav" )
           
           if(SERVER) then
               local ent = ents.Create("sent_TimeGrenade")
               ent:SetPos(self.Owner:GetShootPos())
               ent:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
               ent:SetOwner(self.Weapon:GetOwner())
               ent:Spawn()
               ent:Activate()
   
               ent:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() * 750)
           end
       end
   
   
           if self.DrawOnce == 0 then
           self.DrawOnce = 1
           self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
           end
   
           if self.SecPickUpGren == 1 and self.PickUpDel < CurTime() then
           self.SecPickUpGren = 0
           self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
           end
       
       if not ( self.Owner:KeyDown( IN_ATTACK2 ) ) then
       
           self.HandSound:Stop()
           self.HandSDel = CurTime()
       if self.TheSlowThing ~= NULL and self.TheSlowThing ~= nil then    
           
           if self.TheSlowThing:IsValid() and self.DisableSecOnce == 0 then
   
           self.DisableSecOnce = 1
           
               if string.find(self.TheSlowThing:GetClass(), "prop_physics") or string.find(self.TheSlowThing:GetClass(), "prop_vehicle_*") then
                   self.TheSlowThing:GetPhysicsObject():EnableGravity(true)
                   self.TheSlowThing:GetPhysicsObject():Wake()
               end
                   if string.find(self.TheSlowThing:GetClass(), "prop_ragdoll") then
   
                       local bones = self.TheSlowThing:GetPhysicsObjectCount()
   
                           for i=0,bones-1 do
                                self.TheSlowThing:GetPhysicsObjectNum(i):EnableGravity(true)
                               self.TheSlowThing:GetPhysicsObjectNum(i):Wake()
                           end 
   
                   end
   
           end
       end
       
       
       end
       
end

function SWEP:Draw()
    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:Holster()
    self.HandSound:Stop()
    self.TimeTravel:Stop()
   
       if self.TheSlowThing ~= NULL and self.TheSlowThing ~= nil then    
           if self.TheSlowThing:IsValid() then
   
               if string.find(self.TheSlowThing:GetClass(), "prop_physics") or string.find(self.TheSlowThing:GetClass(), "prop_vehicle_*") then
                   self.TheSlowThing:GetPhysicsObject():EnableGravity(true)
                   self.TheSlowThing:GetPhysicsObject():Wake()
               end
                   if string.find(self.TheSlowThing:GetClass(), "prop_ragdoll") then
   
                       local bones = self.TheSlowThing:GetPhysicsObjectCount()
   
                           for i=0,bones-1 do
                                self.TheSlowThing:GetPhysicsObjectNum(i):EnableGravity(true)
                               self.TheSlowThing:GetPhysicsObjectNum(i):Wake()
                           end 
   
                   end
   
           end
       end
       
    self.TimeNum =  0
    self.TimeNumTwo = self.TimeNum
       
       return true
end

function SWEP:Reload()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay2 < CurTime() then if !SERVER then return end
    if self.RelDel < CurTime() and self.TimeNum ~= 0 then 
        if self.PlayRewind == 0 and self.TimeTravelDel < CurTime() and (SERVER) then
            self.TimeTravelDel = CurTime() + 20    
            self.TimeTravel:Stop()
            self.TimeTravel:Play()
        end

        local RewLimit = self.TimeNumTwo - 80

        if self.TimeNum > RewLimit then
            self.RelDel = CurTime()+0.05
            
            if (SERVER) then
                self.Owner:SetPos(self.TimeSwap[self.TimeNum])
                self.Owner:SetEyeAngles(self.TimeSwapAng[self.TimeNum])
                self.Owner:SetVelocity(Vector(0,0,0)) 
                self.Owner:SetVelocity((self.Owner:GetVelocity()*-1)) 
                self.Owner:Fire("sethealth", ""..self.TimeSwapVel[self.TimeNum].."", 0)
            end
            self.TimeNum =  self.TimeNum - 1

            local ef = EffectData()
            ef:SetOrigin(self.Owner:GetPos())
            util.Effect("TimeRev",ef)
        end 

        if self.TimeNum == RewLimit and (SERVER) then
            self.TimeNum = 0
            self.TimeTravel:Stop()
        end
    end 
    
    if self.TimeNum == 0 then
        self.TimeTravel:Stop()
    end 
    self.CooldownDelay2 = CurTime() + self.Cooldown2
        self.NextAction = CurTime() + self.ActionDelay
    else
        self.Owner:PrintMessage( HUD_PRINTCENTER, "Tu as 15s de cooldown !" )
    end
end