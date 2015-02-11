DeferredEventEmitter = require '../lib/DeferredEventEmitter'

class System
	constructor: ->
		@receives = []
		return
	
	step: (deltaTime, state, receivers) ->
		return
		
class Entity
	constructor: (@id) ->
		_.extend @, Backbone.Events
		@components = {}
		return
		
	addComponent: (component) =>
		switch typeof component
			when 'function' then return @addComponent new component()
			when 'object'
				@components[component.type] ?= []
				@components[component.type].push component
				@trigger 'component-added', component
				return component
			else
				throw new Error('It is wrung')
		
	removeComponent: (component) =>
		components = @components[component.type]
		index = components.indexOf(component)
		if index isnt -1
			components.splice index, 1
		if components.length is 0
			delete @components[component.type]
			@trigger 'all-components-removed', component.type
		@trigger 'component-removed', component
		return
		
	removeAllComponents: (componentType) =>
		if componentType instanceof Array
			for type in componentType
				@removeAllComponents type
		else	if @has componentType
			if typeof(componentType) is 'function'
				@removeAllComponents componentType::type
			else
				for component in @components[componentType]
					@trigger 'component-removed', component
				delete @components[componentType]
				@trigger 'all-components-removed', component.type
		return
		
	has: (componentType) =>
		unless componentType?
			throw new Error('component type is undefined')
		switch typeof componentType
			when 'function' then return @has componentType::type
			when 'object' then return @has componentType.type
			else
				return @components[componentType]?
			
	get: (componentType) =>
		unless componentType?
			throw new Error('component type is undefined')
		if @has componentType
			switch typeof componentType
				when 'function' then return @get componentType::type
				when 'object' then return @get componentType.type
				else
					return @components[componentType]
		else
			return []
		
class State
	constructor: ->
		@entities = {}
		@entitiesByComponent = {}
		@events = new Entity 'events'
		@currentEntityId = 0
		@eventEmitter = new DeferredEventEmitter()
		@tryCompactIdSpace = false

		return
		
	queryComponents: (componentType) ->
		components = []
		for entity in @entitiesByComponent[componentType::type] ? []
			for component in entity.get componentType
				components.push component
		return components
		
	queryEntities: (componentTypes = []) ->
		componentTypes = [componentTypes] unless componentTypes instanceof Array
		if componentTypes.length is 0
			return (@entities[key] for key in Object.keys(@entities))
		entities = []
		for entity in @entitiesByComponent[componentTypes[0]::type] ? []
			validEntity = true
			for componentType in componentTypes[1..]
				validEntity = validEntity and entity.has componentType
			if validEntity
				entities.push entity
		return entities
		
	scanForHighestId: =>
		highest = 0
		for id of @entities
			highest = Number(id) if Number(id) > highest
		return highest
		
	createEntity: =>
		if @tryCompactIdSpace
			@tryCompactIdSpace = false
			@currentEntityId = @scanForHighestId() + 1
		entity = new Entity @currentEntityId
		@currentEntityId++
		@addEntity entity
		
	addEntity: (entity) =>
		throw new Error('Entity already exists') if @entities[entity.id]?
		
		@entities[entity.id] = entity
		entity.on 'all-components-removed', (type) =>
			list = @entitiesByComponent[type]
			list.splice list.indexOf(entity), 1
		entity.on 'component-removed', (component) =>
			@eventEmitter.emit 'component-removed:' + component.type, component, entity
		entity.on 'component-added', (component) =>
			if entity.components[component.type].length is 1
				@entitiesByComponent[component.type] ?= []
				@entitiesByComponent[component.type].push entity
			@eventEmitter.emit 'component-added:' + component.type, component, entity
		return entity
		
	removeEntity: (entity) =>
		id = entity?.id ? entity
		entityToRemove = @entities[id]
		return unless entityToRemove?.components?
		for componentType of entityToRemove.components
			entityToRemove.removeAllComponents componentType
		delete @entities[id]
		@tryCompactIdSpace = true if id is @currentEntityId - 1
		
	emitEvent: =>
		@eventEmitter.emit arguments...
		return
		
	queryEntityById: (entityId) =>
		if @entities[entityId]?
			return @entities[entityId]
		else
			return null



module.exports =
	System: System
	Entity: Entity
	State: State
