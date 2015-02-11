module.exports.WAYBITS = WAYBITS =
	NONE: 0x0
	WEST: 0x1
	NW: 0x2
	NE: 0x4
	EAST: 0x8
	SE: 0x10
	SW: 0x20
	ALL: 0x3F

	format: (bits) ->
		return 'NONE' if bits is @NONE
		return 'ALL' if bits is @ALL
		values = (name for name, value of @ when @NONE < value < @ALL and bits & value)
		return values.join('&')

# Returns the Waybit which leads from the common border of `from` and `to` to the center of `to`.
# Behavior when `from` and `to` are not neighbors is undefined. Both must be of form {x, y}.
module.exports.getEnteringBit = getEnteringBit = (from, to) ->
	# Adjust X coordinate from grid to graphical
	prevX = from.x - (if from.y % 2 then 0.5 else 0)
	curX = to.x - (if to.y % 2 then 0.5 else 0)
	# Build connection from center of previousTile to center of current tile
	if from.y < to.y
		enteringBit = if prevX < curX then WAYBITS.NW else WAYBITS.NE
	else if from.y > to.y
		enteringBit = if prevX < curX then WAYBITS.SW else WAYBITS.SE
	else
		enteringBit = if prevX < curX then WAYBITS.WEST else WAYBITS.EAST
	return enteringBit

# Convert offset (tile) coordinates to cube coordinates.
# Accepts two values or {x, y} and returns {x, y, z}.
module.exports.toCube = toCube = (q, r) ->
	if arguments.length is 1
		return toCube q.x, q.y
	x = q - (r + (r&1)) / 2
	z = r
	y = -x-z
	return {x, y, z}

# Convert cube coordinates to offset (tile) coordinates.
# Accepts three values or {x, y, z} and returns {x, y}.
module.exports.toOffset = toOffset = (x, y, z) ->
	if arguments.length is 1
		return toOffset x.x, x.y, x.z
	q = x + (z + (z&1)) / 2
	r = z
	return {x: q, y: r}

# Return the distance between two tile coordinates.
# Supports all of the following forms:
#   (x1, y1, z1, x2, y2, z2): Two sets of cube coordinates as scalars
#   (x1, y1, x2, y2): Two sets of offset (regular) coordinates as scalars
#   ({x1, y1}, {x2, y2}): Offset coordinates as objects
module.exports.distance = distance = (x1, y1, z1, x2, y2, z2) ->
	args = Array.prototype.slice.call arguments
	if args.length is 6
		# six scalars form -> cube coordinates
		return Math.max Math.abs(x1 - x2), Math.abs(y1 - y2), Math.abs(z1 - z2)
	else if args.length is 4
		# Four scalars form -> even-r coordinates
		x2 = args[2]
		y2 = args[3]
		tile1 = toCube x1, y1
		tile2 = toCube x2, y2
		d = distance tile1.x, tile1.y, tile1.z, tile2.x, tile2.y, tile2.z
		return d
	else if args.length is 2
		# Two objects form -> may be even-r or cube.
		tile1 = args[0]
		tile2 = args[1]
		tile1 = toCube(tile1.x, tile1.y) unless tile1.z?
		tile2 = toCube(tile2.x, tile2.y) unless tile2.z?
		return distance tile1.x, tile1.y, tile1.z, tile2.x, tile2.y, tile2.z

# Get the tile coordinates when moving from `(x, y)` in `direction`.
module.exports.neighbor = neighbor = (x, y, direction) ->
	directions = [WAYBITS.EAST, WAYBITS.NE, WAYBITS.NW, WAYBITS.WEST, WAYBITS.SW, WAYBITS.SE]
	offsets =
		evenRow: [[1, 0], [1, -1], [0, -1], [-1, 0], [0, 1], [1, 1]]
		oddRow: [[1, 0], [0, -1], [-1, -1], [-1, 0], [-1, 1], [0, 1]]
	offsets = if y & 1 then offsets.oddRow else offsets.evenRow
	offset = offsets[directions.indexOf(direction)]
	return {x: x + offset[0], y: y + offset[1]}

# Round cube coordinates, i.e. return the tile center.
# Accepts coordinates as three values or object and returns an object.
module.exports.round = round = (x, y, z) ->
	if arguments.length is 1
		return round x.x, x.y, x.z
	rx = Math.round x
	ry = Math.round y
	rz = Math.round z

	x_diff = Math.abs rx - x
	y_diff = Math.abs ry - y
	z_diff = Math.abs rz - z

	if x_diff > y_diff and x_diff > z_diff
		rx = -ry-rz
	else if y_diff > z_diff
		ry = -rx-rz
	else
		rz = -rx-ry

	return {x: rx, y: ry, z: rz}

# Converts rectangular (x, y) coordinates on the surface plane of the map to tile coordinates.
module.exports.surfaceToTileCoordinates = (x, y) ->
	# Assuming that width from hexagon side to another is 1
	size = 1/Math.sqrt(3)

	# Get rough axial coordinates
	q = (1/3*Math.sqrt(3) * x - 1/3 * y) / size
	r = 2/3 * y / size

	# Convert axial to cube
	x = q
	z = r
	y = -x-z

	# Round to tile
	rounded = round x, y, z

	# Convert back to regular tile coordinates
	return toOffset rounded

# Converts tile coordinates to rectangular surface coordinates.
module.exports.tileToSurfaceCoordinates = tileToSurfaceCoordinates = (x, y) ->
	if arguments.length is 1
		return tileToSurfaceCoordinates x.x, x.y
	rx = x + (-0.5 * (y & 1))
	ry = y * Math.sqrt(3) / 2
	return {x: rx, y: ry}

# Returns a 'spiraling outward' list of all tiles up to `range` tiles away from `(x, y)`.
module.exports.findTilesAround = (x, y, range) ->
	#	console.log 'Finding tiles around', x, y
	directions = [WAYBITS.EAST, WAYBITS.NE, WAYBITS.NW, WAYBITS.WEST, WAYBITS.SW, WAYBITS.SE]
	results = [{x, y}]
	current = neighbor x, y, WAYBITS.SW
	for k in [1..range] by 1
		for segmentDirection in directions
			for i in [0...k] by 1
				results.push current
				current = neighbor current.x, current.y, segmentDirection
		current = neighbor current.x, current.y, WAYBITS.SW
	return results

# Select tiles in a straight line from A (exclusive) to B (inclusive).
# Supports offset {x, y} and cube {x, y, z} coordinates, result is in offset coordinates.
module.exports.straightLine = (tileA, tileB) ->
	tileA = toCube(tileA.x, tileA.y) unless tileA.z?
	tileB = toCube(tileB.x, tileB.y) unless tileB.z?
	result = []
	d = distance tileA, tileB
	for i in [1..d] by 1
		result.push toOffset round
			x: tileA.x * (1 - i / d) + tileB.x * i / d
			y: tileA.y * (1 - i / d) + tileB.y * i / d
			z: tileA.z * (1 - i / d) + tileB.z * i / d
	return result
