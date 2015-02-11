{Engine} = require './base/engine'
LogicStatsStartSystem = require './systems/logic_stats_start'
LogicStatsEndSystem = require './systems/logic_stats_end'
InputEventsSystem = require './systems/input_events'
MouseInputSystem = require './systems/mouse_input'
TouchInputSystem = require './systems/touch_input'
KeyInputSystem = require './systems/key_input'
GraphicsSystem = require './systems/graphics'
MediatorSystem = require './systems/mediator'
PhysicsSystem = require './systems/physics'
PlayerSystem = require './systems/player'
CreepSystem = require './systems/creep'
LevelSystem = require './systems/level'
WeaponsSystem = require './systems/weapons'
InventorySystem = require './systems/inventory'
PickingSystem = require './systems/picking'
CleansingSystem = require './systems/cleansing'

Input = require './components/input'
InputSettings = require './components/input_settings'
Sprite = require './components/sprite'
Position = require './components/position'
PhysicsBody = require './components/physics_body'
Player = require './components/player'
Creep = require './components/creep'
Ground = require './components/ground'
Weapon = require './components/weapon'
Inventory = require './components/inventory'
Animation = require './components/animation'


		
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

		physicsSystem = new PhysicsSystem()
		graphics = null
		level = null
		async.parallel [
			(done) ->
				graphics = new GraphicsSystem stage, container, renderStats, physicsSystem.engine, done
			,
			(done) =>
				level = new LevelSystem('level.json', done)
			], @engine.start

		@engine.addSystem new LogicStatsStartSystem logicStats
		@engine.addSystem level
		@inputEvents = new InputEventsSystem()
		@engine.addSystem @inputEvents
		@engine.addSystem KeyInputSystem
		@engine.addSystem TouchInputSystem
		@engine.addSystem MouseInputSystem
		@engine.addSystem new PickingSystem(graphics.levelContainer, graphics.hudContainer)
		@engine.addSystem physicsSystem
		@engine.addSystem CreepSystem
		@engine.addSystem PlayerSystem
		weaponSystem = new WeaponsSystem()
		@engine.addSystem InventorySystem
		@engine.addSystem weaponSystem
		@engine.addSystem CleansingSystem

		
		@engine.addSystem graphics
		@engine.addSystem new LogicStatsEndSystem logicStats

		@engine.addSystem MediatorSystem # always last!
		
		playerEntity = @engine.createEntity()
		playerEntity.addComponent Input
		playerEntity.addComponent InputSettings

		playerEntity.addComponent new Player()
		playerEntity.addComponent new Animation('idle')
		playerEntity.addComponent new Position(0, 0)
		physicsBody = new PhysicsBody(1.45, 2.9)
		physicsBody.bodyType = 'dynamic'
		physicsBody.inertia = Infinity
		physicsBody.chamfer =
			radius: 0.4
		physicsBody.collisionFilter =
			group: 0
			category: 0b1000
			mask: 0xFFFFFFFF
		physicsBody.friction = 0
		playerEntity.addComponent(physicsBody)
		playerEntity.addComponent new Sprite('player', 1.5, 3)
		inventory = new Inventory()
		for weapon in ['bogenbajonett', 'feuerball', 'turret', 'instantwater', 'ggj', 'mindcontrol', 'railgun',
									 'weathermachine', 'lawnchair', 'prankgun', 'stone', 'tarnkappe']
			inventory.contents[weapon] = weaponSystem.weaponFactory @engine.state, weapon
		playerEntity.addComponent inventory

		return

	dispose: =>
		@inputEvents.dispose()
