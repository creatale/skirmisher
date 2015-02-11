{System} = require '../base/ecs'
Input = require '../components/input'

#
# MouseInput
#
# translates raw input events to mouse input state
#
# emits nothing
#
# receives:
#	- input:mouse-button-changed
# 	- input:mouse-moved
# 	- input:mouse-clicked
#

module.exports = class MouseInputSystem extends System
	constructor: ->
		super
		@receives = ['input:mouse-button-changed', 'input:mouse-moved', 'input:mouse-clicked']
		return

	step: (deltaTime, state, receivers) =>
		clickEvents = receivers['input:mouse-clicked']()
		moveEvents = receivers['input:mouse-moved']()
		buttonEvents = receivers['input:mouse-button-changed']()
		
		x = null
		y = null
		down = null
		clicked = null
		
		if moveEvents.length isnt 0
			lastMoveEvent = moveEvents[moveEvents.length-1][0]
			x = lastMoveEvent.position.x
			y = lastMoveEvent.position.y

		clicked = clickEvents.length > 0

		for event in buttonEvents
			if event[0].type is 'mousedown'
				down = true
			else if event[0].type is 'mouseup'
				down = false

		components = state.queryComponents Input
		for component in components
			mouseState = component.mouseState

			mouseState.position.x = x if x?
			mouseState.position.y = y if y?
			mouseState.down = down if down?
			mouseState.clicked = clicked if clicked?
		return
