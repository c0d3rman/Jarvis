$(document).ready ->
	words = ["hello", "world", "test", "fun", "toodles"]

	message = prompt "Message:"

	codebook = {}

	for word in message.split /\b/
		unless /\W/.test word
			codebook[word] ?= words[Math.floor Math.random() * words.length]
			message.replace new RegExp("(\\b)#{word}(\\b)", "g"), "$1#{codebook[word]}$2"

	print = (text) -> $(document.createElement "p").text(text).appendTo document.body

	print message

	print "Codebook:"
	print "\"#{value}\" means \"#{key}\"" for key, value of codebook
