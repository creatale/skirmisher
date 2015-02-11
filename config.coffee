#
# Brunch configuration file. For documentation see:
# 	https://github.com/brunch/brunch/blob/stable/docs/config.md
#
exports.config =
	paths:
		watched: [
			'app'
		]
	files:
		javascripts:
			joinTo:
				'js/app.js': /^app(\/|\\)(?!vendor)/
				'js/vendor.js': /^(?!app)/
		stylesheets:
			joinTo:
				'css/app.css'
		templates:
			joinTo: 'js/app.js'

	plugins:
		static_jade:
			extension: ".static.jade"
		stylus:
			plugins: ['jeet']
			# imports: ['/node_modules/jeet/stylus/jeet']
	overrides:
		production:
			optimize: true
			sourceMaps: false
			plugins:
				autoReload:
					enabled: false
				cleancss:
					keepSpecialComments: 0
