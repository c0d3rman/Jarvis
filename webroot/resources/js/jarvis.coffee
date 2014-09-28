$(document).ready ->
	# define jarvis object for others to interact with
	jarvis =
		player: $("#myPlayer").get(0)
		# add a talk fuction to submit messages to terminal
		talk: (message, speaker = "Jarvis", spoken) ->
			$("#terminalContent").append speaker + ': ' + message + '<br><br>'
			message = message
				.replace(/\n|<br>|\\n/g, ', ')		# make newlines into pauses
				.replace(/<(?:.|\n)*?>/gm, '')		# remove HTML
				.replace(/[^A-Z0-9!.?, -]/ig, '')	# zap gremlins
			$(document).profanityFilter externalSwears: '/resources/lib/swearWords.json'
			if speaker == "Jarvis"
				if speechSynthesis?
					message = new SpeechSynthesisUtterance (spoken or message)
					message.voice = speechSynthesis.getVoices().filter((voice) -> voice.name == 'Google UK English Male')[0]
					message.lang = "en-GB"
					
					speechSynthesis.speak message
				else
					speak message, {pitch: 20}
		
		#socket-related
		socket: io.connect "https://localhost:29632", secure: true
		socketEmit: (event, data) ->
			if this.socket.connected
				this.socket.emit event, data
		
		process: (command) ->
			this.failGracefully ->
				$.ajax({
					url: "https://api.wit.ai/message"
					data:
						'v': '20140501' #May 1st 2014
						'q': command #encodeURIComponent(command)
						'access_token': "6BBRQXOFZ3PBUOEEZQYAJUXOHLUK3353"
					dataType: "jsonp"
					jsonp: "callback"
					method: "POST"
					timeout: 1000
				}).done((data) ->
					confidence = data.outcome.confidence
					if confidence > 0.6
						window.jarvis.understand data
					else
						window.jarvis.instinct command
				).fail((jqXHR, textStatus, errorThrown) ->
					console.log 'textStatus: ' + textStatus
					console.log 'errorThrown: ' + errorThrown
					console.log 'jqXHR: ' + jqXHR
					window.jarvis.instinct command
				)
				
		understand: (rawData) ->
			this.failGracefully ->
				#console.log rawData
				intent = rawData.outcome.intent
				data = rawData.outcome.entities
				(this.actions[intent] or this.actions._unknown)(this, data)
			
		instinct: (command) ->
			this.failGracefully ->
				[command, data...] = command.toLowerCase().split " "
				data = data.join " "
				player = this.player
				switch command
					when "hello", "hi"		then 	this.actions.hello this
					when "pause", "stop"		then 	this.actions.pause this
					when "unpause"			then 	this.actions.unpause this
					when "play"			then 	this.actions.play this, data
					when "say", "speak"		then 	this.actions.speak this, data
					when "clear"			then 	this.actions.clear this
					when "help", "?"		then	this.actions.help this
					else 					this.actions._unknown this
		
		actions:
			clear:		(self) ->
				self.talk "Clearing terminal"
				$("#terminalContent").text ""
			hello:		(self, data) ->
				greetings = ["Hello", "Hi", "Wazzap ma homie", "Hello sir", "Greetings"]
				self.talk greetings[Math.floor(Math.random() * greetings.length)]
			leave:		(self) ->
				#window.close()
				self.talk "Goodbye sir"
				ww = window.open window.location, '_self'
				ww.close()
			list:		(self, dataCatcher, callback) ->
				$.get("/resources/userMusic/", (data) ->
					data = (data[i] = element.slice(0, -4).replace /_/g, " " for element, i in data.split "\n").slice 0, -1
					if callback?
						callback data
						return
					else
						self.talk "I can play:<br>#{data.join "<br>"}"
				).fail ->
					self.talk "Connect to the internet to play music"
					
			pause:		(self, data) ->
				self.player.pause()
				self.talk "Pausing song"
			play:		(self, data) ->
				filename = data.song_name.value.replace new RegExp(' ', 'g'), "_" #uses RegExp object to avoid leading whitespace regex division bug (#607 in GitHub)
				$(self.player).attr "src", "/resources/userMusic/" + filename.toLowerCase() + ".mp3"
				self.player.play()
				self.talk "Playing " + data.song_name.value
			speak:		(self, data) ->
				self.talk data.message_body.value
			shuffle:	(self) ->
					self.actions.list self, {}, (data) ->
						#shuffle function from https://gist.github.com/ddgromit/859699
						shuffle = (a) ->
							i = a.length
							while --i > 0
								j = ~~(Math.random() * (i + 1))
								t = a[j]
								a[j] = a[i]
								a[i] = t
							a
						data = shuffle data
						self.actions.play self, {song_name: {value: data[0]}}
			search:		(self, data) ->
				engineHash =
					"google": "https://www.google.com/search?q="
					"wikipedia": "http://en.wikipedia.org/wiki/Special:Search?search="
					"wolfram alpha": "http://www.wolframalpha.com/input/?i="
				
				query = data.search_query || data.wikipedia_search_query || data.wolfram_search_query
				query = query.value
				engine = data.search_engine.value || "google"
				window.open engineHash[engine.toLowerCase()] + encodeURIComponent(query), "_self"
				
				self.talk "Searching #{engine} for #{query}"
			unpause:	(self, data) ->
				self.player.play()
				self.talk "Unpausing song"
			calculate:	(self, data) ->
				expression = data.math_expression.value
				self.talk "Calculating #{expression}"
				window.open "http://www.wolframalpha.com/input/?i=#{expression}", "_self"
			help:		(self) ->
				self.talk "You can say:<br>" + (name for name, action of self.actions when name.charAt(0) isnt '_').join "<br>"
			#client actions
			#volumeUp:	(self, data) ->
			#	self.talk "Increasing volume"
			#	self.socketEmit "volume up", data
			mute:	(self, data) ->
				self.talk "Muting volume"
				self.socketEmit "mute"
			unmute:	(self, data) ->
				self.talk "Unmuting volume"
				self.socketEmit "mute"
			#internal actions
			_unknown:	(self) ->
				self.talk "I didn't understand that.", "Jarvis", "I did ent understand that"
		failGracefully: (todo) ->
			try
				todo.apply this
			catch error
				this.talk "Error. See console for details"
				console.log "Jarvis error: " + error
			
	# export jarvis
	(exports ? window).jarvis = jarvis
	
	# greet user
	jarvis.talk "Hello sir"
