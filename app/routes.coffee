# Application routes.
module.exports = (match) ->
	match '', 'home#index'
	match 'game', 'home#game'
