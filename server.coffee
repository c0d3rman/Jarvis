ck = require 'coffeekup'
http = require 'http'
url = require 'url'
path = require 'path'
fs = require 'fs'
mime = require 'mime'

port = process.argv[2] or 80

helpers = {}
helpers["_#{f.slice 0, -3}"] = require "./include/#{f}" for f in fs.readdirSync('./include') when f.slice(-3) is ".js"

server = http.createServer (request, response) ->
	message = "Request recieved\n"

	uri = url.parse(request.url).pathname
	filename = path.join process.cwd(), decodeURIComponent uri
	
	if decodeURIComponent(uri).indexOf('..') isnt -1
		message += """
			*** WARNING!!! ***
			Path Traversal attack detected!
			Attacker attempted to access: #{filename}
			Using URI: #{uri}
		"""
		console.log message
		response.writeHead 404, "Content-Type": "text/plain"
		response.write "Yo dawg, I heard you liked paths so I put paths in your paths so you can traverse paths while you're traversing paths.\n"
		response.end()
		return
	
	if filename.slice(filename.lastIndexOf "/") is "/upload"
		console.log "Yay!"
		console.log request.files
		console.log "Done"
		#for a, b of request.files
		#	console.log a + ": " + b
		response.writeHead 200, "Content-Type": "text/plain"
		response.write "File successfully uploaded\n"
		response.end()
		message += "Moved file"
		console.log message
		return
	#else console.log "I got " + filename.slice(filename.lastIndexOf "/")
	
	(path.exists or fs.exists) filename, (exists) -> 
		if not exists
			response.writeHead 404, "Content-Type": "text/plain"
			response.write "404 Not Found\n"
			response.end()
			message += "404ed on a request for #{filename}\n"
			console.log message
			return
			
		message += "Serving up #{filename}\n"
		
		coffeekup = false
		if fs.statSync(filename).isDirectory() 
			filename += '/' if filename.charAt -1 isnt '/'
			if (path.existsSync or fs.existsSync) filename + 'index.js'
				filename += 'index.js'
				uri += 'index.js'
				coffeekup = true
			else
				filename += 'index.html'
				uri += 'index.html'

		fs.readFile filename, "binary", (err, file) ->
			contentType = mime.lookup filename
			if err
				message += "Encountered internal error: #{err}\n"
				console.log message
				response.writeHead 500, "Content-Type": "text/plain"
				response.write err + "\n"
				response.end()
				return
			
			if coffeekup
				template = require filename
				file = ck.render template, empty: '', hardcode: helpers
				contentType = "text/html"
				message += "Serving as a coffeekup file\n"
			message += "Using content type #{contentType}\n"
			#console.log message
			response.writeHead 200, "Content-Type": contentType
			response.write file, "binary"
			response.end()
server.listen parseInt port, 10
