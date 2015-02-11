GraphicsConstants = require '../lib/graphics_constants'

module.exports = class PhysicsDebugDraw
	constructor: (@graphics)->
		_.extend @, Matter.RenderPixi
		defaults =
			controller: @
			element: null
			canvas: null
			options:
				width: 800
				height: 600
				background: '#fafafa'
				wireframeBackground: '#222'
				hasBounds: false
				enabled: true
				wireframes: true
				showSleeping: true
				showDebug: false
				showBroadphase: false
				showBounds: true
				showVelocity: true
				showCollisions: true
				showAxes: true
				showPositions: true
				showAngleIndicator: true
				showIds: false
				showShadows: false

		_.extend @, defaults
		# transparent = !render.options.wireframes && render.options.background === 'transparent';

		@context = graphics.renderer
		@canvas = @context.view;
		# @container = new PIXI.DisplayObjectContainer();
		@container = @graphics.levelContainer
		@stage = graphics.stage
		@bounds = @bounds || { 
				min: { 
						x: 0,
						y: 0
				}, 
				max: { 
						x: @options.width,
						y: @options.height
				}
		}

		@textures = {}
		@sprites = {}
		@primitives = {}

		@spriteBatch = new PIXI.SpriteBatch();
		@container.addChild(@spriteBatch);

		# if (Common.isElement(render.element)) {
		# 		render.element.appendChild(render.canvas);
		# } else {
		# 		Common.log('No "render.element" passed, "render.canvas" was not inserted into document.', 'warn');
		# }

		# // prevent menus on canvas
		# render.canvas.oncontextmenu = function() { return false; };
		# render.canvas.onselectstart = function() { return false; };


		@world = (engine) =>
			# var render = engine.render,
			world = engine.world
			# 		context = render.context,
			# 		stage = render.stage,
			# 		container = render.container,
			# 		options = render.options,
			bodies = Matter.Composite.allBodies world
			allConstraints = Matter.Composite.allConstraints world
			constraints = []

			# // handle bounds
			# var boundsWidth = render.bounds.max.x - render.bounds.min.x,
			# 		boundsHeight = render.bounds.max.y - render.bounds.min.y,
			# 		boundsScaleX = boundsWidth / render.options.width,
			# 		boundsScaleY = boundsHeight / render.options.height;

			# if (options.hasBounds) {
			# 		// Hide bodies that are not in view
			# 		for (i = 0; i < bodies.length; i++) {
			# 				var body = bodies[i];
			# 				body.render.sprite.visible = Bounds.overlaps(body.bounds, render.bounds);
			# 		}

			# 		// filter out constraints that are not in view
			# 		for (i = 0; i < allConstraints.length; i++) {
			# 				var constraint = allConstraints[i],
			# 						bodyA = constraint.bodyA,
			# 						bodyB = constraint.bodyB,
			# 						pointAWorld = constraint.pointA,
			# 						pointBWorld = constraint.pointB;

			# 				if (bodyA) pointAWorld = Vector.add(bodyA.position, constraint.pointA);
			# 				if (bodyB) pointBWorld = Vector.add(bodyB.position, constraint.pointB);

			# 				if (!pointAWorld || !pointBWorld)
			# 						continue;

			# 				if (Bounds.contains(render.bounds, pointAWorld) || Bounds.contains(render.bounds, pointBWorld))
			# 						constraints.push(constraint);
			# 		}

			# 		// transform the view
			# 		container.scale.set(1 / boundsScaleX, 1 / boundsScaleY);
			# 		container.position.set(-render.bounds.min.x * (1 / boundsScaleX), -render.bounds.min.y * (1 / boundsScaleY));
			# } else {
			# 		;
			# }
			# container.scale = @graphics
			constraints = allConstraints
			for body in bodies
				@body engine, body

			for constraint in constraints
				@constraint engine, constraint

			#if options.showCollisions
			#	Render.collisions engine, engine.pairs.list


		@body = (engine, body) =>
			render = engine.render
			bodyRender = body.render

			if bodyRender.sprite and bodyRender.sprite.texture
				spriteId = "b-" + body.id
				sprite = render.sprites[spriteId]
				spriteBatch = render.spriteBatch
				
				# initialise body sprite if not existing
				sprite = render.sprites[spriteId] = _createBodySprite(render, body)  unless sprite
				
				# add to scene graph if not already there
				spriteBatch.addChild sprite  if Matter.Common.indexOf(spriteBatch.children, sprite) is -1
				
				# update body sprite
				sprite.position.x = body.position.x * GraphicsConstants.WORLD_TO_ASSET_SCALE
				sprite.position.y = body.position.y * GraphicsConstants.WORLD_TO_ASSET_SCALE
				sprite.rotation = body.angle
				sprite.scale.x = GraphicsConstants.WORLD_TO_ASSET_SCALE
				sprite.scale.y = GraphicsConstants.WORLD_TO_ASSET_SCALE
			else
				primitiveId = "b-" + body.id
				primitive = render.primitives[primitiveId]
				container = render.container
				
				# initialise body primitive if not existing
				unless primitive
					primitive = render.primitives[primitiveId] = _createBodyPrimitive(render, body)
					primitive.initialAngle = body.angle
				
				# add to scene graph if not already there
				container.addChild primitive  if Matter.Common.indexOf(container.children, primitive) is -1
				
				# update body primitive
				primitive.position.x = body.position.x * GraphicsConstants.WORLD_TO_ASSET_SCALE
				primitive.position.y = body.position.y * GraphicsConstants.WORLD_TO_ASSET_SCALE
				# primitive.scale.x = GraphicsConstants.WORLD_TO_ASSET_SCALE
				# primitive.scale.y = GraphicsConstants.WORLD_TO_ASSET_SCALE
				primitive.rotation = body.angle - primitive.initialAngle

		@constraint = (engine, constraint) =>
			render = engine.render
			bodyA = constraint.bodyA
			bodyB = constraint.bodyB
			pointA = constraint.pointA
			pointB = constraint.pointB
			container = render.container
			constraintRender = constraint.render
			primitiveId = "c-" + constraint.id
			primitive = render.primitives[primitiveId]
			
			# initialise constraint primitive if not existing
			primitive = render.primitives[primitiveId] = new PIXI.Graphics() unless primitive
			
			# don't render if constraint does not have two end points
			if not constraintRender.visible or not constraint.pointA or not constraint.pointB
				primitive.clear()
				return
			
			# add to scene graph if not already there
			container.addChild primitive  if Matter.Common.indexOf(container.children, primitive) is -1
			
			# render the constraint on every update, since they can change dynamically
			primitive.clear()
			primitive.beginFill 0, 0
			primitive.lineStyle constraintRender.lineWidth, Matter.Common.colorToNumber(constraintRender.strokeStyle), 1
			if bodyA
				primitive.moveTo (bodyA.position.x + pointA.x) * GraphicsConstants.WORLD_TO_ASSET_SCALE, (bodyA.position.y + pointA.y) * GraphicsConstants.WORLD_TO_ASSET_SCALE
			else
				primitive.moveTo pointA.x * GraphicsConstants.WORLD_TO_ASSET_SCALE, pointA.y * GraphicsConstants.WORLD_TO_ASSET_SCALE
			if bodyB
				primitive.lineTo (bodyB.position.x + pointB.x) * GraphicsConstants.WORLD_TO_ASSET_SCALE, (bodyB.position.y + pointB.y) * GraphicsConstants.WORLD_TO_ASSET_SCALE
			else
				primitive.lineTo pointB.x * GraphicsConstants.WORLD_TO_ASSET_SCALE, pointB.y * GraphicsConstants.WORLD_TO_ASSET_SCALE
			primitive.endFill()
			return

_createBodySprite = (render, body) ->
	bodyRender = body.render
	texturePath = bodyRender.sprite.texture
	texture = _getTexture(render, texturePath)
	sprite = new PIXI.Sprite(texture)
	sprite.anchor.x = 0.5
	sprite.anchor.y = 0.5
	sprite

_createBodyPrimitive = (render, body) ->
	bodyRender = body.render
	options = render.options
	primitive = new PIXI.Graphics()
	primitive.clear()
	unless options.wireframes
		primitive.beginFill Matter.Common.colorToNumber(bodyRender.fillStyle), 1
		primitive.lineStyle body.render.lineWidth, Matter.Common.colorToNumber(bodyRender.strokeStyle), 1
	else
		primitive.beginFill 0, 0
		primitive.lineStyle 2, Matter.Common.colorToNumber("#bbb"), 1
	primitive.moveTo (body.vertices[0].x - body.position.x) * GraphicsConstants.WORLD_TO_ASSET_SCALE, (body.vertices[0].y - body.position.y) * GraphicsConstants.WORLD_TO_ASSET_SCALE
	j = 1

	while j < body.vertices.length
		primitive.lineTo (body.vertices[j].x - body.position.x) * GraphicsConstants.WORLD_TO_ASSET_SCALE, (body.vertices[j].y - body.position.y) * GraphicsConstants.WORLD_TO_ASSET_SCALE
		j++
	primitive.lineTo (body.vertices[0].x - body.position.x) * GraphicsConstants.WORLD_TO_ASSET_SCALE, (body.vertices[0].y - body.position.y) * GraphicsConstants.WORLD_TO_ASSET_SCALE
	primitive.endFill()
	
	# angle indicator
	if options.showAngleIndicator or options.showAxes
		primitive.beginFill 0, 0
		if options.wireframes
			primitive.lineStyle 2, Matter.Common.colorToNumber("#CD5C5C"), 1
		else
			primitive.lineStyle 2, Matter.Common.colorToNumber(body.render.strokeStyle)
		primitive.moveTo 0, 0
		primitive.lineTo (((body.vertices[0].x + body.vertices[body.vertices.length - 1].x) / 2) - body.position.x) * GraphicsConstants.WORLD_TO_ASSET_SCALE, (((body.vertices[0].y + body.vertices[body.vertices.length - 1].y) / 2) - body.position.y) * GraphicsConstants.WORLD_TO_ASSET_SCALE
		primitive.endFill()
	primitive
