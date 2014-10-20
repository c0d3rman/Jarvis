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
			previousEntries.splice 1, 0, $("#in").val()
			$("#in").val("")
			#filter()
	
	window.submitTerminal = submitTerminal
	
	#save and make accessible entries
	window.previousEntries = [""]
	window.currentEntry = 0
	# submit on enter anywhere in page (and save entries)
	$(document).keydown (event) ->
		if event.keyCode == 13
			window.submitTerminal()
		else if event.keyCode == 38 or event.keyCode == 40
			window.previousEntries[0] = $("#in").val()
			window.currentEntry += 39 - event.keyCode if 0 <= window.currentEntry + 39 - event.keyCode <= previousEntries.length # extra one at end for blank
			$("#in").val previousEntries[window.currentEntry]
		else if event.keyCode == 27
			annyang.stop()
			
	# keep #in focused
	$("#in").focus()
	$("#in").blur ->
		$(this).focus()