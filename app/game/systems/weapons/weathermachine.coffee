Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Projectile = require '../../components/projectile'
Sprite = require '../../components/sprite'

module.exports = class WeatherMachineSubSystem
	
	constructor: ->
		@projectiles = ['cloud']

	handleProjectile: (state, deltaTime, projectileEntity) ->
		projectile = projectileEntity.get(Projectile)[0]
		position = projectileEntity.get(Position)[0]
		

		if projectile.name is 'cloud'
			position.x += 0.0005
			position.y = 4
			projectile.lastFire += deltaTime
			if projectile.lastFire > 1/projectile.rateOfFire
				lightningEntity = state.createEntity()
				lightning = new Projectile 'lightning'
				lightning.ttl = 1
				lightningEntity.addComponent lightning
				projectileBody = new PhysicsBody(4, 1)
				projectileBody.linearVelocity = 
					x: 50*Math.random()
					y: 50*Math.random() - 25
				projectileBody.collisionFilter =
					group: 0
					category: 0b10000
					mask: 0b10
				projectileBody.bodyType = 'dynamic'
				lightningEntity.addComponent projectileBody
				lightningPosition = new Position(position.x + 1.5, position.y)
				# position.rotation = angle
				lightningEntity.addComponent lightningPosition
				lightningEntity.addComponent new Sprite('lightning', 4, 1)
				projectile.lastFire -= 1/projectile.rateOfFire
				
	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability -= 2
		weaponPosition = weaponEntity.get(Position)[0]
		worldPos = input.mouseState.worldPosition
		direction = Matter.Vector.normalise({x: worldPos.x - weaponPosition.x, y:  worldPos.y - weaponPosition.y})
		angle = (Matter.Vector.angle {x: 0, y: 0}, direction)

		projectileEntity = state.createEntity()
		projectileBody = new PhysicsBody(20, 20)

		projectileBody.density = 500
		projectileBody.bodyType = 'dynamic'
		projectileBody.inertia = Infinity
		projectileBody.collisionFilter =
			group: 0
			category: 0b10000
			mask: 0b10
		projectileEntity.addComponent projectileBody
		position = new Position(weaponPosition.x - 5, 0)
		projectileEntity.addComponent position
		projectileEntity.addComponent new Sprite('cloud', 20, 20)
		projectile = new Projectile 'cloud'
		projectile.rateOfFire = 5
		projectile.lastFire = 0
		projectileEntity.addComponent projectile