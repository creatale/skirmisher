{System} = require '../base/ecs'
Sprite = require '../components/sprite'
Position = require '../components/position'
GraphicsConstants = require '../lib/graphics_constants'
PhysicsDebugDraw = require '../lib/PhysicsDebugDraw'
Player = require '../components/player'


DEBUG = false

# Files to load from /images/$res/; either a value of ASSETS below or a sprite sheet.
RESOURCES = [
	'Hintergrund.jpg'
	'Level-Area_large.png'
	'level1.json'
	'level2.json'
	'level3.json'
	'prince.json'
	'weapons.json'
	'player_laufen1.json'
	'player_laufen2.json'
	'player_laufen_mit_item1.json'
	'player_laufen_mit_item2.json'
	'player.json'
	'creeps.json'
	'Die_perfekte_Welle_1.png'
	'Die_perfekte_Welle_2.png'
	'Die_perfekte_Welle_3.png'
	'feuer.json'
	'alien_walk.json'
	'alien_dying.json'
	'alien_burning.json'
	'alien_suicide.json'
	'explosion.json'
	'alien_dance.json'
	'gewitter.json'
]

# Maps `Sprite.texture` string to files; arrays define an animation
ASSETS =
	background: 'Level-Area_large.png'
	# prince: [
		# 'Prinz_Frame1.png'
		# 'Prinz_Frame2.png'
		# 'Prinz_Frame3.png'
		# 'Prinz_Frame4.png'
	# ]
	'prince-dying': 'platform.png'
	platform: 'platform.png'
	traeger: 'Traeger_X.png'
	traegerTex: 'Traeger_X_tex.png'
	traegerEcke: 'Traeger_Ecke.png'
	traegerEckeTex: 'Traeger_Ecke_tex.png'
	bodenGrau: 'Boden_grau.png'
	bodenGrauTex: 'Boden_grau_tex.png'
	bodenKlinik: 'Boden_Klinik.png'
	bodenKlinikTex: 'Boden_Klinik_tex.png'
	tisch: 'Tisch.png'
	tafel: 'Tafel.png'
	chemieZubehor: 'Chemie-Zubehoer.png'
	ampullen: 'Ampullen.png'
	antenne: 'Antenne.png'
	automat: 'Automat.png'
	beamer: 'Beamer.png'
	box: 'Box.png'
	boxFramed: 'Box_framed.png'
	boxSifi: 'Box_Sifi.png'
	boxSifi2: 'Box_Sifi2.png'
	flascheBlau: 'Flasche_blau.png'
	flascheGruen: 'Flasche_gruen.png'
	flascheRot: 'Flasche_rot.png'
	flaschenBreit: 'Flaschen_breit.png'
	flaschenBreit1: 'Flaschen_breit1.png'
	flaschenBreit2: 'Flaschen_breit2.png'
	flaschensammlung: 'Flaschensammlung.png'
	flaschenstaender: 'Flaschenstaender.png'
	leitungen: 'Leitungen.png'
	pad: 'Pad.png'
	panel: 'Panel.png'
	platinenbox: 'Platinenbox.png'
	ufo: 'Ufo.png'
	bogenbajonett: 'Bogenbajonett.png'
	bogenbajonettProjektil: 'Bogenbajonett-Projektil.png'
	feuerball: 'Feuerball.png'
	turret: 'Turret.png'
	turretbullet1: 'Laser1.png'
	turretbullet2: 'Laser2.png'
	player_laufen: [
		'player_laufen_00.png'
		'player_laufen_01.png'
		'player_laufen_02.png'
		'player_laufen_03.png'
		'player_laufen_04.png'
		'player_laufen_05.png'
		'player_laufen_06.png'
		'player_laufen_07.png'
		'player_laufen_08.png'
		'player_laufen_09.png'
		'player_laufen_10.png'
		'player_laufen_11.png'
		'player_laufen_12.png'
	]
	player_laufen_mit_item: [
		'player_laufen_mit_item_00.png'
		'player_laufen_mit_item_01.png'
		'player_laufen_mit_item_02.png'
		'player_laufen_mit_item_03.png'
		'player_laufen_mit_item_04.png'
		'player_laufen_mit_item_05.png'
		'player_laufen_mit_item_06.png'
		'player_laufen_mit_item_07.png'
		'player_laufen_mit_item_08.png'
		'player_laufen_mit_item_09.png'
		'player_laufen_mit_item_10.png'
		'player_laufen_mit_item_11.png'
		'player_laufen_mit_item_12.png'
	]
	player: 'normal_albert.png'
	player_mit_item: 'stehn_mit_item.png'
	player_sprung: 'sprung.png'
	player_sprung_mit_item: 'sprung_mit_item.png'
	creep: 'alien_alien.png'
	alien_walk: [
		'alien_walk_00.png'
		'alien_walk_01.png'
		'alien_walk_02.png'
		'alien_walk_03.png'
		'alien_walk_04.png'
		'alien_walk_05.png'
		'alien_walk_06.png'
		'alien_walk_07.png'
		'alien_walk_08.png'
		'alien_walk_09.png'
		'alien_walk_10.png'
	]
	alien_dying: [
		'alien_dying_00.png'
		'alien_dying_01.png'
		'alien_dying_02.png'
		'alien_dying_03.png'
		'alien_dying_04.png'
		'alien_dying_05.png'
		'alien_dying_06.png'
		'alien_dying_07.png'
		'alien_dying_08.png'
		'alien_dying_09.png'
		'alien_dying_10.png'
		'alien_dying_11.png'
		'alien_dying_12.png'
		'alien_dying_13.png'
		'alien_dying_14.png'
		'alien_dying_15.png'
	]
	alien_suicide: [
		'alien_suicide_00.png'
		'alien_suicide_01.png'
		'alien_suicide_02.png'
		'alien_suicide_03.png'
		'alien_suicide_04.png'
		'alien_suicide_05.png'
		'alien_suicide_06.png'
		'alien_suicide_07.png'
		'alien_suicide_08.png'
		'alien_suicide_09.png'
		'alien_suicide_10.png'
	]
	alien_burning: [
		'alien_burning_00.png'
		'alien_burning_00.png'
		'alien_burning_01.png'
		'alien_burning_01.png'
		'alien_burning_00.png'
		'alien_burning_00.png'
		'alien_burning_01.png'
		'alien_burning_01.png'
		'alien_burning_00.png'
		'alien_burning_00.png'
		'alien_burning_01.png'
		'alien_burning_01.png'
		'alien_burning_00.png'
		'alien_burning_00.png'
		'alien_burning_01.png'
		'alien_burning_01.png'
		'alien_burning_00.png'
		'alien_burning_00.png'
		'alien_burning_01.png'
		'alien_burning_01.png'
		'alien_burning_02.png'
		'alien_burning_03.png'
		'alien_burning_04.png'
		'alien_burning_05.png'
		'alien_burning_06.png'
		'alien_burning_07.png'
		'alien_burning_08.png'
		'alien_burning_09.png'
		'alien_burning_10.png'
		'alien_burning_11.png'
		'alien_burning_12.png'
		'alien_burning_13.png'
		'alien_burning_14.png'
		'alien_burning_15.png'
	]
	alien_dance: [
		'alien_dance_00.png'
		'alien_dance_00.png'
		'alien_dance_00.png'
		'alien_dance_01.png'
		'alien_dance_01.png'
		'alien_dance_01.png'
	]
	rolling_stone: [
		'rolling_stone1.png'
		'rolling_stone1.png'
		'rolling_stone1.png'
		'rolling_stone1.png'
		'rolling_stone2.png'
		'rolling_stone2.png'
		'rolling_stone3.png'
		'rolling_stone3.png'
		'rolling_stone2.png'
		'rolling_stone2.png'
	]
	stone: [
		'rolling_stone3.png'
	]


	instantwater: 'Instant_Water.png'
	welle: [
		'Die_perfekte_Welle_1.png'
		'Die_perfekte_Welle_1.png'
		'Die_perfekte_Welle_1.png'
		'Die_perfekte_Welle_1.png'
		'Die_perfekte_Welle_2.png'
		'Die_perfekte_Welle_2.png'
		'Die_perfekte_Welle_2.png'
		'Die_perfekte_Welle_2.png'
		'Die_perfekte_Welle_3.png'
		'Die_perfekte_Welle_3.png'
		'Die_perfekte_Welle_3.png'
		'Die_perfekte_Welle_3.png'
	]
	firetrail: [
		'Feuerspur.png'
		'Feuerspur2.png'
		'Feuerspur3.png'
		'Feuerspur4.png'
	]
	ggj: 'Marmelade.png'
	mindcontrol: 'Mindcontrol.png'
	weathermachine: 'Wettermaschine.png'
	cloud: [
		'Wolke.png'
		'Wolke.png'
		'Wolke.png'
		'Wolke.png'
		'Wolke.png'
		'Wolke2.png'
		'Wolke2.png'
		'Wolke2.png'
		'Wolke2.png'
		'Wolke2.png'
		'Wolke3.png'
		'Wolke3.png'
		'Wolke3.png'
		'Wolke3.png'
		'Wolke3.png'
	]
	lightning: [
		'Blitz1.png'
		'Blitz2.png'
		'Blitz3.png'
	]
	railgun: 'Railgun.png'
	rail: 'rail.png'
	lawnchair: 'Lawnchair.png'
	rocketlawnchair: 'Rocket_Lawnchair.png'
	prankgun: 'Scherzpistole.png'
	'prankgun-firing': 'Scherzpistole-Feuer.png'
	tarnkappe: 'Tarnkappe.png'
	explosion: [
		'Explosion1.png'
		'Explosion2.png'
		'Explosion3.png'
		'Explosion4.png'
		'Explosion5.png'
	]

module.exports = class GraphicsSystem extends System
	bounds: false
	stage: false
	constructor: (@stage, @container, @stats, @physicsEngine, loadingFinished) ->
		@receives = ['component-added:Sprite', 'component-removed:Sprite', '!graphics:twistEffect']
		@renderer = PIXI.autoDetectRenderer(800, 600, autoResize: false)
		
		#@domElement = $(@renderer.view).css
		#       width: '100%'
		#       height: '100%'
		@container.append(@renderer.view)
		# Subscribe DOM-Events.
		$(window).resize @resize
		
		# Choose graphics size based on screen size
		if screen.width > 1920
			@urlPrefix = '/images/100/'
		else if screen.width > 960
			@urlPrefix = '/images/50/'
			GraphicsConstants.ASSET_WIDTH /= 2
			GraphicsConstants.ASSET_HEIGHT /= 2
			GraphicsConstants.WORLD_TO_ASSET_SCALE /= 2
		else
			@urlPrefix = '/images/25/'
			GraphicsConstants.ASSET_WIDTH /= 4
			GraphicsConstants.ASSET_HEIGHT /= 4
			GraphicsConstants.WORLD_TO_ASSET_SCALE /= 4


		@megaBackgroundContainer = new PIXI.DisplayObjectContainer()
		@stage.addChild @megaBackgroundContainer
		@backgroundContainer = new PIXI.DisplayObjectContainer()
		@stage.addChild @backgroundContainer
		@levelContainer = new PIXI.DisplayObjectContainer()
		@stage.addChild @levelContainer
		@weaponContainer = new PIXI.DisplayObjectContainer()
		@stage.addChild @weaponContainer
		@hudContainer = new PIXI.DisplayObjectContainer()
		@stage.addChild @hudContainer
		
		@counter = new PIXI.Text '', font: '50px Titan One', fill: '#FEC'
		@stage.addChild @counter
		@loadAssets(loadingFinished)

		if DEBUG
			@physicsDebug = new PhysicsDebugDraw @
			@physicsEngine.render = @physicsDebug

		@resize()
		@animate()
		
		return
		
	loadAssets: (callback) =>
		# Flatten asset urls to array and start loading
		assets = []
		for baseUrl in RESOURCES
			assets.push @urlPrefix + baseUrl
		loader = new PIXI.AssetLoader assets
		loader.load()
		@counter.setText '0%'
		loader.onProgress = =>
			percentDone = Math.floor((1.0 - (loader.loadCount / assets.length)) * 100)
			@counter.setText percentDone + '%'
		loader.onComplete = =>
			# Wrap loaded assets in PIXI.Textures and store as @textures
			@counter.setText ''
			console.log 'Assets loaded'
			for baseUrl in RESOURCES
				# Rename directly loaded resources to just their basename
				texture = PIXI.Texture.removeTextureFromCache @urlPrefix + baseUrl
				if texture?
					PIXI.Texture.addTextureToCache(texture, baseUrl)
			
			@textures = {}
			for key, value of ASSETS
				if value instanceof Array
					@textures[key] = value.map PIXI.Texture.fromFrame
				else
					@textures[key] = PIXI.Texture.fromFrame value
			@initStage()
			callback?()
		return
		
	# Adds decorations to stage (scrolling background and walls)
	initStage: =>
		@background = new PIXI.TilingSprite(@textures.background, GraphicsConstants.ASSET_WIDTH, GraphicsConstants.ASSET_HEIGHT)

		@megaBackgroundContainer.addChild @background
		# @megaBackgroundContainer.filters = [new PIXI.BlurXFilter()]

		return

	# Change scaling so that full viewport height is visible
	resize: =>
		screenHeight = @container.height()
		screenWidth = @container.width()
		
		@renderer.resize screenWidth, screenHeight
		scale = Math.min screenHeight / GraphicsConstants.ASSET_HEIGHT, screenWidth / GraphicsConstants.ASSET_WIDTH

		resizeLayer = (layer) =>
			layer.scale.x = scale
			layer.scale.y  = scale
			layer.position.x  = Math.max 0, screenWidth / 2 - GraphicsConstants.ASSET_WIDTH * scale / 2
			layer.position.y  = Math.max 0, screenHeight / 2 - GraphicsConstants.ASSET_HEIGHT * scale / 2
		
		resizeLayer @levelContainer
		resizeLayer @hudContainer
		resizeLayer @backgroundContainer
		resizeLayer @weaponContainer

		console.log 'scale canvas by', scale
		return

	# Begin rendering (and update @stats).
	animate: =>
		@stats.begin()
		@renderer.render @stage
		if DEBUG
			Matter.Engine.render @physicsEngine
		@stats.end()
		requestAnimationFrame @animate
		return

	# Update graphics state
	step: (deltaTime, state, receivers) =>
		return unless @textures?
		playerCameraOffset = 
			x: 3
			y: 3
		player = state.queryEntities([Player])[0]
		playerComponent = player.get(Player)[0]
		playerPos = player.get(Position)[0]

		setLayerPosition = (layer) =>
			layer.position.x = -1 * (playerPos.x - playerCameraOffset.x) * GraphicsConstants.WORLD_TO_ASSET_SCALE * layer.scale.x
			layer.position.y = -1 * (playerPos.y + playerCameraOffset.y) * GraphicsConstants.WORLD_TO_ASSET_SCALE * layer.scale.y + @container.height() / 2
		
		setLayerPosition @levelContainer
		setLayerPosition @backgroundContainer
		setLayerPosition @weaponContainer
		@counter.setText playerComponent.progress.toFixed(0) + ' m'
		# Parallax backgrounds
		@background.tilePosition.x = -1 * playerComponent.progress * GraphicsConstants.WORLD_TO_ASSET_SCALE * 0.7

		# Create PIXI sprite for new sprites.
		for event in receivers['component-added:Sprite']()
			spriteComponent = event[0]
			texture = @textures[spriteComponent.texture]
			if texture instanceof Array
				item = new PIXI.MovieClip texture
				item.loop = spriteComponent.loop if spriteComponent.loop?
				item.animationSpeed = 0.5
				item.play()
			else
				item = new PIXI.Sprite texture
			item.width = spriteComponent.width * GraphicsConstants.WORLD_TO_ASSET_SCALE if spriteComponent.width
			item.height = spriteComponent.height * GraphicsConstants.WORLD_TO_ASSET_SCALE if spriteComponent.height
			item.visible = false
			if spriteComponent.anchor?
				item.anchor = new PIXI.Point spriteComponent.anchor.x, spriteComponent.anchor.y
			else
				item.anchor = new PIXI.Point 0.5, 0.5

			spriteComponent.object = item
			switch spriteComponent.layer 
				when 'hud'
					@hudContainer.addChild item
				when 'background'
					@backgroundContainer.addChild item
				when 'weapon'
					@weaponContainer.addChild item
				else
					@levelContainer.addChild item

		# Remove PIXI sprites.
		for event in receivers['component-removed:Sprite']()
			spriteComponent = event[0]
			switch spriteComponent.layer 
				when 'hud'
					@hudContainer.removeChild spriteComponent.object
				when 'background'
					@backgroundContainer.removeChild item
				when 'weapon'
					@weaponContainer.removeChild spriteComponent.object
				else
					@levelContainer.removeChild spriteComponent.object
			spriteComponent.object = null
			
		for event in receivers['!graphics:twistEffect']()
			@effectTime = 5
			filter = new PIXI.TwistFilter()
			filter.radius = 0.5
			@levelContainer.filters = [filter]
			
		@effectTime -= deltaTime
		if @effectTime < 0
			@levelContainer.filters = null
		else
			@levelContainer.filters?[0].radius = Math.max 0.1, @effectTime / 10
		
		# Every tick, update positions and visibility.
		for spriteEntity in state.queryEntities [Sprite]
			position = spriteEntity.get(Position)[0]
			for sprite in spriteEntity.get Sprite
				if position?
					sprite.object.visible = true
					sprite.object.position.x = (position.x + sprite.offsetX) * GraphicsConstants.WORLD_TO_ASSET_SCALE
					sprite.object.position.y = (position.y + sprite.offsetY) * GraphicsConstants.WORLD_TO_ASSET_SCALE
					sprite.object.rotation = position.rotation or 0
				else
					sprite.object.visible = false
		return
			
		

