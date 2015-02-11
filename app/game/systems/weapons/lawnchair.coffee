Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Projectile = require '../../components/projectile'
Sprite = require '../../components/sprite'
Player = require '../../components/player'
Creep = require '../../components/creep'
Ground = require '../../components/ground'

module.exports = class RocketLawnchairSubSystem

	constructor: ->
		@projectiles = ['lawnchair']

	handleWeapon: () ->

	handleProjectile: (state, deltaTime, projectileEntity) ->
		projectile = projectileEntity.get(Projectile)[0]
		position = projectileEntity.get(Position)[0]
		physicsBody = projectileEntity.get(PhysicsBody)[0]

		if physicsBody?
			direction = Matter.Vector.normalise physicsBody.linearVelocity
			angle = (Matter.Vector.angle {x: 0, y: 0}, direction)
			FORCE = 0.0003
			physicsBody.applyForce =
				position:
					x: position.x
					y: position.y
				force:
					x: Math.cos(position.rotation) * FORCE
					y: Math.sin(position.rotation) * FORCE

			position.rotation = angle

	handleProjectileCollision: (state, projectileEntity, otherEntity) ->
		return if otherEntity.has Player
		# if otherEntity.has Ground
		# 	state.removeEntity projectileEntity


	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability -= 40
		weaponPosition = weaponEntity.get(Position)[0]
		worldPos = input.mouseState.worldPosition
		direction = Matter.Vector.normalise({x: worldPos.x - weaponPosition.x, y:  worldPos.y - weaponPosition.y})
		angle = (Matter.Vector.angle {x: 0, y: 0}, direction)

		projectileEntity = state.createEntity()
		projectile = new Projectile 'lawnchair'
		projectile.ttl = 60
		
		projectileEntity.addComponent projectile
		projectileBody = new PhysicsBody(1, 1)
		projectileBody.linearVelocity =
			x: direction.x * 40
			y: direction.y * 40
			
		projectileBody.density = 10
		projectileBody.bodyType = 'dynamic'
		projectileEntity.addComponent projectileBody
		position = new Position(weaponPosition.x + direction.x*1.5, weaponPosition.y + direction.y*1.5)
		position.rotation = angle
		projectileEntity.addComponent position
		projectileEntity.addComponent new Sprite('rocketlawnchair', 2, 2)

