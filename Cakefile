{spawn} = require 'child_process'
os = require 'os'
fs = require 'fs'
path = require 'path'

cmd = (name) ->
	if os.platform() is 'win32' then name + '.cmd' else name

npm = cmd 'npm'
brunch = cmd 'brunch'
bower = cmd 'bower'

task 'install', 'Install node.js packages', ->
	spawn npm, ['install'], {cwd: '.', stdio: 'inherit'}
	spawn bower, ['install', '--allow-root'], {cwd: '.', stdio: 'inherit'}

task 'update', 'Update node.js packages', ->
	spawn npm, ['update'], {cwd: '.', stdio: 'inherit'}
	spawn bower, ['update'], {cwd: '.', stdio: 'inherit'}
	
task 'build', 'Build brunch project', ->
	brunch = spawn brunch, ['build'], {cwd: '.', stdio: 'inherit'}

task 'watch', 'Watch brunch project', ->
	brunch = spawn brunch, ['watch', '--server', '-p', '9000'], {cwd: '.', stdio: 'inherit'}
	brunch.on 'exit', (status) -> process.exit(status)

task 'bake', 'Bake the Images', ->
	async = require 'async'
	glob = require 'glob'
	glob 'assets/images/*', (err, groups) ->
		async.eachSeries groups, bakeImageGroup, (error) ->
			console.error error if error?

bakeImageGroup = (directory, done) ->
	glob = require 'glob'
	glob directory + '/*.??g', (err, files) ->
		console.error err if err?
		console.log directory, files.length
		name = directory.split('/')[-1..][0]
		if name is 'background'
			copyAndResize files, 'app/assets/images', done
		else
			makeAllSpritesheets name, files, done

copyAndResize = (files, destination, done) ->
	async = require 'async'
	gm = require 'gm'
	fs.mkdirSync path.join(destination, '100') unless fs.existsSync path.join(destination, '100')
	fs.mkdirSync path.join(destination, '50') unless fs.existsSync path.join(destination, '50')
	fs.mkdirSync path.join(destination, '25') unless fs.existsSync path.join(destination, '25')
	async.each files, (file, next) ->
		basename = path.basename file
		async.parallel [
			(done) ->
				gm(file).write(path.join(destination, '100', basename), done)
			,
			(done) ->
				gm(file).resize(50, '%').write(path.join(destination, '50', basename), done)
			,
			(done) ->
				gm(file).resize(25, '%').write(path.join(destination, '25', basename), done)
		], next
	, done

makeAllSpritesheets = (name, files, done) ->
	os = require 'os'
	async = require 'async'
	dir = path.join os.tmpdir(), 'spritesheet'
	fs.mkdirSync dir
	copyAndResize files, dir, ->
		async.parallel [
			makeSpritesheet.bind null, name, dir, '100'
			makeSpritesheet.bind null, name, dir, '50'
			makeSpritesheet.bind null, name, dir, '25'
		], (err) ->
			return done err if err?
			fs.rmdir dir, done

makeSpritesheet = (name, baseDir, variant, done) ->
	glob = require 'glob'
	params = '--format json --png-opt-level 0 --trim-mode None --algorithm Basic --max-size 4096'.split(' ')
	targetBasename = path.join 'app/assets/images', variant, name
	p = spawn 'TexturePacker', params.concat(['--data', targetBasename + '.json', '--sheet', targetBasename + '.png', path.join(baseDir, variant)]), {stdio: 'inherit'}
	p.on 'exit', (code) ->
		return done new Error('TexturePacker exited with ' + code) if code isnt 0
		glob path.join(baseDir, variant, '*'), (err, files) ->
			fs.unlinkSync file for file in files
			fs.rmdirSync path.join(baseDir, variant)
			done()
			
task 'load_weapons', 'Prepare weapons for baking', ->
	glob = require 'glob'
	async = require 'async'
	gm = require 'gm'
	targetWidth = 400
	glob 'assets_orig/weapons/*.??g', (error, files) ->
		if error
			console.log error
			return
		destination = 'assets/images/weapons'
		fs.mkdirSync destination unless fs.existsSync destination
		async.each files, (file, next) ->
			basename = path.basename file
			gm(file).resize(targetWidth).write(path.join(destination, basename), next)
		return

task 'test', 'Build brunch project and run tests once', ->
	console.log 'Ja, mach mal'
