{System} = require '../base/ecs'
Player = require '../components/player'
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
		for event in receivers['!mediator:game-over']()
			score = state.queryComponents(Player)[0].progress
			mediator.publish 'game-over', 'bla', score.toFixed(1)
