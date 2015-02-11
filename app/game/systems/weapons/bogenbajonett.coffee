Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Projectile = require '../../components/projectile'
Sprite = require '../../components/sprite'
Player = require '../../components/player'
Creep = require '../../components/creep'

module.exports = class BogenBajonettSubSystem

	constructor: ->
		@projectiles = ['bogenbajonettProjektil']

	handleWeapon: () ->
	
	handleProjectile: (state, deltaTime, projectileEntity) ->
		projectile = projectileEntity.get(Projectile)[0]
		position = projectileEntity.get(Position)[0]
		physicsBody = projectileEntity.get(PhysicsBody)[0]

		if physicsBody?
			direction = Matter.Vector.normalise physicsBody.linearVelocity
			angle = (Matter.Vector.angle {x: 0, y: 0}, direction)
			position.rotation = angle

	handleProjectileCollision: (state, projectileEntity, otherEntity) ->
		return if otherEntity.has Player
		if otherEntity.has Creep
			state.removeEntity projectileEntity
		else
			projectileEntity.removeAllComponents PhysicsBody


	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability -= 2
		weaponPosition = weaponEntity.get(Position)[0]
		worldPos = input.mouseState.worldPosition
		direction = Matter.Vector.normalise({x: worldPos.x - weaponPosition.x, y:  worldPos.y - weaponPosition.y})
		angle = (Matter.Vector.angle {x: 0, y: 0}, direction)

		projectileEntity = state.createEntity()
		projectile = new Projectile 'bogenbajonettProjektil'
		projectile.ttl = 5
		projectileEntity.addComponent projectile
		projectileBody = new PhysicsBody(1, 0.5)
		projectileBody.linearVelocity = 
			x: direction.x * 50
			y: direction.y * 50
		projectileBody.bodyType = 'dynamic'
		projectileEntity.addComponent projectileBody
		position = new Position(weaponPosition.x + direction.x*1.5, weaponPosition.y + direction.y*1.5)
		position.rotation = angle
		projectileEntity.addComponent position
		projectileEntity.addComponent new Sprite('bogenbajonettProjektil', 1.6, 1)

