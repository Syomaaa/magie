include("shared.lua")

function SWEP:PrimaryAttack()
    return true
end

function SWEP:SecondaryAttack()
    return true
end

function SWEP:Initialize()
    self:SetHoldType("magic")
    if SERVER then
        util.AddNetworkString("SendTP")
        util.AddNetworkString("TPSelectedPlayer")
        util.AddNetworkString("RemovePlayer")
    end
end

net.Receive("SendTP", function(len, own)
    local playerList = net.ReadTable()

    local addedID = {}

    local SYSFrame = vgui.Create("DFrame")
    SYSFrame:SetSize(300, 350)
    SYSFrame:SetTitle("TP")
    SYSFrame:MakePopup()
    SYSFrame:ShowCloseButton(true)
    SYSFrame:Center()

    SYSFrame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
    end

    local list = vgui.Create("DListView", SYSFrame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("Nom du joueur")
    list:AddColumn("Entité du joueur"):SetVisible(false)

    list:Clear()

    for _, ply in ipairs(playerList) do
        if IsValid(ply) then
            local id = ply:SteamID64()

            if not addedID[id] then
                addedID[id] = true

                local line = list:AddLine(ply:Nick())

                line.OnMousePressed = function(self, mouseCode)
                    if mouseCode == MOUSE_LEFT then
                        self.PressedTime = SysTime()
                    end
                end

                line.OnMouseReleased = function(self, mouseCode)
                    if mouseCode == MOUSE_LEFT then
                        if SysTime() - self.PressedTime > 2 then
                            net.Start("RemovePlayer")
                            net.WriteEntity(ply)
                            net.SendToServer()
                            SYSFrame:Remove()
                        elseif  SysTime() - self.PressedTime < 2 then
                            net.Start("TPSelectedPlayer")
                            net.WriteEntity(ply)
                            net.SendToServer()
                            SYSFrame:Close()
                        end
                    end
                end
            end
        end
    end

    SYSFrame.Close = function()
        local startTime = SysTime()
        local endTime = SysTime() + 0.3
        local startAlpha = SYSFrame:GetAlpha()
        local endAlpha = 0
        local deltaTime = 0

        timer.Create("FadeOutTimer", 0.01, 0, function()
            deltaTime = SysTime() - startTime
            SYSFrame:SetAlpha(Lerp(deltaTime / (endTime - startTime), startAlpha, endAlpha))
            if deltaTime >= endTime - startTime then
                SYSFrame:Remove()
                timer.Remove("FadeOutTimer")
            end
        end)
    end
end)
