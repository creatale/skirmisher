View = require 'views/base/view'

#isTouchDevice = ->
#	return 'ontouchstart' of window or 'onmsgesturechange' of window

module.exports = class HomeView extends View
	container: 'body'
	autoRender: true
	template: require 'views/templates/home'
	id: 'home'
	events:
		'click' : 'anyKey'
		'keypress': 'anyKey'

	initialize: =>
		$(document).on 'keydown', @anyKey
		super
		
	render: =>
		super

	off: =>
		super
		$(document).off 'keydown'

	anyKey: (event) =>
		event.preventDefault()
		@trigger 'any-key'
