{System} = require '../base/ecs'

module.exports = class LogicStatsStartSystem extends System
	constructor: (@logicStats) ->
		return
		
	step: (deltaTime, state, receivers) =>
		@logicStats.begin()
		return
