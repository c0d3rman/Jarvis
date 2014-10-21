$(document).ready ->
	# define jarvis object for others to interact with
	jarvis =
		player: $("#myPlayer").get(0)
		swearWords: ( ->
			tempObj = null
			jQuery.ajax url: '/resources/data/swearWords.json', async: no, dataType: "json", success: (json) ->
				tempObj = json
			tempObj
		)()
		# add a talk fuction to submit messages to terminal
		talk: (message, speaker = "Jarvis", spoken) ->
			$("#terminalContent").append speaker + ': ' + message + '<br><br>'
			message = message
				.replace(/\n|<br>|\\n/g, ', ')		# make newlines into pauses
				.replace(/<(?:.|\n)*?>/gm, '')		# remove HTML
				.replace(/[^A-Z0-9!.?, -]/ig, '')	# zap gremlins
			$(document).profanityFilter customSwears: this.swearWords
			if speaker == "Jarvis"
				if speechSynthesis?
					message = new SpeechSynthesisUtterance (spoken or message)
					message.voice = speechSynthesis.getVoices().filter((voice) -> voice.name == 'Google UK English Male')[0]
					message.lang = "en-GB"
					
					speechSynthesis.speak message
				else
					speak message, {pitch: 20}
		
		process: (command) ->
			this.failGracefully ->
				$.ajax({
					url: "https://api.wit.ai/message"
					data:
						'v': '20140501' #May 1st 2014
						'q': command #encodeURIComponent(command)
						'access_token': "HFJ5Y3XFVSEXQICMCUPICOJKO6IIBECQ"
					dataType: "jsonp"
					jsonp: "callback"
					method: "POST"
					timeout: 1000
				}).done((data) ->
					confidence = data.outcome.confidence
					if confidence > 0.6
						window.jarvis.understand data
					else
						window.jarvis.actions._unknown()
				).fail((jqXHR, textStatus, errorThrown) ->
					console.log 'textStatus: ' + textStatus
					console.log 'errorThrown: ' + errorThrown
					console.log 'jqXHR: ' + jqXHR
					if navigator.onLine
						throw errorThrown
					else
						window.jarvis.talk "I can't connect to the internet", "Jarvis", "I cant connect to the internet"
				)
				
		understand: (rawData) ->
			this.failGracefully ->
				intent = rawData.outcome.intent
				data = rawData.outcome.entities
				(this.actions[intent] or this.actions._unknown)(this, data)
		
		actions:
			hello:		(self, data) ->
				greetings = ["Hello", "Hi", "Wazzap ma homie", "Hello sir", "Greetings"]
				self.talk greetings[Math.floor(Math.random() * greetings.length)]
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
				filename = data.song_name.value.replace(new RegExp(' ', 'g'), "_").toLowerCase() + ".mp3" #uses RegExp object to avoid leading whitespace regex division bug (#607 in GitHub)
				filepath = "/resources/userMusic/#{filename}"
				$.get(filepath)
					.done( ->
						$(self.player).attr "src", filepath
						self.player.play()
						self.talk "Playing " + data.song_name.value
					).fail ->
						self.player.pause()
						self.talk "I don't have the song " + data.song_name.value
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
				window.open "http://www.wolframalpha.com/input/?i=#{encodeURIComponent expression}", "_self"
			help:		(self) ->
				self.talk "You can say:<br>" + (name for name, action of self.actions when name.charAt(0) isnt '_').join "<br>"
			class_now:	(self) ->
				#className = window.scheduleUtils.getClassFromTime window.scheduleUtils.schedule, data.datetime[0].value.from
				className = window.scheduleUtils.getCurrentClass()
				if className?
					self.talk "You have #{className} right now"
				else
					self.talk "You don't have a class right now"
			class_next:	(self, data) ->
				[day, time] = window.scheduleUtils.getCurrentTime()
				scheduleRawPart = window.scheduleUtils.scheduleRaw.schedule[day]
				sortedKeys = Object.keys(scheduleRawPart).sort (a, b) ->
					a = (new JarvisTimeRange a).startTime
					b = (new JarvisTimeRange b).startTime
					if a < b
						-1
					else if a > b
						1
					else
						0
				if time < (new JarvisTimeRange sortedKeys[0]).startTime
					nextClass = window.scheduleUtils.scheduleRaw.names[scheduleRawPart[sortedKeys[0]]]
				else
					for key, i in sortedKeys
						if (new JarvisTimeRange key).contains time
							if scheduleRawPart[sortedKeys[i+1]] isnt 0
								nextClass = window.scheduleUtils.scheduleRaw.names[scheduleRawPart[sortedKeys[i+1]]]
							else
								nextClass = window.scheduleUtils.scheduleRaw.names[scheduleRawPart[sortedKeys[i+2]]]
							break
				if nextClass?
					self.talk "You have #{nextClass} next"
				else if window.scheduleUtils.getCurrentClass()?
					self.talk "This is your last class of the day"
				else
					self.talk "The day is over!"
			#internal actions
			_unknown:	(self) ->
				self.talk "I didn't understand that.", "Jarvis", "I did ent understand that"
			_disconnected: (self) ->
				self.talk "I can't connect to the internet"
		failGracefully: (todo) ->
			try
				todo.apply this
			catch error
				this.talk "Error. See console for details"
				console.log "Jarvis error: #{error.stack or error}"
			
	# export jarvis
	(exports ? window).jarvis = jarvis
	
	# greet user
	jarvis.talk "Hello sir"