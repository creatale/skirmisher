{System} = require '../base/ecs'
Map = require '../components/map'
Tile = require '../components/tile'
Position = require '../components/position'
hex = require '../lib/hex'

# MapSystem
#
#	Creates a map comprised entirely of Hexagons
#	The one chosen coordinate system: odd-r
#
# emits:
#
# receives:

module.exports = class MapSystem extends System
	constructor: ->
		@receives = []

		return

	step: (deltaTime, state, receivers) ->
		if state.queryEntities(Map)[0]?
			return
		else
			map = state.createEntity()
			map.addComponent Map
			for x in [1..Map::WIDTH]
				for y in [1..Map::HEIGHT]
					console.log 'positions', x, y
					tile = state.createEntity()
					tile.addComponent(new Tile {x: x, y: y})
					pos = hex.tileToSurfaceCoordinates x, y
					tile.addComponent(new Position(pos.x, pos.y))
		return

