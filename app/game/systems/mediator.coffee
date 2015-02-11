{System} = require '../base/ecs'
mediator = require '/mediator'

#
# Mediator System
#
# interfaces with global page state out of the game itself
# 
# receives '!mediator:game-over'
#

module.exports = class MediatorSystem extends System
	constructor: ->
		super
		@receives = ['!mediator:game-over']
		return

	step: (deltaTime, state, receivers) =>