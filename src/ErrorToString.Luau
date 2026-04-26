local function ErrorToString(context: string, error_type: string)
	local module = "PLOT-SERVICE"
	return `\n`..`[{module}-{string.upper(tostring(error_type))}]: {context}` .. `\n` .. ` TraceBack:` .. `\n` .. debug.traceback()
end

return ErrorToString
