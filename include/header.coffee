module.exports = (title) ->
	div '#headerDiv.resp', ->
		if title == 'JARVIS'
			a '#header', href: './', ->
				span '#jar', 'JAR'
				span '#u', 'V'
				span '#is', 'IS'
		else
			a '#header', href: './', title