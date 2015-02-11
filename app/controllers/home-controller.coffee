mediator = require 'mediator'

Controller = require 'controllers/base/controller'
HomeView = require 'views/home-view'
GameView = require 'views/game-view'

module.exports = class HomeController extends Controller
	index: ->
		@redirectTo 'home#game'

	game: =>
		# dirty hack for restarting all dependencies because the engine and PIXI don't dispose right
		if window.dirtyEngine?
			setTimeout (-> window.location.reload()), 1			
			return
		else
			window.dirtyEngine = 'so dirty!'
		@view = new GameView()
		@subscribeEvent 'game-over', (cause, score) =>
			switch cause
				when 'death-by-prince'
					console.log 'caught by the enemy formerly known as prince'
				when 'death-by-out-of-lives'
					console.log 'death by running out of lives'

			# save the score
			if window.localStorage?
				store = window.localStorage
				scores = store.getItem 'scores'
				if scores
					scores = JSON.parse scores
				else
					scores = []
				scores.push
					date: Date.now()
					score: score
					cause: cause
				store.setItem 'scores', JSON.stringify scores

			#@redirectTo 'home#gameOver', cause: cause
			@view.game.engine.stop()
			@view.dispose()
			
			@view = new GameOverView
				cause: cause
				score: score

			@listenTo @view, 'try-again', =>
				# kill all
				window.location.reload()

	# for fast debug only
	gameOver: (params, options, query) ->
		@view = new GameOverView
			cause: query.query.cause
			score: query.query.score

		# # skip dialogs
		# @subscribeEvent 'develop-faster', =>
			# @publishEvent '!io:emit', 'authenticate', {username: 'developer'}, (user) =>
				# mediator.user = user
				# realm = new Realm()
				# realm.save {name: 'develop'},
					# success: =>
						# @redirectTo 'realm#show', {id: realm.get 'id'}
