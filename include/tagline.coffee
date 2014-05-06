module.exports = (tagline) ->
	h1 '#tagline.resp', ->
		span '.fa.fa-angle-right', @empty
		text " #{tagline}"