Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Projectile = require '../../components/projectile'
Sprite = require '../../components/sprite'
Player = require '../../components/player'
Creep = require '../../components/creep'

module.exports = class PrankGunSubSystem

	constructor: ->
		@projectiles = ['prankgun-fire']

	handleWeapon: () ->
	
	handleProjectile: (state, deltaTime, projectileEntity) ->
		projectile = projectileEntity.get(Projectile)[0]
		position = projectileEntity.get(Position)[0]
		physicsBody = projectileEntity.get(PhysicsBody)[0]
		playerPosition = state.queryEntities(Player, Position)[0]?.get(Position)?[0]
		position.x = playerPosition.x + 1.5
		position.y = playerPosition.y - 0.15


	handleProjectileCollision: (state, projectileEntity, otherEntity) ->
		return if otherEntity.has Player
		if otherEntity.has(Creep)
			state.removeEntity projectileEntity
		return


	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability -= 0.5
		weaponPosition = weaponEntity.get(Position)[0]

		projectileEntity = state.createEntity()
		projectile = new Projectile 'prankgun-fire'
		projectile.ttl = 3
		projectileEntity.addComponent projectile
		projectileBody = new PhysicsBody(0.5, 2)
		projectileBody.bodyType = 'dynamic'
		projectileBody.inertia = Infinity
		projectileBody.collisionFilter =
			group: 0
			category: 0b10000
			mask: 0b10
		projectileEntity.addComponent projectileBody
		position = new Position(weaponPosition.x + 1, weaponPosition.y)

		projectileEntity.addComponent position
		projectileEntity.addComponent new Sprite('prankgun-firing', 1.2, 0.72, -1)

