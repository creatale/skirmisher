{Engine} = require './base/engine'
LogicStatsStartSystem = require './systems/logic_stats_start'
LogicStatsEndSystem = require './systems/logic_stats_end'
InputEventsSystem = require './systems/input_events'
MouseInputSystem = require './systems/mouse_input'
TouchInputSystem = require './systems/touch_input'
KeyInputSystem = require './systems/key_input'
GraphicsSystem = require './systems/graphics'
MediatorSystem = require './systems/mediator'
PickingSystem = require './systems/picking'

Input = require './components/input'
InputSettings = require './components/input_settings'
Sprite = require './components/sprite'
Position = require './components/position'

		
module.exports = class Game
	constructor: (container, user) ->
		stats = $('<div class="stats">')
		# Render frame statistics.
		renderStats = new Stats()
		$(renderStats.domElement).addClass 'render'
		stats.append renderStats.domElement
		# Logic frame statistics.
		logicStats = new Stats()
		$(logicStats.domElement).addClass 'logic'
		stats.append logicStats.domElement
		stage = new PIXI.Stage(0x332222)
		# Engine.
		@initialize container, stage, renderStats, logicStats
		container.append stats

	initialize: (container, stage, renderStats, logicStats) =>
		@engine = new Engine()

		graphics = null
		async.parallel [
			(done) ->
				graphics = new GraphicsSystem stage, container, renderStats, done
			], @engine.start

		@engine.addSystem new LogicStatsStartSystem logicStats
		@inputEvents = new InputEventsSystem()
		@engine.addSystem @inputEvents
		@engine.addSystem KeyInputSystem
		@engine.addSystem TouchInputSystem
		@engine.addSystem MouseInputSystem
		@engine.addSystem new PickingSystem(graphics.levelContainer, graphics.hudContainer)

		
		@engine.addSystem graphics
		@engine.addSystem new LogicStatsEndSystem logicStats

		@engine.addSystem MediatorSystem # always last!
		return

	dispose: =>
		@inputEvents.dispose()
