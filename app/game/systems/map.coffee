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
#		- map:tile-selected
#
# receives:

module.exports = class MapSystem extends System
	constructor: ->
		@receives = ['graphics:mouse-over-polygon', 'graphics:mouse-out-polygon', 'graphics:clicked-polygon']

		return

	step: (deltaTime, state, receivers) ->
		@createMap(state) unless state.queryEntities(Map)[0]?
		for event in receivers['graphics:mouse-over-polygon']()
			continue unless event[1].has Tile
			event[0].strokeWidth = 10
		for event in receivers['graphics:mouse-out-polygon']()
			continue unless event[1].has Tile
			event[0].strokeWidth = 0
		for event in receivers['graphics:clicked-polygon']()
			continue unless event[1].has Tile
			for entity in state.queryEntities [Tile]
				tile = entity.get(Tile)[0]
				if entity.id is event[1].id and not tile.selected
					polygon = entity.get(Polygon)[0]
					tile.selected = true
					polygon.fillColor = 0xFF00FF
					state.emitEvent 'map:tile-selected', tile, entity
				else if tile.selected
					polygon = entity.get(Polygon)[0]
					tile.selected = false
					polygon.fillColor = 0xFF0000

		

	createMap: (state) =>
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
				polygon.interactive = true
				tile.addComponent polygon
				pos = hex.tileToSurfaceCoordinates x, y

				tile.addComponent(new Position(pos.x * Tile::DISPLAY_SIZE, pos.y * Tile::DISPLAY_SIZE))
		return

hexCorner = (size, i) ->
		angle = 2 * Math.PI / 6 * (i + 0.5)
		x = size * (Math.cos angle)
		y = size * (Math.sin angle)
		return {x:x, y:y}
