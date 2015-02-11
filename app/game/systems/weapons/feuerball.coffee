Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Projectile = require '../../components/projectile'
Sprite = require '../../components/sprite'

module.exports = class FeuerballSubSystem

	constructor: ->
		@projectiles = ['feuerball', 'firetrail']

	handleProjectile: (state, deltaTime, projectileEntity) ->
		projectile = projectileEntity.get(Projectile)[0]
		position = projectileEntity.get(Position)[0]

		switch projectile.name
			when 'feuerball'
				physicsBody = projectileEntity.get(PhysicsBody)[0]
				physicsBody.linearVelocity.x = 10
				if position.x - projectile.lastTrail > 0.5
					projectile.lastTrail = position.x
					trailEntity = state.createEntity()
					trailProjectile = new Projectile 'firetrail'
					trailProjectile.ttl = 0.3
					trailEntity.addComponent trailProjectile
					trailPosition = new Position(position.x, position.y)
					trailEntity.addComponent trailPosition
					trailEntity.addComponent new Sprite('firetrail', 1, 1)

			# when 'firetrail'
				
	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability -= 2
		weaponPosition = weaponEntity.get(Position)[0]
		worldPos = input.mouseState.worldPosition
		direction = Matter.Vector.normalise({x: worldPos.x - weaponPosition.x, y:  worldPos.y - weaponPosition.y})
		angle = (Matter.Vector.angle {x: 0, y: 0}, direction)

		projectileEntity = state.createEntity()
		projectileBody = new PhysicsBody()
		projectileBody.shape = 'circle'
		projectileBody.radius = 0.5
		projectileBody.density = 50
		projectileBody.bodyType = 'dynamic'
		projectileEntity.addComponent projectileBody
		position = new Position(weaponPosition.x + 1, weaponPosition.y)
		projectileEntity.addComponent position
		projectileEntity.addComponent new Sprite('feuerball', 1, 1)
		projectile = new Projectile 'feuerball'
		projectile.lastTrail = position.x
		projectileEntity.addComponent projectile
