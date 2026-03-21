local Plot = {}
Plot.__index = Plot

export type Plot = typeof(setmetatable(
	{} :: {
		plot: Model,
		owner: Player,
		plotData: {},
	},
	Plot
	)
)

type plotData = {
	plot: Model,
	loadCallback: (Player: Player, plot: Model) -> (),
	owner: Player,
	plotData: {},
}

function Plot.new(plotData: plotData)
	local self = setmetatable({}, Plot)
	
	self.loadCallback = plotData.loadCallback
	self.plot = plotData.plot
	self.owner = plotData.owner
	self.plotData = plotData.plotData
	
	if self.loadCallback then
		self.loadCallback(self.owner, self.plot)
	end
	
	return self
end

function Plot:Disconnect()
	self.plot:Destroy()
	self = nil
end

function Plot:setPlotData(data: {})
	self.plotData = data
	return self
end

return Plot
