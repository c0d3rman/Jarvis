module.exports = (requireHeads, message) ->
	form '.dropzone.resp', action: './upload', enctype: 'multipart/form-data', id: 'dropzone', ->
		span '.dz-message.resp', message
		br()
		span '.fa.fa-cloud-upload.resp', @empty
		br()
		div '.fallback', ->
			input name: 'file', type: 'file', multiple: 'multiple'
	span '#pulldown.fa.fa-angle-double-down', @empty
	
	requireHeads.push ->
		require './css/_dropzoneFormat.css'