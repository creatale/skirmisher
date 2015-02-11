class InputSettings
	type: 'InputSettings'

	constructor: ->
		@keyBindings =
			69: 'inventory'
			32: 'space'
			37: 'left'
			38: 'up'
			39: 'right'
			40: 'down'
			65: 'left' # A
			68: 'right' # D
			83: 'down' # S
			87: 'up' # W
		return

module.exports = InputSettings
