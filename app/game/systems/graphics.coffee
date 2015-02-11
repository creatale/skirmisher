{System} = require '../base/ecs'
Sprite = require '../components/sprite'
Position = require '../components/position'
GraphicsConstants = require '../lib/graphics_constants'

DEBUG = false

# Files to load from /images/$res/; either a value of ASSETS below or a sprite sheet.
RESOURCES = [
	'alien_walk.json'
]

# Maps `Sprite.texture` string to files; arrays define an animation
ASSETS = {
	dummy: 'alien_walk_00.png'
}

module.exports = class GraphicsSystem extends System
	bounds: false
	stage: false
	constructor: (@stage, @container, @stats, loadingFinished) ->
		@receives = ['component-added:Sprite', 'component-removed:Sprite', 'component-added:Tile', '!graphics:twistEffect']
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
		@stats.end()
		requestAnimationFrame @animate
		return

	# Update graphics state
	step: (deltaTime, state, receivers) =>
		return unless @textures?

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

		hexCorner = (center, size, i) =>
			angle = 2 * Math.PI / 6 * (i + 0.5)
			x = (center.x + size) * (Math.cos angle)
			y = (center.y + size) * (Math.sin angle)
			return new PIXI.Point x, y

		for event in receivers['component-added:Tile']()
			corners = []
			for i in [0..5]
				corner = hexCorner {x: 0, y:0}, 50, i
				corners.push corner
			graphics = new PIXI.Graphics()
			console.log corners
			graphics.beginFill '#FFFF00'
			graphics.drawShape new PIXI.Polygon corners
			graphics.endFill()
			@levelContainer.addChild graphics



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
			
		

