class JarvisTime
	constructor: (time) ->
		if typeof time is "string"
			throw "Invalid time #{time}" unless time.match /^\d{1,2}:\d{1,2}$/
			[@hours, @minutes] = (Number(t) for t in time.split ":")
			throw "Out of range time #{time}" unless 0 <= @hours < 24 and 0 <= @minutes < 60
		else if typeof time is "number" and time % 1 is 0
			throw "Out of range time #{time}" unless 0 <= time < 1440
			@hours = Math.floor(time / 60)
			@minutes = time % 60
		else
			throw "Unknown input type (#{typeof time}) for input #{time}"
	
	toString: () ->
		"#{@hours}:" + (if @minutes < 10 then "0#{@minutes}" else "#{@minutes}")
	valueOf: () ->
		@hours * 60 + @minutes

window.scheduleUtils =
	minuteByMinute: (timeRange) ->
		unless timeRange.match /^\d{1,2}:\d{2}-\d{1,2}:\d{2}$/
			throw Error("Bad input to minuteByMinute: #{timeRange}")
	
		[startTime, endTime] = (new JarvisTime(time) for time in timeRange.split "-")
		unless startTime < endTime
			throw Error("Start time after end time in minuteByMinute: #{timeRange}")
	
		output = []
		for time in [startTime + 0..endTime - 1]
			time = new JarvisTime time
			output.push time.toString()
		output
	
	parseSchedule: (data) ->
		output = []
		classes = data.names
		for day in data.schedule
			today = {}
			for timeRange, classCode of day
				for time in this.minuteByMinute timeRange
					today[time] = classes[classCode]
			output.push today
		output
	
	scheduleRaw: ( ->
		tempObj = null
		jQuery.ajax url: '/resources/data/blockSchedule.json', async: no, dataType: "json", success: (json) ->
			tempObj = json
		tempObj
	)()

	getClassFromTime: (schedule, day, time) ->
		schedule[day][time]

	getCurrentTime: ->
		now = new Date()
		return [now.getDay(), new JarvisTime "#{now.getHours()}:#{now.getMinutes()}"]
	
	getCurrentClass: ->
		this.getClassFromTime this.schedule, this.getCurrentTime()...

window.scheduleUtils.schedule = window.scheduleUtils.parseSchedule window.scheduleUtils.scheduleRaw