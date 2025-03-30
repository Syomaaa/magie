EFFECT.LaserMat = Material("ultralaser_sprite/laser")
EFFECT.EndSprMat = Material("ultralaser_sprite/glow")
EFFECT.Alpha = 150
EFFECT.Width = 35

function EFFECT:Init(d)
	self.StartPos = d:GetStart()
	self.EndPos = d:GetOrigin()
	self.Ent = d:GetEntity()

	self.Dir = self.StartPos-self.EndPos
	self.Length = self.Dir:Length()
	self:SetRenderBoundsWS(self.StartPos,self.EndPos)
	self.Dir:Normalize()
	if not IsValid(self.Weapon) then return false end
end

function EFFECT:Think()
	if not self.Alpha then return false end
	if IsValid(self.Weapon) then 
		self.StartPos = self:GetTracerShootPos(self.Position,self.Weapon,self.Attachment)
	end
	self.Alpha = self.Alpha - FrameTime() * 1000
	if self.Alpha < 0 then return false end
	return true
end

function EFFECT:Render()
	if self.Alpha < 1 then return end
	local alpha = self.Alpha + ((self.Alpha/2) * math.sin(CurTime()*((182-self.Alpha)*0.08))) 
	local col = Color(182,182,182)
	render.SetMaterial(self.LaserMat)
	render.DrawBeam(self.StartPos,self.EndPos,self.Width*(self.Alpha/80),CurTime()*15 + (self.Length*0.01),CurTime()*15,Color(182,182,182,alpha))
	render.SetMaterial(self.EndSprMat)
	render.DrawSprite(self.StartPos, self.Width*8, self.Width*8,Color(col.r,col.g,col.b,200))
	render.DrawSprite(self.EndPos, self.Width*8, self.Width*8,Color(col.r,col.g,col.b,20))
end
