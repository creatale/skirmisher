Weapon = require '../../components/weapon'
PhysicsBody = require '../../components/physics_body'
Creep = require '../../components/creep'

module.exports = class GGJSubSystem
	
	constructor: ->
		@projectiles = []

	handleWeapon: () ->
	
	handleProjectile: (state, deltaTime, projectileEntity) ->
		null

	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability = 0
		
		state.emitEvent '!graphics:twistEffect'
		
		for creep in state.queryEntities(Creep)
			state.removeEntity creep
			
