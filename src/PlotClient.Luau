local PlotClient = {}
PlotClient.__index = PlotClient

local Players = game:GetService("Players")

export type PlotClient = typeof(setmetatable(
	{} :: {
		plot: Model
	},
	PlotClient
	)
)

function PlotClient.new()
	local self = setmetatable({}, PlotClient)
	
	self.owner = Players.LocalPlayer
	self.plot = workspace:FindFirstChild(`{self.owner.UserId}`)
	
	return self
end

function PlotClient.getPlot(self: PlotClient)
	return self.plot
end

function PlotClient.getPlotCFrame(self: PlotClient)
	return self.plot:GetPivot()
end

function PlotClient.Destroy(self: PlotClient)
	self.plot = nil
	self.owner = nil
	self = nil
end

return PlotClient
