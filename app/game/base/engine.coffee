{State, System} = require './ecs'

class Timer
	now = performance?.now.bind(performance) ? Date.now.bind(Date)

	constructor: (@interval, @function) ->
		@baseline = undefined
		#@stats = new Array(30)
		#@statsIndex = 0

	run: =>
		@baseline ?= now()
		@function()
		end = now()
		@baseline += @interval
		nextTick = @interval - (end - @baseline)
		if nextTick < -@interval
			console.log 'Lagging behind, giving up', nextTick
			@baseline = end
		if nextTick < 0
			nextTick = 0
		#@stats[@statsIndex++] = nextTick / @interval
		#if @statsIndex >= @stats.length
		#	console.log Math.min 1, @stats.reduce((a, b) -> a+b) / @stats.length
		#	@statsIndex = 0
		if nextTick > 1
			@timer = setTimeout @run, nextTick | 0
		else if setImmediate?
			@timer = setImmediate @run
		else
			@run()

	stop: =>
		clearTimeout @timer


class Engine
	constructor: () ->
		@state = new State()
		@systems = []
		@timer = null
		@deltaTime = 1000 / 60
		return

	step: (deltaTime) =>
		for system in @systems
			system.step deltaTime, @state, system._receivers
		return

	createEntity: =>
		return @state.createEntity()

	addSystem: (system) =>
		if typeof(system) is 'function'
			return @addSystem new system()
		else
			@systems.push system
			if system.receives?
				system._receivers = {}
				for receiving in system.receives
					receive = @state.eventEmitter.on receiving
					system._receivers[receiving] = receive
			return system

	start: (fps = 60) =>
		if not @timer?
			@deltaTime = 1000 / fps
			@timer = new Timer @deltaTime, @tick
			@timer.run()
		return

	stop: =>
		@timer?.stop()
		@timer = null
		return

	tick: =>
		@step @deltaTime / 1000
		return


module.exports.Timer = Timer
module.exports.Engine = Engine
