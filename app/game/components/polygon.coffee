module.exports = class Polygon

  type: 'Polygon'

  constructor: (@points = []) ->
  	@dirty = false
  	@fillColor = 0xFF0000
  	@strokeColor = 0xFFFF00
  	@strokeWidth = 0
