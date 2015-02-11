Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Projectile = require '../../components/projectile'
Sprite = require '../../components/sprite'

module.exports = class InstantWaterSubSystem

	constructor: ->
		@projectiles = ['welle']

	handleProjectile: (state, deltaTime, projectileEntity) ->
		projectile = projectileEntity.get(Projectile)[0]
		position = projectileEntity.get(Position)[0]
		position.x += 0.01
		position.y = 10
				
	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability = 0
		weaponPosition = weaponEntity.get(Position)[0]
		worldPos = input.mouseState.worldPosition
		direction = Matter.Vector.normalise({x: worldPos.x - weaponPosition.x, y:  worldPos.y - weaponPosition.y})
		angle = (Matter.Vector.angle {x: 0, y: 0}, direction)

		projectileEntity = state.createEntity()
		projectileBody = new PhysicsBody(30, 30)

		projectileBody.density = 500
		projectileBody.bodyType = 'dynamic'
		projectileBody.inertia = Infinity
		projectileBody.collisionFilter =
			group: 0
			category: 0b10000
			mask: 0b10
		projectileEntity.addComponent projectileBody
		position = new Position(weaponPosition.x - 5, 10)
		projectileEntity.addComponent position
		projectileEntity.addComponent new Sprite('welle', 30, 30)
		projectile = new Projectile 'welle'
		projectileEntity.addComponent projectile
