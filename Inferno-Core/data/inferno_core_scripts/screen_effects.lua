local function TimeIncrement(useSpeed) 
	if useSpeed then
		return Hyperspace.FPS.SpeedFactor / 16
	elseif Hyperspace.FPS.NumFrames ~= 0 then 
		return 1 / Hyperspace.FPS.NumFrames
	else
		return 0
	end
end

--[[
////////////////////
SCREEN TRANSFORMATIONS
////////////////////
]]--

--FADERS
do 
	local ScreenFader = { 
		active = false,
		timer = 0,
		fadeIn = 1,
		hold = 1,
		fadeOut = 1,

		r = 1,
		g = 1,
		b = 1,
		a = 0,

		Render = function(self)
			if self.active then
				self.timer = self.timer + TimeIncrement(true)
				if self.timer < self.fadeIn then
					self.a = self.timer / self.fadeIn
				elseif self.timer < self.fadeIn + self.hold then
					self.a = 1
				elseif self.timer < self.fadeIn + self.hold + self.fadeOut then
					self.a = 1 - ((self.timer - self.fadeIn - self.hold) / self.fadeOut)
				else
					self.a = 0
					self.active = false
					self.timer = 0
				end
				Graphics.CSurface.GL_DrawRect(0, 0, 9999, 9999, Graphics.GL_Color(self.r, self.g, self.b, self.a)) --This will draw a rectangle from the point (0,0) to the point (9999,9999), which will cover the whole screen. It isn't important here, but one thing to note is that FTL's y coordinates increase as you go DOWNWARDS. (0,0) corresponds to the top left corner of the screen.
			end
		end,

		Start = function(self,table)
			self.fadeIn = table.fadeIn or 1 
      self.hold = table.hold or 1
      self.fadeOut = table.fadeOut or 1
			self.r = table.r or 1
			self.g = table.g or 1
			self.b = table.b or 1

			self.active = true
			self.timer = 0
		end, 
	}
	script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, function() end, function() ScreenFader:Render() end) 
	mods.inferno.ScreenFade = function(table)
		return ScreenFader:Start(table) 
	end
end
--SCREENSHAKE
do
	local shakeTimer = 0
	local shakeDuration = 0
	script.on_render_event(Defines.RenderEvents.GUI_CONTAINER, 
	function()
		if shakeTimer < shakeDuration then
			Graphics.CSurface.GL_PushMatrix() 
			local randomX = Hyperspace.random32() / 2147483647 * 10 * shakeTimer 
			local randomY = Hyperspace.random32() / 2147483647 * 10
			Graphics.CSurface.GL_Translate(randomX, randomY)
		end
	end, 
	function()
		if shakeTimer < shakeDuration then
			Graphics.CSurface.GL_PopMatrix() 
			shakeTimer = shakeTimer + TimeIncrement(true)
		end
	end)
	mods.inferno.ScreenShake = function(seconds)
		shakeTimer = 0
		shakeDuration = seconds
	end
end