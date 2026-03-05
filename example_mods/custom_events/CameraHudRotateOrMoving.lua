local defaultNotePos = {}
local spin = 0 -- How much it moves before going the other direction
local second = 1000 -- How long it will take.
 
function onSongStart()
    for i = 0, 7 do
        defaultNotePos[i] = {
            getPropertyFromGroup('strumLineNotes', i, 'x'),
            getPropertyFromGroup('strumLineNotes', i, 'y')
        }
        -- or, you can do this 'x = getPropertyFromGroup('strumLineNotes', i, 'x'); y = getPropertyFromGroup('strumLineNotes', i, 'y'); table.insert(defaultNotePos, {x,y});'
    end
end

function onEvent(name, value1, value2)
    if name == 'CameraHudRotateOrMoving' then
        cameraFlash('camGame', 'FFFFFF', 1, true)
        cameraFlash('camHUD', 'FFFFFF', 1, true)
        spin = value1
        second = 1000*value2
    end
end


function onUpdate(elapsed)

    position = getPropertyFromClass('Conductor', 'songPosition')

    songPosTime = position / second

    setProperty("camHUD.angle", spin * math.sin(songPosTime))
    
end