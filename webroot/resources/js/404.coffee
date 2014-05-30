window.onload = ->
	if speechSynthesis?
		window.speechSynthesis.onvoiceschanged = ->
			messages = ["4O4 not found", "Your life amounts to nothing... A zero sum!", "This isn't the page you're looking for", "I'm afraid I cannot show you that Dave"]
			
			`
			//+ Jonas Raoni Soares Silva
			//@ http://jsfromhell.com/array/shuffle [v1.0]
			function shuffle(o){ //v1.0
				for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
				return o;
			}
			`

			messages = shuffle messages
			
			for m, i in messages
				m = new SpeechSynthesisUtterance m
				m.voice = speechSynthesis.getVoices().filter((voice) -> voice.name == 'Zarvox')[0]
				m.lang = "en-US"
				#m.onend = (event) ->
				#	setTimeout sayRandom, 1500
				messages[i] = m
			
			sayStuff = ->
				speechSynthesis.speak messages[i++ % messages.length]

			setInterval sayStuff, 4000
			
			window.messages = messages
