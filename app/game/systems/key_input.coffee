{System} = require '../base/ecs'
Input = require '../components/input'
InputSettings = require '../components/input_settings'

# ECMAScript 6 proposal, add polyfill
Math.sign ?= (x) ->
	if x > 0
		return 1
	else if x < 0
		return -1
	else
		return 0

#
# KeyInput
#
# translates raw input events to input state
#
# emits nothing
# 
# receives:
#		- input:key-changed
#

module.exports = class KeyInputSystem extends System
	constructor: ->
		super
		@receives = ['input:key-changed']
		return

	step: (deltaTime, state, receivers) =>
		events = receivers['input:key-changed']()
		
		components = state.queryComponents Input
		settings = state.queryComponents(InputSettings)[0]

		for component in components
			@handleEvents component, events, settings
			component.axis.x = @keyToAxis component.keyState.right, component.keyState.left, deltaTime, component.axis.x
			component.axis.y = @keyToAxis component.keyState.up, component.keyState.down, deltaTime, component.axis.y
		return
	
	# Simplified version without acceleration
	keyToAxis: (upKey, downKey, step, axis) =>
		if upKey
			return 1
		else if downKey
			return -1
		else
			return 0
			
	handleEvents: (component, events, settings) =>
		for event in events
			event = event[0]
			if event.type is 'keydown'
				component.keyState[settings.keyBindings[event.originalEvent.keyCode]] = true
			if event.type is 'keyup'
				component.keyState[settings.keyBindings[event.originalEvent.keyCode]] = false
		return		
