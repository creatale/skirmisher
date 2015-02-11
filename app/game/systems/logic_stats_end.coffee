{System} = require '../base/ecs'

module.exports = class LogicStatsEndSystem extends System
	constructor: (@logicStats) ->
		return
		
	step: (deltaTime, state, receivers) =>
		@logicStats.end()
		return
