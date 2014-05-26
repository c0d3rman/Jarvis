module.exports = ->
	span id: "settingCog", class: "fa fa-cog"
	div id: "settingBar", ->
		div id: "settings", ->
			div class: "setting", ->
				p "Name"
				input type: "text", id: "jarvisName", value: "Jarvis"
	#script src: "/resources/js/settings.js"
