module.exports = class DeferredEventEmitter
	constructor: ->
		@listeners = {}

	on: (event) =>
		listener =
			aggregatedEvents: []

		@listeners[event] = [] unless @listeners[event]
		@listeners[event].push listener

		return ->
			events = listener.aggregatedEvents
			listener.aggregatedEvents = []
			return events

	emit: (event) =>
		args = Array.prototype.slice.call arguments
		
		if @listeners[event]?
			for listener in @listeners[event]
				listener.aggregatedEvents.push args[1..]
		return
