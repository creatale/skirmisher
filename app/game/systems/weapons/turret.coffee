Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Projectile = require '../../components/projectile'
Sprite = require '../../components/sprite'

module.exports = class TurretSubSystem

	constructor: ->
		@projectiles = ['turretbullet']
	
	handleProjectile: (projectile) ->

	handleProjectileCollision: (state, projectileEntity, otherEntity) ->
		state.removeEntity projectileEntity

	# general Weapon handling
	handleWeapon: (state, deltaTime, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]

		return if weapon.equipped?
		weapon.lastFire += deltaTime
		if weapon.lastFire > 1/weapon.rateOfFire
			weaponPosition = weaponEntity.get(Position)[0]

			projectileEntity = state.createEntity()
			projectile = new Projectile 'turretbullet'
			projectile.ttl = 0.5
			projectileEntity.addComponent projectile
			projectileBody = new PhysicsBody(0.5, 0.2)
			projectileBody.linearVelocity = 
				x: 40
				y: 30*Math.random() - 20
			projectileBody.bodyType = 'dynamic'
			projectileEntity.addComponent projectileBody
			position = new Position(weaponPosition.x + 1.5, weaponPosition.y)
			# position.rotation = angle
			projectileEntity.addComponent position
			projectileEntity.addComponent new Sprite('turretbullet' + _.sample([1,2]), 0.5, 0.2)
			weapon.lastFire -= 1/weapon.rateOfFire


	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weaponPosition = weaponEntity.get(Position)[0]
		weapon.durability -= 40

		turretEntity = state.createEntity()
		weapon = new Weapon 'turret'
		weapon.rateOfFire = 20
		turretEntity.addComponent weapon
		turretBody = new PhysicsBody(1.5, 1.5)			
		turretBody.bodyType = 'dynamic'
		turretEntity.addComponent turretBody
		position = new Position(weaponPosition.x + 1.5, weaponPosition.y)
		turretEntity.addComponent position
		turretEntity.addComponent new Sprite('turret', 1.5, 1.5)
		weapon.lastFire = 0

