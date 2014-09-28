requireHeads = []
doctype 5
html ->
	head ->
		headFunction() for headfunction in requireHeads
		title 'Jarvis'

		meta 'http-equiv': 'Content-Type', content: 'text/html; charset=UTF-8'
		meta name: 'description', content: 'A digital personal assistant that accepts voice commands.'
		meta name: 'keywords', content: 'jarvis,personal assistant,assistant,voice command,jarvis personal assistant'
		#meta property: 'og:image', content: 'INSERT_IMAGE_LINK'
		meta property: 'og:title', content: 'Jarvis Personal Assistant'
		meta property: 'og:type', content: 'website'
		meta property: 'og:site_name', content: 'Jarvis Personal Assistant'
		meta property: 'og:description', content: 'Jarvis is a digital personal assistant that accepts voice commands. He can play music, calculate mathematical expressions, speak, search, and more! BETA'
		meta property: 'og:url', content: 'https://javispa.info/'

		link href: '/resources/lib/font-awesome.min.css', rel: 'stylesheet'
		link href: '/resources/lib/dropzone.css', rel: 'stylesheet'
		link href: '/resources/css/main.css', rel: 'stylesheet'
		link href: '/resources/css/settings.css', rel: 'stylesheet'
		link href: '/resources/images/favicon.png', rel: 'icon', type: 'image/png'
		
		script src: '/resources/lib/dropzone.js'
		script src: '/resources/lib/jquery.min.js'
		script src: '/resources/lib/annyang.js'
		script src: '/resources/lib/profanity.js'
		script src: '/resources/lib/socket.io.js'

		script src: '/resources/js/jarvis.js'
		script src: '/resources/js/script.js'
		script src: '/resources/js/speech.js'
	body ->
		_header 'JARVIS'
		_tagline 'Your smart personal assistant'
		_settings()
		div '#content', ->
			_dropzone requireHeads, 'Drag or click to Upload Music'
			br()
			div '#terminal', ->
				p '#terminalContent', @empty
				span '#inWrapper', ->
					text 'You: '
					input '#in', name: 'in', type: 'text'
		audio '#myPlayer', @empty
		div '#audio', @empty
		_footer()
