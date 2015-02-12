{System, Entity} = require '../base/ecs'
Map = require '../components/map'
Sprite = require '../components/sprite'
Tile = require '../components/tile'
Polygon = require '../components/polygon'

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
#	- '!console:add-unit'

module.exports = class TurnSystem extends System
	constructor: ->
		@once = false
		@receives = ['!turn:undo', '!turn:end', '!console:add-unit']
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
			if /^component-added:/.test eventName
				continue
			target = serialized.pendingEvents[eventName] = []
			
			for subscriber in listener
				serializedEvent = subscriber.aggregatedEvents.map serializeEvent
				target.push JSON.stringify(serializedEvent)
		return serialized
		
	restoreState: (target, serializedState) =>
		for entity of target.entities
			target.removeEntity entity
		for eventName, listener of target.eventEmitter.listeners when /^component-added:/.test eventName
			for subscriber in listener
				subscriber.aggregatedEvents = []
		
		for serializedEntity in serializedState.entities
			entity = new Entity serializedEntity.id
			target.addEntity entity
			for componentType, components of serializedEntity.components
				for serializedComponent in components
					data = JSON.parse serializedComponent
					entity.addComponent @restoreComponent(componentType, data)
						
		for eventName, listeners of serializedState.pendingEvents
			for serializedEvents, index in listeners
				list = JSON.parse(serializedEvents).map(restoreEvent)
				targetListener = target.eventEmitter.listeners[eventName][index]
				if /^component-removed:/.test eventName
					targetListener.aggregatedEvents.push list...
				else
					targetListener.aggregatedEvents = list
				
		return
	
	restoreComponent: (type, serializedData) ->
		# Factory portion of deserialization. We only need to know all components which either:
		#  a) have prototype properties beyond type (e.g. constants) or
		#  b) have method(s).
		component = switch type
			when 'Map' then new Map()
			when 'Sprite' then new Sprite()
			when 'Tile' then new Tile()
			when 'Polygon' then new Polygon()
			else Object.create {type}

		for key, value of serializedData
			component[key] = value
		return component


	restoreEvent = (state, serializedData) ->
		result = new Array(serializedData.length)
		entity = null
		
		for thing, index in serializedData
			if /^entity:/.test thing
				id = thing[7..]
				entity = result[index] = state.queryEntityById id
		
		for thing, index in serializedData when not result[index]?
			if /^component:/.test thing
				[type, index] = thing[10..].split(':')
				result[index] = entity.get(type)[index]
			else
				result[index] = thing
				
		return result
		
		
	serializeEvent = (eventArguments) ->
		result = new Array(eventArguments.length)
		for thing, index in eventArguments
			if thing instanceof Entity
				entity = thing
				result[index] = 'entity:' + thing.id
		
		for thing, index in eventArguments when not result[index]?
			for componentType, list of entity?.components ? []
				idx = list.indexOf(thing)
				if idx >= 0
					result[index] = 'component:' + componentType + ':' + idx
					
			result[index] ?= thing
	
		return result
