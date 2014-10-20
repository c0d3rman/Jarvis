$(document).ready ->
	#---------------------------
	#	Footer Alignment
	#---------------------------
	#$(document.body).resize ->
	#	console.log "height: " + $(document.body).height()
	#	$("footer").css "top",  $(document.body).height()
	
	#---------------------------
	#	Terminal Customization
	#--------------------------- 
	# add a method to submit the terminal
	submitTerminal = ->
		if $("#in").val() isnt ""
			window.jarvis.talk $("#in").val(), "You"
			window.jarvis.process $("#in").val()
			$("#in").val("")
	
	window.submitTerminal = submitTerminal
	
	# submit on enter anywhere in page (and save entries)
	$(document).keydown (event) ->
		if event.keyCode == 13
			window.submitTerminal()
		else if event.keyCode == 27
			annyang.stop()
			
	# keep #in focused
	$("#in").focus()
	$("#in").blur ->
		$(this).focus()