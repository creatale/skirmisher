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
		return
			
