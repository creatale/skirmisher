View = require 'views/base/view'
Game = require 'game/game'

#isTouchDevice = ->
#	return 'ontouchstart' of window or 'onmsgesturechange' of window

module.exports = class GameView extends View
	container: 'body'
	autoRender: true
#	template: require 'views/templates/home'
	id: 'game'

	initialize: ->
		super
		
	render: =>
		super

	dispose: =>
		super
		@game.dispose()
	
	attach: =>
		super
		@game = new Game @$el
		# Hide (non-)touch dependend elements.
#		if isTouchDevice()
#			@$('.hidden-touch').hide()
#		else
#			@$('.visible-touch').hide()
		# Disable login button.
#		@$('.form-login > button').prop('disabled', true)
	
