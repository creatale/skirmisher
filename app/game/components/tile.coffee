module.exports = class Tile

  type: 'Tile'
  DISPLAY_SIZE: 100

  constructor: (@coordinates) ->
  	@selected = false
