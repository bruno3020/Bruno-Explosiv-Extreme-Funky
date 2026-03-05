-- CODE SHIT BY I-WIN

-- kade ui by daninnocent

--CREDIT TO 1F1D ON GAMEBANANA FOR MAKING THE KADEBAR SCRIPT
--CREDIT TO Tomek*Tomciok*Przybysz ON GAMEBANANA FOR FIXING THE KADEBAR SCRIPT

-- idk how to code ok leave me be :( -daninnocent

local a1 = 0.254829592;
local a2 = -0.284496736;
local a3 = 1.421413741;
local a4 = -1.453152027;
local a5 = 1.061405429;
local p = 0.3275911;
local curTotalNotesHit = 0
local counterUpdated = 0
local actualRatingHere = 0.00
local msDiffTimeLimit = 1200  -- how many ms after hitting a note should the ms rating disappear
local lastMsShowUp = 0
local msTextVisible = false
local isPixel = false
-- local turnvalue = 20

function onCreatePost()
    if getPropertyFromClass('PlayState', 'isPixelStage') then 
		isPixel = true
	end

    addLuaText('funnikade')
	addLuaText('oldScore')

    setObjectOrder('oldScore', 40)
    setObjectOrder('funnikade', 40)

    setObjectCamera('oldScore','hud')
	setObjectCamera('funnikade','hud')

	if getPropertyFromClass('ClientPrefs', 'downScroll') == false then
	setProperty('oldScore.y', 680)
	elseif getPropertyFromClass('ClientPrefs', 'downScroll') == true then
	setProperty('oldScore.y', 130)
    end


    setProperty('scoreTxt.visible', true)

    -- setProperty('timeBar.scale.x', 1.3);
    -- setProperty('timeBar.scale.y', 1.3);
    -- setProperty('timeBarBG.scale.x', 1.3);
    -- setProperty('timeBarBG.scale.y', 1.3);
    -- setProperty('timeTxt.scale.x', 1.3);
    -- setProperty('timeTxt.scale.y', 1.3);

    setProperty('grpNoteSplashes.visible', false)

end

function onCreate()
    -- the 540 is the x pos of the text; the 360 is the y pos of the text. Note that y pos is from the top.
    makeLuaText('msTxt', ' ', 0, 540, 360)
    setTextSize('msTxt', 17)
    setTextBorder('msTxt', 2, '000000')
    setTextFont('msTxt', 'pixel.otf')
    addLuaText('msTxt')

    makeLuaText('funnikade', songName .. ' - ' .. difficultyName .. ' | Psych Engine ' .. version,getProperty('healthBarBG.width'), 0 ,700)
    setTextSize('funnikade', 16)

    makeLuaText('oldScore', '', 630, 200)
	setTextSize('oldScore', 16)

    -- so positions won't be fucked up -Daninnocent

    end

function onUpdatePost(elapsed)
	-- start of "update", some variables weren't updated yet
    -- This updates the contents of the score text.
    -- the rating name is not drawn from the game source.
    -- debugPrint(curTotalNotesHit)

    -- DETERMING WHETHER TO HIDE THE MS DIFF

    if getPropertyFromClass('PlayState', 'isPixelStage') then 
		isPixel = true
	end

    local curSongPosRightNow = getSongPosition()
    if curSongPosRightNow - lastMsShowUp > msDiffTimeLimit and msTextVisible then
        removeLuaText('msTxt', false)
        setTextString('msTxt', '')
        addLuaText('msTxt')
        msTextVisible = false
    end

    -- UPDATING SCORETXT

    if ratingName == '?' then
        local beforeScoreTxt = ''
        setTextString('oldScore', beforeScoreTxt)
    else
        local ratingNameM = getProperty('ratingFC')

        if ratingNameM == 'SFC' then
            ratingNameM = 'MFC'
        end
        local ratingFull = math.max(actualRatingHere * 100, 0)
        local ratingFullAsStr = string.format("%.2f", ratingFull)

        local tempRatingNameVery = accuracyToRatingString(ratingFull)
        -- we can assert that ratingdec
        local finalScoreTxt = ' '..tempRatingNameVery
		setTextString('oldScore', finalScoreTxt)
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not isSustainNote then
        strumTime = getPropertyFromGroup('notes', id, 'strumTime')
        songPos = getPropertyFromClass('Conductor', 'songPosition')
        rOffset = getPropertyFromClass('ClientPrefs','ratingOffset')
        updateAccuracy(strumTime, songPos, rOffset)
    end
end



function updateAccuracy(strumTime, songPos, rOffset) -- HELPER FUNCTION
    local noteDiffSign = strumTime - songPos + rOffset
    local noteDiffAbs = math.abs(noteDiffSign)
    local totalNotesForNow = handleNoteDiff(noteDiffAbs)
    -- local rawJudgements = cancelExistingJudgements(noteDiffAbs)
    -- debugPrint(rawJudgements)
    -- local notesHitDiff = totalNotesForNow - rawJudgements
    -- addHits(noteHitDiff)
    showMsDiffOnScreen(noteDiffSign)
    curTotalNotesHit = curTotalNotesHit + totalNotesForNow
    counterUpdated = counterUpdated + 1
    -- curAccuracy = curTotalNotesHit / counterUpdated
    -- debugPrint(curTotalNotesHit)
    -- setHits(curTotalNotesHit)
    -- getProperty(totalNotesHit)
    
    -- debugPrint(curTotalNotesHit / counterUpdated)
    actualRatingHere = curTotalNotesHit / counterUpdated
    setProperty('ratingPercent', math.max(0, actualRatingHere))  -- we technically need this so the game accounts that for the high score
    -- setRatingPercent(actualRatingHere)
    
    -- debugPrint(tln)
    -- setProperty('totalNotesHit', curTotalNotesHit)
    -- setProperty('totalPlayed', counterUpdated)

    -- ratingStr = accuracyToRatingString(curAccuracy * 100)
    -- setProperty('ratingPercent', math.max(0, curAccuracy))
    -- setProperty('ratingName', ratingStr)
end

function showMsDiffOnScreen(diff)  -- remove everything in this function if you don't want ms timings

    doTweenAlpha('msTxtGONE', 'msTxt', 0, 0.5, 'circInOut')

    lastMsShowUp =  getPropertyFromClass('Conductor', 'songPosition')
    msTextVisible = true

    

    -- local msDiffStr = string.format("%.3f", diff)
    -- msDiffStr = msDiffStr + 'ms'
    -- debugPrint(msDiffStr)
 
end


function ratingTextColor(diff)
    local absDiff = math.abs(diff)
    
    if absDiff < 46.0 then
        return '00FFFF'
    elseif absDiff < 91.0 then
        return '008000'
    else
        return 'FF0000'
    end
end



function cancelExistingJudgements(diff) -- HELPER FUNCTION
    if diff < 46.0 then
        return 1.0
    elseif diff < 91.0 then
        return 0.75
    elseif diff < 136.0 then
        return 0.5
    else
        return 0.0
    end
end


function accuracyToRatingString(accuracy) -- HELPER FUNCTION
    -- Please don't cancel me for repeat if else statements blame python 3.10 for not releasing sooner
    if accuracy >= 99.9935 then
        return ''
    elseif accuracy >= 99.980 then
        return ''
    elseif accuracy >= 99.970 then
        return ''
    elseif accuracy >= 99.955 then
        return ''
    elseif accuracy >= 99.90 then
        return ''
    elseif accuracy >= 99.80 then
        return ''
    elseif accuracy >= 99.70 then
        return ''
    elseif accuracy >= 99 then
        return ''
    elseif accuracy >= 96.50 then
        return ''
    elseif accuracy >= 93 then
        return ''
    elseif accuracy >= 90 then
        return ''
    elseif accuracy >= 85 then
        return ''
    elseif accuracy >= 80 then
        return ''
    elseif accuracy >= 70 then
        return ''
    elseif accuracy >= 60 then
        return ''
    else
        return ''
    end
end

function handleNoteDiff(diff) -- HELPER FUNCTION
    local maxms = diff
    local ts = 1

    local max_points = 1.0;
    local miss_weight = -1.0; -- used to be -5.5; this should be a lot less harsh.
    local ridic = 5 * ts;
    local max_boo_weight = 166
    local ts_pow = 0.75;
    local zero = 65 * ts^ts_pow
    local power = 2.5;
    local dev = 22.7 * ts^ts_pow

    if (maxms <= ridic) then -- // anything below this (judge scaled) threshold is counted as full pts
        return max_points
    elseif (maxms <= zero) then -- // ma/pa region, exponential
        return max_points * erf((zero - maxms) / dev)
    elseif (maxms <= max_boo_weight) then -- // cb region, linear
        return (maxms - zero) * miss_weight / (max_boo_weight - zero)
    else
        return miss_weight
    end
end

function erf(x)  -- HELPER FUNCTION
    local sign = 1;
    if (x < 0) then
        sign = -1;
    end
    x = math.abs(x);
    local t = 1.0 / (1.0 + p * x);
    local y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-x * x);

    return sign * y;
end

function noteMissPress(direction)
    updateAccuracy(400, 0, 0)
end

function noteMiss(id, direction, noteType, isSustainNote)
    updateAccuracy(400, 0, 0)
end


