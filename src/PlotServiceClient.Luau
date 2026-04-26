local Networker = require(script.Parent.networker)

local PlotClient = require(script.Parent.classes.PlotClient)

local PlotServiceClient = {
	_plot = nil :: PlotClient.PlotClient
}

export type PlotServiceClient = typeof(PlotServiceClient) & {
	networker: Networker.Client
}

function PlotServiceClient.init(self: PlotServiceClient)
	self.networker = Networker.client.new("PlotService", self)
end

function PlotServiceClient.PlayerAdded(self: PlotServiceClient)
	self._plot = PlotClient.new()
end

function PlotServiceClient.PlayerRemoving(self: PlotServiceClient)
	self._plot:Destroy()
end

function PlotServiceClient.getPlot(self: PlotServiceClient): Model?
	return self._plot:getPlot()
end

function PlotServiceClient.PivotToPlot(self: PlotServiceClient, offset: Vector3?)
	self.networker:fire("PivotToPlot", offset)
end

return PlotServiceClient
