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
		for eventName, listener of state.eventEmitter.listeners
			target = serialized.pendingEvents[eventName] = []
			for subscriber in listener
				target.push JSON.stringify subscriber.aggregatedEvents, entityReplacer
		return serialized
		
	restoreState: (target, serializedState) =>
		for entity of target.entities
			target.removeEntity entity
		
		for serializedEntity in serializedState.entities
			entity = new Entity serializedEntity.id
			target.addEntity entity
			for componentType, components of serializedEntity.components
				for serializedComponent of components
					data = JSON.parse serializedComponent
					# FIXME Needs a factory
					component = entity.addComponent componentType
					for key, value of data
						component[key] = value
						
		for eventName, listeners of serializedState.pendingEvents
			for serializedEvents, index in listeners
				target.eventEmitter[eventName][index].aggregatedEvents = JSON.parse serializedEvents
				
		return


entityReplacer = (key, value) ->
	if value instanceof Entity
		return 'entity:' + value.id
	return value

# entityReviver
