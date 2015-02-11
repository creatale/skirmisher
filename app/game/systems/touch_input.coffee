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
#	- input:touch-changed
#	- input:touch-moved
#

module.exports = class TouchInputSystem extends System
	constructor: ->
		super
		@receives = ['input:touch-changed', 'input:touch-moved']
		return

	step: (deltaTime, state, receivers) =>
		changedEvents = receivers['input:touch-changed']()
		movedEvents = receivers['input:touch-moved']()

		inputs = state.queryComponents Input
		for input in inputs
			for id, state of input.touchStates
				if state.clicked
					delete input.touchStates[id]
		
		for event in changedEvents
			switch event[0].type
				when 'start'
					for touch in event[0].touches
						for input in inputs
							input.touchStates[touch.identifier] ?=
								position:
									x: touch.clientX
									y: touch.clientY
								ellipse:
									x: touch.radiusX
									y: touch.radiusY
									angle: touch.rotationAngle
								down: true
								clicked: false
								picked: null
								drag: null
				when 'end'
					for touch in event[0].touches
						for input in inputs
							inputTouch = input.touchStates[touch.identifier]
							inputTouch.clicked = true
				when 'cancel'
					for touch in event[0].touches
						for input in inputs
							delete input.touchStates[touch.identifier]
							
		for event in movedEvents
			for touch in event[0]
				for input in inputs
					inputTouch = input.touchStates[touch.identifier]
					inputTouch.position.x = touch.clientX
					inputTouch.position.y = touch.clientY
					inputTouch.ellipse.x = touch.radiusX
					inputTouch.ellipse.y = touch.radiusY
					inputTouch.ellipse.angle = touch.rotationAngle
		return
