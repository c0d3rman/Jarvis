$(document).ready ->
	$("#settingCog").hover ->
		$("#settingBar").slideDown()
		#$("#settings").animate left: if $("#settings").css('left') is 0 then $("#setting").outerWidth() * -1 else 0
	, ->
		$("#settingBar").slideUp()
