{System, Entity} = require '../base/ecs'

# TurnSystem
#
#	It turns.
#
# emits:
# 	- 'turn:started'
#
# receives:
#	- '!turn:undo'
#	- '!turn:end'

module.exports = class TurnSystem extends System
	constructor: ->
		@receives = ['!turn:undo', '!turn:end']
		@states = []
		return

	step: (deltaTime, state, receivers) =>
		# What to do on several 'turn:end' in one tick? Currently collapses them into one.
		turnEnded = receivers['!turn:end']().length
		if turnEnded
			@states.push @serializeState(state)
		
		for event in receivers['!turn:undo']()
			@restoreState state, @states.pop()
			
		return
		
	serializeState: (state) =>
		serialized =
			entities: []
			pendingEvents: {}
		
		# Serialize entities
		for id, entity of state.entities
			serializedEntity =
				id: id
				components: {}
				
			for componentType of entity.components
				target = serializedEntity.components[componentType] = []
				for component in entity.components[componentType]
					# Must be implemented on component level from here on
					target.push JSON.stringify(component)
			serialized.entities.push serializedEntity
			
		# Serialize (pending) events
		for eventName, data of state.eventEmitter.listeners
			serialized.pendingEvents[eventName] = JSON.stringify data, entityReplacer
		return serialized
		
	restoreState: (target, serializedState) =>
		undefined


entityReplacer = (key, value) ->
	if value instanceof Entity
		return 'entity:' + value.id
	return value

# entityReviver
