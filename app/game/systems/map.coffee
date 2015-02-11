{System} = require '../base/ecs'
Map = require '../components/map'
Tile = require '../components/tile'
Position = require '../components/position'
Polygon = require '../components/polygon'

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
					tile = state.createEntity()
					tile.addComponent(new Tile {x: x, y: y})
					polygon = new Polygon()
					for i in [0..5]
						corner = hexCorner Tile::DISPLAY_SIZE/2, i
						polygon.points.push corner
					tile.addComponent polygon
					pos = hex.tileToSurfaceCoordinates x, y

					tile.addComponent(new Position(pos.x * Tile::DISPLAY_SIZE, pos.y * Tile::DISPLAY_SIZE))
		return

hexCorner = (size, i) ->
		angle = 2 * Math.PI / 6 * (i + 0.5)
		x = size * (Math.cos angle)
		y = size * (Math.sin angle)
		return {x:x, y:y}
