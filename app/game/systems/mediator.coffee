{System} = require '../base/ecs'
mediator = require '/mediator'

#
# Mediator System
#
# interfaces with global page state out of the game itself
#
# emits
# receives '!console:add-unit'
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
			state.emitEvent command[0], command[1]
		@userCommands = []

	userCommand: (command, params) =>
		@userCommands.push [command, params]
