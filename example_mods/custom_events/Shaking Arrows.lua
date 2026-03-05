local defaultNotePos = {};
local shake = 0;

function onSongStart()
    for i = 0,7 do 
        x = getPropertyFromGroup('strumLineNotes', i, 'x')
        y = getPropertyFromGroup('strumLineNotes', i, 'y')
        table.insert(defaultNotePos, {x,y})
    -- or, you can use this 'defaultNotePos[i] = { getPropertyFromGroup('strumLineNotes', i, 'x'), getPropertyFromGroup('strumLineNotes', i, 'y')}'

    end
end

function onEvent(name, value1, value2)
    if name == 'Shaking Arrows' then
        cameraFlash('camGame', 'FFFFFF', 1, true)
        cameraFlash('camHUD', 'FFFFFF', 1, true)
        shake = value1
    end
end

function onUpdate(elapsed)
    songPos = getPropertyFromClass('Conductor', 'songPosition');
     
    currentBeat = (songPos / 300) * (bpm / 160)

    for i = 0,7 do
        setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + getRandomInt(-shake, shake) + math.sin((currentBeat + i*0.25) * math.pi))
        setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + getRandomInt(-shake, shake) + math.sin((currentBeat + i*0.25) * math.pi))
    end      
end