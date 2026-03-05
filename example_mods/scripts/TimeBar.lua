function onCreatePost()
  addLuaText("songLength");
  setProperty('timeTxt.visible', false)
  setProperty('timeBar.visible', false) -- original timebar thingies

  
    -- Time bar fill 
  makeLuaSprite('TimeBarFill', '', 5, 678)
    makeGraphic('TimeBarFill', 302, 20, '00FF00')
	setGraphicSize('TimeBarFill', 0, 20)
    setObjectCamera('TimeBarFill', 'hud')
    addLuaSprite('TimeBarFill')
	setObjectOrder("timeBarFill", 99)   
	setProperty('TimeBarFill.visible', false) -- invisible until after song starts
	-- Time bar
  makeLuaSprite('TimeBarBG', 'timeBar', -20, 670)
	setProperty("TimeBarBG.scale.x", 0.9)
	setProperty("TimeBarBG.scale.y", 0.9)
    setObjectCamera('TimeBarBG', 'hud')
    addLuaSprite('TimeBarBG')
	setObjectOrder("timeBarBG", 100)
	setProperty('TimeBarBG.alpha', 0)
	

end

function onCreate()
	makeLuaText('songLength', '00:00 - 00:00', 0, 80, 671)
	  setTextAlignment('songLength', 'left')
	  setObjectCamera('songLength', 'hud')
	  setTextFont('songLength', 'vcr.ttf')
	  setTextSize('songLength', 26)
	  setProperty('songLength.visible', false) 


end

function onSongStart()
    setProperty('TimeBarFill.visible', true)
	setProperty('songLength.visible', true) 
	doTweenAlpha('bgFade', 'TimeBarBG', 1, 1, 'circOut')
end

function onUpdatePost()
	local percent_p1 = (getProperty("healthBar.percent") / 100)
	local percent_p2 = 1 - percent_p1

	local fillWidth = (getSongPosition() / songLength) * 302
	setGraphicSize('TimeBarFill', fillWidth+0.001, 20) -- +0.001 for weird bug at width=0 filling the whole bar
	
	setProperty("healthbar_p1" .. ".scale.x", percent_p2 * 2)
	setProperty("healthbar_p2" .. ".scale.x", (percent_p1 * 2) + (percent_p1 < 1 and 0.01 or 0))
	if mouseClicked('left') and mouseOverLapsSprite('teehee', 'hud') then
		endSong()
	end
end

function onStepHit()
	setTextString('songLength', milliToHuman(math.floor(getSongPosition() - noteOffset)).. ' - ' .. milliToHuman(math.floor(songLength)) .. '\n')
end

function posOverlaps(
    x1, y1, w1, h1, --r1,
    x2, y2, w2, h2 --r2
)
    return (
        x1 + w1 >= x2 and x1 < x2 + w2 and
        y1 + h1 >= y2 and y1 < y2 + h2
    )
end

function mouseOverLapsSprite(spr, cam)
    local mouseX, mouseY = getMouseX(cam or "other"), getMouseY(cam or "other")
    
    local x, y, w, h = getProperty(spr .. ".x"), getProperty(spr .. ".y"), getProperty(spr .. ".width"), getProperty(spr .. ".height")
    
    return posOverlaps(
        mouseX, mouseY, 1, 1,
        x, y, w, h
    )
end

function milliToHuman(milliseconds) -- https://forums.mudlet.org/viewtopic.php?t=3258
	local totalseconds = math.floor(milliseconds / 1000)
	local seconds = totalseconds % 60
	local minutes = math.floor(totalseconds / 60)
	minutes = minutes % 60
	return string.format("%02d:%02d", minutes, seconds)  
end