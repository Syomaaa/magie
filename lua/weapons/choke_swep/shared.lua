SWEP.Base = "weapon_base"
SWEP.PrintName = "Choke"
SWEP.Category = "Choke"
SWEP.Author = "SMOK"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/v_regret.mdl"
SWEP.WorldModel = "models/weapons/v_regret.mdl"
SWEP.ViewModelFOV = 64
SWEP.ViewModelFlip = false 
SWEP.BobScale = 1
SWEP.SwayScale = 1
SWEP.Instructions = "Right click to punch"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Automatic = true  
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"


SWEP.ragdollToNPC = {}
SWEP.ragdollToPlayer = {}
SWEP.slowTime = 0

SWEP.isHolding = false 

SWEP.isPlayer = false

SWEP.lastDecalTime  = 0
SWEP.punchTime = 0 

SWEP.chokingDamage = 2


CreateConVar("choke_enable_sound", 1, FCVAR_ARCHIVE)
CreateConVar("choke_enable_damage", 1, FCVAR_ARCHIVE)
CreateConVar("choke_col_dmg_multiplier", 0.3, FCVAR_ARCHIVE)


if CLIENT then

    hook.Add( "PopulateToolMenu", "ChokeMenuSettings", function()
        spawnmenu.AddToolMenuOption( "Utilities", "Choke SWEP", "Choke_Menu", "Choke Options", "", "", function( panel )
            panel:CheckBox("Enable choking sounds", "choke_enable_sound")
			panel:CheckBox("Choking does damage", "choke_enable_damage")
			panel:NumSlider("Collision damage multiplier", "choke_col_dmg_multiplier", 0 , 1)
        end )
    end )

end



local soundList = {
	female = {
		"vo/npc/female01/goodgod.wav",
		"vo/npc/female01/help01.wav"
	},
	male = {
		"vo/npc/male01/goodgod.wav",
		"vo/npc/male01/help01.wav"
	}


}


function SWEP:PrimaryAttack()

	local owner = self:GetOwner()

	local vm = owner:GetViewModel()
	
	self:SetNextPrimaryFire(CurTime() + 0.5)

	
	if self:GetActivity() ~= ACT_VM_PRIMARYATTACK  then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		
	end
	

	local npc = self.Owner:GetEyeTrace().Entity
	local distance = self:GetPos():Distance(npc:GetPos())


	if  not (npc:IsNPC() or npc:IsNextBot() or npc:IsPlayer() or npc:GetClass() == "prop_ragdoll") or distance > 1200 then return end

	-- JUST RAGDOLL
	if npc:GetClass() == "prop_ragdoll" then

		npc:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

		if npc.HP then
			if npc.HP <= 0 then
				npc:PhysWake()
				self.ragdoll = npc
				self.bone = self.Owner:GetEyeTrace().PhysicsBone
				self.living = false 
				return
			else
				self.npc = npc.npc
				self.ragdollHP = npc.HP

			end
		else
			npc:PhysWake()
			self.ragdoll = npc
			self.bone = self.Owner:GetEyeTrace().PhysicsBone
			self.living = true 
			return 
		end
		
		
	end
	
	self.living = true
	local bone_ID = npc:LookupBone("ValveBiped.Bip01_Head1")
	local bone

	if bone_ID ~= nil then 
		bone = npc:TranslateBoneToPhysBone( bone_ID )
	else
		bone = self.Owner:GetEyeTrace().PhysicsBone
	end



	local boneCount = npc:GetBoneCount()

	-- please dont look at this part of the code

	if npc:LookupBone("ValveBiped.Bip01_R_Hand") then
		self.isFemale = false
	end

	if npc:LookupBone("ValveBiped.Bip01_L_Pectoral") then
		self.isFemale = true
	end

	if not self.isFemale then

		for i = 0, boneCount - 1 do
			local boneName = npc:GetBoneName(i)
			if string.match(boneName, "hair") then
				self.isFemale = true
				break 
			end
		end

	end
	

	if SERVER then

	local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetPos(npc:GetPos())
    ragdoll:SetAngles(npc:GetAngles())
    ragdoll:SetModel(npc:GetModel())
	ragdoll:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    ragdoll:Spawn()
    ragdoll:Activate()

	
	--local bone_pos, bone_ang = npc:GetBonePosition(bone)
	

	-- local phys_obj = ragdoll:GetPhysicsObjectNum(bone)
    -- if IsValid(phys_obj) then
		--phys_obj:SetPos(player:EyePos() + player:GetAimVector() * 60)
		--ragdoll:EmitSound("vo/npc/female01/no0"..math.random(1,2)..".wav")
		--phys_obj:SetAngles(npc:GetBoneMatrix(bone):GetAngles())
        --phys_obj:EnableMotion(false)

    -- end


	if npc:IsNPC() or npc:IsNextBot() then
		self.npc = npc:GetClass()
	elseif npc:IsPlayer() then
		
		npc:Freeze(true)
    	npc:Spectate(OBS_MODE_CHASE)
    	npc:SpectateEntity(ragdoll)
		local viewModel = npc:GetViewModel()
		--if IsValid(viewModel) then
		npc:DrawViewModel(false) 
		npc:DrawWorldModel(false)
		--end
		self.npc = npc
		self.isPlayer = true
	end
	
	self.npcModel = npc:GetModel()
	self.ragdoll = ragdoll
	self.bone = bone
	self.time = CurTime() - 2 
	if self.ragdollHP == nil then
		self.ragdollHP = 30
	end


	if not self.isPlayer then
		npc:Remove()
	end

	end
	
end




function SWEP:SecondaryAttack()

	if self:GetActivity() ~= ACT_VM_PRIMARYATTACK then return end

	self:SetNextSecondaryFire(CurTime() + 0.4)
	self:SetNextPrimaryFire(CurTime() + 0.5)


	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self.punchTime = CurTime() + 0.25

	
			
	if self.ragdoll ~= nil then 

		local phys_obj = self.ragdoll:GetPhysicsObjectNum(self.bone)

		timer.Simple(0.2,function()

			phys_obj:ApplyForceOffset((self.Owner:GetRight() )*10000, phys_obj:GetPos() + Vector(0,40,0))
			self.ragdoll:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav")
			self.ragdoll:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1,6)..".wav")
			
			if self.chokingDamage == 2 then
				self.time = CurTime() - 2  
			else
				self.ragdollHP = self.ragdollHP - 2
			end
			--self.ragdollHP = self.ragdollHP - 2   -- remove comment if you want punches to kill faster
					
			local effect = EffectData()
				effect:SetOrigin(phys_obj:GetPos())
			util.Effect("BloodImpact", effect)
			

		end)

	end

end




function SWEP:Think()
	
	if CurTime() - self.slowTime > 0.1 then
		for k , v in pairs(self.ragdollToNPC) do

			hook.Add("Think", "RagdollToNPC", function()
				if IsValid(k) then
					if (CurTime() - k.timer > 2) and k and v and self.Owner and k:GetVelocity():Length() < 5 then
						local npc = ents.Create(tostring(v.npc))
		
						npc:SetModel(v.model)
						npc:SetKeyValue("citizentype",4) -- for dumb anime models
						npc:SetPos(k:GetPos())
						npc:Spawn()
						npc:NextThink(CurTime() + 0.1)
						npc:DropToFloor()
						
		
						if IsValid(npc) then
							
							npc:SetSequence(18)
							
						end
						
						self.ragdollToNPC[k] = nil
						k:Remove()
						hook.Remove("Think", "RagdollToNPC")
					end
				else

					self.ragdollToNPC[k] = nil
					hook.Remove("Think", "RagdollToNPC")

				end
			end)

			-- There probably a better way of doing this but i dont want to spend more time on this
			function BloodOnCollide(obj,data)
					

				local speed = data.HitSpeed:Length()
				
				if (speed > 700)  and (CurTime() - v.time > 0.5) and data.HitEntity ~= k then

					util.Decal("Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
					local effect = EffectData()
					effect:SetOrigin(data.HitPos)
			
					effect:SetScale(1)
					util.Effect("BloodImpact", effect)
					local colSpeed = data.OurOldVelocity - data.OurNewVelocity
					
					local modifier = GetConVar("choke_col_dmg_multiplier"):GetFloat()

					v.HP = v.HP - colSpeed:Length() * modifier
					-- print(v.HP)

					if v.HP < 0 then
						self.ragdollToNPC[v] = nil
						self.ragdollToNPC[k] = nil
						hook.Remove("Think", "RagdollToNPC")
					end
					v.time  = CurTime()

				end
			
			end
			if IsValid(k) then
				k:CallOnRemove("RemoveHook",function() hook.Remove("PhysicsCollide", "BloodOnCollide") end)
				k:AddCallback("PhysicsCollide", BloodOnCollide)
			end
			
		end
		for k , v in pairs(self.ragdollToPlayer) do

			if (CurTime() - k.timer > 2) and k and v and k:GetVelocity():Length() < 5 then

				
				local player = v.npc


				
				--player:SetModel(v.model)
				player:Spawn()
				player:SetPos(k:GetPos())
				player:Freeze(false)
        		player:UnSpectate()
				local viewModel = player:GetViewModel()
				--if IsValid(viewModel) then
				player:DrawViewModel(true)
				player:DrawWorldModel(true)
				--end
				

				if IsValid(npc) then
					
					npc:SetSequence(18)
					
				end
				
				self.ragdollToPlayer[k] = nil
				k:Remove()
			end
			
		end
		
		self.slowTime = CurTime()
	end
	
	if not self.Owner:KeyDown(IN_ATTACK) and not self.Owner:KeyDown(IN_ATTACK2) then

		local owner = self:GetOwner()
		local vm = owner:GetViewModel()

		if self:GetActivity() ~= ACT_VM_IDLE then
			self:SendWeaponAnim (ACT_VM_IDLE)
			vm:SetPlaybackRate(4)  -- for some reason the speed goes down so i need to speed it up
		end

		
		if self.ragdoll then

			self.ragdoll:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			local phys_obj = self.ragdoll:GetPhysicsObjectNum(self.bone)
			
			if phys_obj ~= nil then
				phys_obj:EnableMotion(true)
				phys_obj:Wake()
			end
			
			if self.ragdollHP and self.ragdollHP > 0 then
				if not self.isPlayer then
					self.ragdollToNPC[self.ragdoll] = {npc = self.npc , model = self.npcModel, time = 0, HP = self.ragdollHP}
					self.ragdoll.HP = self.ragdollHP
					self.ragdoll.npc = self.npc -- this is only here for a ragdoll being picked up right after a choke 
				else
					self.ragdollToPlayer[self.ragdoll] = {npc = self.npc , model = self.npcModel}
				end
				self.ragdoll.timer = CurTime()
			end
			
 			
			
			self.npc = nil
			self.npcModel = nil
			self.ragdoll = nil
			self.time = nil
			self.isFemale = nil
			self.ragdollHP = nil
			self.isPlayer = false 

			hook.Remove("PhysicsCollide", "BloodOnCollide")
		end
		
    elseif not self.Owner:KeyDown(IN_ATTACK2) and CurTime() - self.punchTime > 0 then

		if self:GetActivity() ~= ACT_VM_PRIMARYATTACK  then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			
		end
		
		
	end
	

	
	if IsValid(self.ragdoll) then
		
		
		self:SetNextPrimaryFire(CurTime() + 0.3)

		local player_hand_pos, player_hand_ang = self.Owner:GetViewModel():GetBonePosition(self.Owner:GetViewModel():LookupBone("ValveBiped.Bip01_R_Forearm"))

		local phys_obj = self.ragdoll:GetPhysicsObjectNum(self.bone)

		
		local left_hand = self.ragdoll:LookupBone("ValveBiped.Bip01_L_Hand")
		local right_hand = self.ragdoll:LookupBone("ValveBiped.Bip01_R_Hand")

		local hand_bone_L
		local hand_bone_R

		local ragdoll_hand_L
		local ragdoll_hand_R

		if left_hand ~= nil and right_hand ~= nil then

			hand_bone_L = self.ragdoll:TranslateBoneToPhysBone(left_hand)
			hand_bone_R = self.ragdoll:TranslateBoneToPhysBone(right_hand)

			ragdoll_hand_L = self.ragdoll:GetPhysicsObjectNum(hand_bone_L)
			ragdoll_hand_R = self.ragdoll:GetPhysicsObjectNum(hand_bone_R)
		
		end

		if IsValid(phys_obj) then
			
			if( ragdoll_hand_L or ragdoll_hand_R ) and self.ragdollHP and self.ragdollHP > 0 then
				-- if string.match( self.ragdoll:GetModel(), ".*female.*") then
				-- 	ragdoll_hand_L:SetPos(player_hand_pos - player:GetRight()*2)
				-- 	ragdoll_hand_R:SetPos(player_hand_pos + player:GetRight()*4)
				-- else
					--local angle = Angle(-90, 0, 0)
					local angle2 =((ragdoll_hand_L:GetPos() - ragdoll_hand_R:GetPos()):Angle())
					local angle = ((ragdoll_hand_R:GetPos() - ragdoll_hand_L:GetPos()):Angle())
					angle.p = 0
					
					ragdoll_hand_L:SetPos(player_hand_pos + self.Owner:GetAimVector() + self.Owner:GetRight()*2)
					ragdoll_hand_L:SetAngles(angle)
					ragdoll_hand_R:SetPos(player_hand_pos + self.Owner:GetAimVector() - self.Owner:GetRight()*4)
					ragdoll_hand_R:SetAngles(angle2)
				-- end
				
			end

			local current_pos = phys_obj:GetPos()
			local player_pos = self.Owner:EyePos()
			local dir = (player_pos - current_pos):GetNormalized()
			local angle = dir:Angle()
			angle:RotateAroundAxis(angle:Up(), 120)
			
			
			
			phys_obj:SetAngles(angle)

			phys_obj:SetPos(self.Owner:EyePos() + self.Owner:GetAimVector() * 25)


			-- force instead of setpos

			--phys_obj:SetAngles(npc:GetBoneMatrix(bone):GetAngles())
			--phys_obj:EnableMotion(false)
			-- local current_pos = phys_obj:GetPos()
			-- local target_pos = player:EyePos() + player:GetAimVector() * 20
			-- local force_dir = (target_pos - current_pos):GetNormalized()
			-- local dist = current_pos:Distance(target_pos)
			-- local force_strength = 100 * dist 
			-- if dist > 10 then
			-- 	phys_obj:ApplyForceCenter (force_dir * force_strength)
			-- end
			-- if dist < 10 then
			-- 	phys_obj:ApplyForceCenter (force_dir * 700) 
			-- end

			

			local s 
			if self.isFemale then
				s = "female"
			else
				s = "male"
			end

			if self.ragdollHP and self.ragdollHP > 0 then

				local flexID = 1 
				if flexID ~= -1 then 
					self.ragdoll:SetFlexWeight(flexID, 1) 
					self.ragdoll:SetFlexScale((self.ragdollHP / 30) * 1)
				end
				
				
				


				function BloodOnCollide(obj,data)
					

					local speed = data.HitSpeed:Length()
					
					if (speed > 700)  and (CurTime() - self.lastDecalTime > 0.5) and data.HitEntity ~= self.ragdoll then

						util.Decal("Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)
						local effect = EffectData()
						effect:SetOrigin(data.HitPos)
				
						effect:SetScale(1)
						util.Effect("BloodImpact", effect)
						local colSpeed = data.OurOldVelocity - data.OurNewVelocity
						
						local modifier = 0.02

						if self.ragdollHP then
							self.ragdollHP = self.ragdollHP - colSpeed:Length() * modifier
						end
						
						self.lastDecalTime  = CurTime()

					end
				
				end

				self.ragdoll:AddCallback("PhysicsCollide", BloodOnCollide)
				self.ragdoll.timer = CurTime()
				

				if CurTime() - self.time > 2 then

					if GetConVar("choke_enable_damage"):GetBool() == false  then
						self.chokingDamage = 0
					else
						self.chokingDamage = 2
					end

					if (self.isFemale == nil or GetConVar("choke_enable_sound"):GetBool() == false) and self.ragdollHP > 0 then
						self.ragdollHP = self.ragdollHP - self.chokingDamage 
						self.time = CurTime()
						return
					end



					if self.ragdollHP > 28 then
						self.ragdoll:EmitSound("vo/npc/"..s.."01/no0"..math.random(1,2)..".wav")
						
						self.ragdollHP = self.ragdollHP - self.chokingDamage 
						self.time = CurTime()
					elseif self.ragdollHP > 24 then
						self.ragdoll:EmitSound(soundList[s][math.random(1,2)])
						self.ragdollHP = self.ragdollHP - self.chokingDamage 
						self.time = CurTime()
					elseif self.ragdollHP > 10 then
						self.ragdoll:EmitSound("vo/npc/"..s.."01/pain0"..math.random(1,9)..".wav" )
						self.ragdollHP = self.ragdollHP - self.chokingDamage 
						self.time = CurTime()
					elseif self.ragdollHP > 2 then
						self.ragdoll:EmitSound("vo/npc/"..s.."01/ow0"..math.random(1,2)..".wav", (self.ragdollHP / 15) *200)
						self.ragdollHP = self.ragdollHP - self.chokingDamage 
						self.time = CurTime()
					else
						self.ragdoll:EmitSound("vo/npc/"..s.."01/moan0"..math.random(1,5)..".wav")
						self.ragdollHP = self.ragdollHP - self.chokingDamage 
						self.time = CurTime()
					end

				end

			elseif self.isPlayer then


				local player = self.npc

				player:KillSilent()
				player:Freeze(false)
        		player:UnSpectate()
				self.npc = nil 
				self.isPlayer = false

				
			end

		end
	end

end



function SWEP:OnRemove()
    

	for k , v in pairs(self.ragdollToNPC) do
		--print (k.timer)
		--print (k)
		--print (v)
		--if v then 
		-- hook.Add("Think", "RagdollToNPC", function()

			-- if (CurTime() - k.timer > 2) and k and v and self.Owner then
				local npc = ents.Create(tostring(v.npc))

				npc:SetModel(v.model)
				npc:SetKeyValue("citizentype",4) -- for dumb anime models
				npc:SetPos(k:GetPos())
				npc:Spawn()
				npc:NextThink(CurTime() + 0.1)
				npc:DropToFloor()
				

				if IsValid(npc) then
					
					npc:SetSequence(18)
					
				end
				
				self.ragdollToNPC[k] = nil
				k:Remove()
				hook.Remove("Think", "RagdollToNPC")
			-- end

		-- end)
	--end
		
	end

	for k , v in pairs(self.ragdollToPlayer) do

		--if (CurTime() - k.timer > 2) and k and v then

			
			local player = v.npc


			
			--player:SetModel(v.model)
			player:Spawn()
			player:SetPos(k:GetPos())
			player:Freeze(false)
			player:UnSpectate()
			local viewModel = player:GetViewModel()
			--if IsValid(viewModel) then
			player:DrawViewModel(true)
			player:DrawWorldModel(true)
			--end
			

			if IsValid(npc) then
				
				npc:SetSequence(18)
				
			end
			
			self.ragdollToPlayer[k] = nil
			k:Remove()
		-- end
		
	end
	
	hook.Remove("Think", "RagdollToNPC")
end