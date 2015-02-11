Weapon = require '../../components/weapon'
Position = require '../../components/position'
PhysicsBody = require '../../components/physics_body'
Sprite = require '../../components/sprite'
Creep = require '../../components/creep'

module.exports = class RollingStoneSubSystem

	constructor: ->
		@projectiles = []
	
	handleProjectile: (projectile) ->

	# general Weapon handling
	handleWeapon: (state, deltaTime, weaponEntity) ->
		return


	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weaponPosition = weaponEntity.get(Position)[0]
		weapon.durability = 0

		turretEntity = state.createEntity()
		turretBody = new PhysicsBody(2, 2)			
		turretBody.bodyType = 'dynamic'
		turretBody.inertia = Infinity
		turretBody.density = 10000
		turretEntity.addComponent turretBody
		position = new Position(weaponPosition.x + 1.5, weaponPosition.y)
		turretEntity.addComponent position
		turretEntity.addComponent new Sprite('rolling_stone', 2.5, 2)

		for creep in state.queryEntities(Creep)
			creep.removeAllComponents(PhysicsBody)
			creep.removeAllComponents(Sprite)
			creep.addComponent new Sprite('alien_dance', 2.25, 4.5)
		return

