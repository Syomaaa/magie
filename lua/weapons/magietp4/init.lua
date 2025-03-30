AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local config = {}
config.dst = 1500

if not file.Exists("tp4_data", "DATA") then
    file.CreateDir("tp4_data/")
end

function SWEP:Initialize()
    self:SetHoldType("magic")
    self.playerLists = {}

    if SERVER then
        util.AddNetworkString("SendTP")
        util.AddNetworkString("TPSelectedPlayer")
        util.AddNetworkString("RemovePlayer")
    end
end

function SWEP:PrimaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay < CurTime() then 
        if not SERVER then return end

        local ply = self:GetOwner()
        local steamid = ply:SteamID64()

        if not file.Exists("tp4_data/" .. steamid .. ".txt", "DATA") then
            local playerdata = {}
            playerdata.target = {}
            file.Write("tp4_data/" .. steamid .. ".txt", util.TableToJSON(playerdata))
        end

        local trace = ply:GetEyeTrace()
        local dist = trace.StartPos:Distance(trace.HitPos)

        if dist < config.dst then 
            local ent = trace.Entity

            if ent:IsPlayer() and ent:Alive() then
                local filepath = "tp4_data/" .. steamid .. ".txt"
                if file.Exists(filepath, "DATA") then
                    local playerdata = util.JSONToTable(file.Read(filepath, "DATA"))
                    if not table.HasValue(playerdata.target, ent:SteamID64()) then
                        ply:ChatPrint("Joueur enregistré : " .. ent:Nick())
                        table.insert(playerdata.target, ent:SteamID64())
                        file.Write(filepath, util.TableToJSON(playerdata))
                        self.CooldownDelay = CurTime() + self.Cooldown
                        self.NextAction = CurTime() + self.ActionDelay
                    end
                end
            end
        end
    else
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown .. "s de cooldown !")
    end
    return true
end

function SWEP:GetPlayerList(ply)
    local steamid = ply:SteamID64()
    local filepath = "tp4_data/" .. steamid .. ".txt"
    local tarList = {}

    if file.Exists(filepath, "DATA") then
        local playerdata = util.JSONToTable(file.Read(filepath, "DATA"))
        for _, tarSteamID64 in ipairs(playerdata.target) do
            local tar = player.GetBySteamID64(tarSteamID64)
            table.insert(tarList, tar)
        end
    end

    return tarList
end

function SWEP:SecondaryAttack()
    if self.NextAction > CurTime() then return end
    if self.CooldownDelay2 < CurTime() then 
        if not SERVER then return end

        if SERVER then
            net.Start("SendTP")
            net.WriteTable(self:GetPlayerList(self.Owner))
            net.Send(self.Owner)
        end

        self.CooldownDelay2 = CurTime() + self.Cooldown2
        self.NextAction = CurTime() + self.ActionDelay
    else
        self.Owner:PrintMessage(HUD_PRINTCENTER, "Tu as " .. self.Cooldown2 .. "s de cooldown !")
    end
    return true
end

function SWEP:Think()
    if not SERVER then return end
    net.Receive("TPSelectedPlayer", function(len, ply)
        local target = net.ReadEntity()
        if IsValid(target) then
            ply:SetPos(target:GetPos() + Vector(0, 0, 150))
        end
    end)

    net.Receive("RemovePlayer", function(len, ply)
        local target = net.ReadEntity()
        local steamid = ply:SteamID64()
        local filepath = "tp4_data/" .. steamid .. ".txt"

        if file.Exists(filepath, "DATA") then
            local playerdata = util.JSONToTable(file.Read(filepath, "DATA"))
            table.RemoveByValue(playerdata.target, target:SteamID64())
            file.Write(filepath, util.TableToJSON(playerdata))
            ply:ChatPrint("Joueur supprimé : " .. target:Nick())
        end
    end)
end

function SWEP:Holster()
    return true
end
