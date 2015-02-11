module.exports = class Position
	type: 'Position'

	constructor: (@x, @y, @zIndex = 0) ->
		@rotation = 0
		return
