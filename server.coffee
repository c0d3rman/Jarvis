coffeecup = require 'coffeecup'
coffeemiddleware = require 'coffee-middleware'
express = require 'express'
morgan = require 'morgan'
servestatic = require 'serve-static'
fs = require 'fs'
path = require 'path'
http = require 'http'
https = require 'https'
busboy = require 'connect-busboy'
edt = require 'express-directory-traversal'
cluster = require 'cluster'
os = require 'os'


numCPUs = os.cpus().length

if cluster.isMaster
	console.log "Jarvis initialized"
	for i in [1..numCPUs]
		cluster.fork() 
		console.log "Process #{i} started"
	cluster.on "exit", (worker, code, signal) -> cluster.fork()
else
	`
	var compile = function (fmt) {
		fmt = fmt.replace(/"/g, '\\"');
		var js = '  return "' + fmt.replace(/:([-\w]{2,})(?:\[([^\]]+)\])?/g, function(_, name, arg){
		        return '"\n    + (tokens["' + name + '"](req, res, "' + arg + '") || "-") + "';
		}) + '";'
		return new Function('tokens, req, res', js);
	};
	`

	morgan.format 'dev++', (tokens, req, res) ->
		color = 32
		status = res.statusCode
	
		if status >= 500 then color = 31
		else if status >= 400 then color = 33
		else if status >= 300 then color = 36
	
		fn = compile "\x1b[90m:remote-addr \x1b[32m:method \x1b[35m:url \x1b[" + color + "m:status \x1b[97m:response-time ms\x1b[0m"
	
		fn tokens, req, res


	app = express()

	app.set 'views', "#{__dirname}/webroot"
	app.set 'view engine', 'coffee'
	app.engine 'coffee', coffeecup.__express

	app.use morgan stream: {write: (str) -> fs.appendFileSync "#{__dirname}/log/long.log", str}
	app.use morgan format: "dev++", stream: {write: (str) -> fs.appendFileSync "#{__dirname}/log/short.log", str}
	app.use edt "Yo dawg, I heard you liked paths so I put paths in your paths so you can traverse paths while you're traversing paths.\n"
	app.use coffeemiddleware src: "#{__dirname}/webroot"
	app.use busboy limits: {fileSize: 20 * 1024 * 1024}
	app.use servestatic "#{__dirname}/webroot"
	
	app.get '/', (req, res) ->
		res.render 'index', empty: ''
	app.get '/resources/userMusic', (req, res) ->
		fs.readdir "#{__dirname}/webroot/resources/userMusic", (err, files) ->
			if err
				res.writeHead 500, "Content-Type": "text/plain"
				res.write "Internal error fetching music list"
				res.end()
				console.log err.message
			else
				res.writeHead 200, "Content-Type": "text/plain"
				res.write "#{file}\n" for file in files
				res.end()
	app.get '*', (req, res) ->
		relpath = "#{req.url.substr(1)}index"
		filepath = "#{__dirname}/webroot#{req.url}index.coffee"
		if filepath isnt path.join '/', filepath
			res.writeHead 403, "Content-Type": "text/plain"
			res.write "The directory traversal is strong in this one."
			res.end()
		else
			fs.exists filepath, (fileExists) ->
				if fileExists
					res.render relpath, empty: ''
				else
					res.status 404
					if req.accepts 'html'
						res.render '404', empty: ''
					else
						res.write '404 not found'
						res.end()

	#from http://www.benjiegillam.com/2012/06/node-dot-js-ssl-certificate-chain/
	ca = []
	chain = fs.readFileSync "#{__dirname}/certs/chain/ca-certs.crt", 'utf8'
	chain = chain.split "\n"
	cert = []
	for line in chain when line.length isnt 0
		cert.push line
		if line.match /-END CERTIFICATE-/
			ca.push cert.join "\n"
			cert = []
	
	options =
		ca: ca
		key: fs.readFileSync "#{__dirname}/certs/server.key"
		cert: fs.readFileSync "#{__dirname}/certs/server.crt"

	wwwdata = -> process.setuid "www-data"
	localhost = "0.0.0.0"

	httpServer = http.createServer (req, res) ->
		res.writeHead 301, "Content-Type": "text/plain", "Location": "https://#{req.headers.host + req.url}"
		res.end()
	httpsServer = https.createServer options, app
	httpServer.listen 8000, localhost, wwwdata
	httpsServer.listen 8080, localhost, wwwdata