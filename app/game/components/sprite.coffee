module.exports = class Sprite
	type: 'Sprite'

	constructor: (@texture, @width, @height, @offsetX = 0, @offsetY = 0) ->
		@object = null
		@layer = 'regular'
		return
		
	toJSON: =>
		return {
			texture: @texture,
			width: @width,
			height: @height,
			offsetX: @offsetX,
			offsetY: @offsetY,
			layer: @layer
		}
