global.ectwo_log = {}

if process.env.ECTWO_LOGGING
	global.ectwo_log = console
else
	["log", "warn", "error", "notice"].forEach (method) ->
		global.ectwo_log[method] = (()->)