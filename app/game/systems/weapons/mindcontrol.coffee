Weapon = require '../../components/weapon'
PhysicsBody = require '../../components/physics_body'
Creep = require '../../components/creep'
Sprite = require '../../components/sprite'

module.exports = class MindControlSubSystem
	
	constructor: ->
		@projectiles = []

	handleWeapon: () ->
	
	handleProjectile: (state, deltaTime, projectileEntity) ->
		null

	fire: (state, playerEntity, input, weaponEntity) ->
		weapon = weaponEntity.get(Weapon)[0]
		weapon.durability -= 50
		
		# state.emitEvent '!graphics:twistEffect'
		
		for creepEntity in state.queryEntities(Creep)
			creepEntity.removeAllComponents PhysicsBody
			sprite = creepEntity.get(Sprite)[0]
			creepComponent = creepEntity.get(Creep)[0]
			if sprite?
				creepEntity.removeComponent sprite
				creepComponent.dying = 0.6
				sprite = new Sprite('alien_suicide', sprite.width, sprite.height)
				sprite.loop = false
				creepEntity.addComponent sprite
			
