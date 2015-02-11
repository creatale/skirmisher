class Input
	type: 'Input'
	
	constructor: ->
		@mouseState =
			position:
				x: 0
				y: 0
			ellipse: # This is allways 0 for compatibility reasons with touch state.
				x: 0
				y: 0
				angle: 0
			down: false
			clicked: false
			picked: null
			drag: null
		@touchStates = {}
		@axis =
			x: 0
			y: 0
		@keyState = {}
		# contains
		#	position:
		#		x: 0
		#		y: 0
		#	ellipse:
		#		x: 0
		#		y: 0
		#		angle: 0
		#	down: true
		#	clicked: false
		#	picked: null
		#	drag: null
		# per touch identifier
		# For touches the down state is allways true for compatibility reasons with mouse state.
		return

module.exports = Input
