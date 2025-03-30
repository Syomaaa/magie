

	EFFECT.Mat = Material('effects/yellowflare')

	function EFFECT:Init(d)
		timer.Simple(0.1, function() self:Remove() end)
		self.StartPos = d:GetStart()
		self.EndPos = d:GetOrigin()
		self.Ent = d:GetEntity()

		self.Dir = self.StartPos-self.EndPos
		self.Length = self.Dir:Length()
		self:SetRenderBoundsWS(self.StartPos,self.EndPos)
		self.Dir:Normalize()
		self.TracerTime = 0.01
		self.DieTime = 0.01
	end

	function EFFECT:Think()
		return true
	end

	function EFFECT:Render()
		local fDelta = (self.DieTime-UnPredictedCurTime())/self.TracerTime
		fDelta = 1-math.Clamp(fDelta,0,1)

		render.SetMaterial(self.Mat)

		local color = Color(255,255,255,30)

		render.DrawBeam(self.StartPos,self.EndPos,75,0.5,0.5,color)
	end

