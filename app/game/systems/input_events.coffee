{System} = require '../base/ecs'
InputSettings = require '../components/input_settings'

# InputEventsSystem
#
# Injects DOM events into the engine event system.
# (stores them in a queue and releases them on step)
#
# emits:
# 	- 'input:key-changed', {type: 'keydown|keyup|keypress', originalEvent} : originalEvent has 'keyCode'
#		- 'input:mouse-moved', {position: {x,y}}
#		- 'input:mouse-button-changed', {type: 'mousedown|mouseup'}
#		- 'input:mouse-clicked'
#

module.exports = class InputEventsSystem extends System
	constructor: (@keyElement = document, @mouseElement = document) ->
		super
		@localEventQueue = []

		@mouseElement.addEventListener 'mousemove', @mouseMove
		@mouseElement.addEventListener 'mousedown', @mouseDown
		@mouseElement.addEventListener 'mouseup', @mouseUp
		@mouseElement.addEventListener 'click', @click

		@mouseElement.addEventListener 'touchstart', @touchStart
		@mouseElement.addEventListener 'touchend', @touchEnd
		@mouseElement.addEventListener 'touchmove', @touchMove
		@mouseElement.addEventListener 'touchcancel', @touchCancel

		@keyElement.addEventListener 'keydown', @keyDown, false
		@keyElement.addEventListener 'keyup', @keyUp, false
		@keyElement.addEventListener 'keypress', @keyPress, false		
		return
	
	dispose: =>
		@mouseElement.removeEventListener 'mousemove', @mouseMove
		@mouseElement.removeEventListener 'mousedown', @mouseDown
		@mouseElement.removeEventListener 'mouseup', @mouseUp
		@mouseElement.removeEventListener 'click', @click

		@mouseElement.removeEventListener 'touchstart', @touchStart
		@mouseElement.removeEventListener 'touchend', @touchEnd
		@mouseElement.removeEventListener 'touchmove', @touchMove
		@mouseElement.removeEventListener 'touchcancel', @touchCancel
		
	step: (deltaTime, state) =>
		@settings = state.queryComponents(InputSettings)[0]
		@emitAllEvents state
		@localEventQueue = []
		return
		
	emitAllEvents: (state) =>
		for event in @localEventQueue
			state.emitEvent event...
		return

	mouseMove: (event) =>
		@localEventQueue.push ['input:mouse-moved', {position: {x: event.clientX, y: event.clientY}}]
		return

	mouseDown: =>
		@localEventQueue.push ['input:mouse-button-changed', {type: 'mousedown'}]
		return
		
	mouseUp: =>
		@localEventQueue.push ['input:mouse-button-changed', {type: 'mouseup'}]
		return

	click: =>
		@localEventQueue.push ['input:mouse-clicked']
		return

	touchStart: (event) =>
		@localEventQueue.push ['input:touch-changed', {type: 'start', touches: event.changedTouches}]
		event.preventDefault()
		return

	touchEnd: (event) =>
		@localEventQueue.push ['input:touch-changed', {type: 'end', touches: event.changedTouches}]
		event.preventDefault()
		return
		
	touchMove: (event) =>
		@localEventQueue.push ['input:touch-moved', event.changedTouches]
		event.preventDefault()
		return

	touchCancel: (event) =>
		@localEventQueue.push ['input:touch-changed', {type: 'cancel', touches: event.changedTouches}]
		event.preventDefault()
		return

	keyDown: (event) =>
		return unless @settings?.keyBindings[event.keyCode]?
		@localEventQueue.push ['input:key-changed', {type: 'keydown', originalEvent: event}]
		event.preventDefault()
		return

	keyUp: (event) =>
		return unless @settings?.keyBindings[event.keyCode]?
		@localEventQueue.push ['input:key-changed', {type: 'keyup', originalEvent: event}]
		event.preventDefault()
		return

	keyPress: (event) =>
		return unless @settings?.keyBindings[event.keyCode]?
		@localEventQueue.push ['input:key-changed', {type: 'keypress', originalEvent: event}]
		event.preventDefault()
		return
