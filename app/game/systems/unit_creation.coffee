{System} = require '../base/ecs'
Unit = require '../components/unit'
Polygon = require '../components/polygon'
Position = require '../components/position'
hex = require '../lib/hex'
Tile = require '../components/tile'

module.exports = class UnitCreationSystem extends System

	constructor: ->
		@receives = ['!unit:add']

		return

	step: (deltaTime, state, receivers) ->
		for event in receivers['!unit:add']()
			@createUnit(state, event[0].coordinates)
		return

	createUnit: (state, coordinates) =>
		unit = state.createEntity()
		pos = hex.tileToSurfaceCoordinates coordinates.x, coordinates.y
		unit.addComponent(new Position(pos.x * Tile::DISPLAY_SIZE, pos.y * Tile::DISPLAY_SIZE))
		unit.addComponent(new Unit(coordinates))
		polygon = new Polygon([{x: -25, y: -25}, {x: -25, y: 25}, {x: 25, y: 25}, {x: 25, y: -25}])
		polygon.fillColor = 0x33DD00
		unit.addComponent polygon