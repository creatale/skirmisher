{System} = require '../base/ecs'
Input = require '../components/input'
MouseArea = require '../components/mouse_area'
Position = require '../components/position'
cons = require '../lib/graphics_constants'

module.exports = class PickingSystem extends System
	constructor: (@levelContainer, @hudContainer) ->
	
	step: (deltaTime, state, receivers) =>
		mouseAreaEntities = state.queryEntities [MouseArea, Position]
		entities = state.queryEntities [Input]
		for entity in entities
			inputs = entity.get Input
			for input in inputs
				@pickForState input.mouseState, mouseAreaEntities
				for id, touchState of input.touchStates
					@pickForState touchState, mouseAreaEntities
		return
		
	pickForState: (inputState, mouseAreaEntities) =>
		x = (inputState.position.x - @hudContainer.position.x) / @levelContainer.scale.x / cons.WORLD_TO_ASSET_SCALE
		y = (inputState.position.y - @hudContainer.position.y) / @hudContainer.scale.y / cons.WORLD_TO_ASSET_SCALE
		wx = (inputState.position.x - @levelContainer.position.x) / @levelContainer.scale.x / cons.WORLD_TO_ASSET_SCALE
		wy = (inputState.position.y - @levelContainer.position.y) / @levelContainer.scale.y / cons.WORLD_TO_ASSET_SCALE
		rx = inputState.ellipse.x / @levelContainer.scale.x / cons.WORLD_TO_ASSET_SCALE
		ry = inputState.ellipse.y / @levelContainer.scale.y / cons.WORLD_TO_ASSET_SCALE
		picked = @pick(mouseAreaEntities, x, y, rx, ry)
		if picked?.tag
			inputState.picked = picked.entity.id + ':' + picked.tag
		else if picked?.entity
			inputState.picked = picked?.entity.id
		else
			inputState.picked = null

		inputState.worldPosition =
			x: wx
			y: wy
		return
		
	pick: (entities, x, y, rx, ry) =>
		pickedLowestZ = null
		pickedZIndex = null
		for entity in entities
			pick = @pickZIndex entity, x, y, rx, ry
			if pick? and
					((not pickedZIndex?) or (pickedZIndex? and pickedZIndex < pick.zIndex))
				pickedLowestZ = pick
				pickedZIndex = pick.zIndex
		return pickedLowestZ

	pickZIndex: (entity, x, y, rx, ry) =>
		position = entity.get(Position)[0]
		mouseAreas = entity.get MouseArea
		for mouseArea in mouseAreas
			left = position.x + mouseArea.offsetX - mouseArea.width / 2
			top = position.y + mouseArea.offsetY - mouseArea.height / 2
			right = left + mouseArea.width
			bottom = top + mouseArea.height

			touchLeft = x - rx
			touchRight = x + rx
			touchTop = y - ry
			touchBottom = y + ry
			if not (touchLeft > right or touchRight < left or touchTop > bottom or touchBottom < top)
				return {zIndex: position.zIndex, tag: mouseArea.tag, entity: entity}
		return null
