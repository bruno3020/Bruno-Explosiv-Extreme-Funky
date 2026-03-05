function onEvent(name, value1, value2)
	if name == 'dedandclose' then
		setPropertyFromClass('GameOverSubstate','deathSoundName','fnf_loss_sfx')
		setProperty('health', 0)
		setPropertyFromClass('ClientPrefs', 'pauseMusic', 'Tea Time')
		setPropertyFromClass('PauseSubState', 'pauseMusic', 'Tea Time')
	end
end