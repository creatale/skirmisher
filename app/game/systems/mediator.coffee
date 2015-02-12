{System} = require '../base/ecs'
mediator = require '/mediator'

#
# Mediator System
#
# interfaces with global page state out of the game itself
#
# emits
# receives
#

module.exports = class MediatorSystem extends System
	constructor: ->
		super
		@receives = []
		@userCommands = []
		window.command = @userCommand
		return

	step: (deltaTime, state, receivers) =>
		for command in @userCommands
			state.emitEvent '!unit:add', command

	userCommand: (command) =>
		@userCommands.push command