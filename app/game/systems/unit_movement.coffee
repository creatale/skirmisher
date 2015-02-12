{System} = require '../base/ecs'
Map = require '../components/map'
Tile = require '../components/tile'
Position = require '../components/position'
Unit = require '../components/unit'

hex = require '../lib/hex'

# UnitMovementSystem
#
#	I got to move it, move it.
#
# emits:
#
# receives: map:tile-selected

module.exports = class UnitMovementSystem extends System
	constructor: ->
		@receives = ['map:tile-selected']

		return

	step: (deltaTime, state, receivers) ->
		for event in receivers['map:tile-selected']()
			tile = event[0]

			newUnit = null
			selectedUnit = null
			selectedUnitEntity = null

			for entity in state.queryEntities [Unit]
				unit = entity.get(Unit)[0]
				if tile.coordinates.x is unit.coordinates.x and tile.coordinates.y is unit.coordinates.y and not unit.selected
					newUnit = unit
				if unit.selected
					selectedUnit = unit
					selectedUnitEntity = entity
			
			if newUnit?
				selectedUnit?.selected = false
				newUnit.selected = true
			else if selectedUnit?
				console.log "move unit #{selectedUnit.coordinates.x}/#{selectedUnit.coordinates.y} to #{tile.coordinates.x}/#{tile.coordinates.y}"
				selectedUnit.coordinates.x = tile.coordinates.x
				selectedUnit.coordinates.y = tile.coordinates.y
				pos = hex.tileToSurfaceCoordinates selectedUnit.coordinates.x, selectedUnit.coordinates.y
				unitPosition = selectedUnitEntity.get(Position)[0]
				unitPosition.x = pos.x * Tile::DISPLAY_SIZE
				unitPosition.y = pos.y * Tile::DISPLAY_SIZE




