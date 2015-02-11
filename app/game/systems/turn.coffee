{System} = require '../base/ecs'

# TurnSystem
#
#	It turns.
#
# emits:
# 	- 'turn:started'
#
# receives:
#	- '!turn:undo'
#	- '!turn:end'

module.exports = TurnSystem extends System

	constructor: ->
		@receives = ['!turn:undo', '!turn:end']
		return

	step: (deltaTime, state, receivers) ->

		return