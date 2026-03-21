local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return nil
end

local GetPlot = script.Parent.remotes.getPlot
local GetData = script.Parent.remotes.getData
local SetData = script.Parent.remotes.setData

type Plot = {
	plot: Model,
	owner: Player,
	plotData: { [any]: any },
}

local PlotServiceClient = {}

export type PlotServiceClient = typeof(PlotServiceClient) & {}

function PlotServiceClient.init(data: {}?)
	local self = PlotServiceClient :: PlotServiceClient
	
	if data then
		self.setData(self, data)
	end
end

function PlotServiceClient.getPlot(self: PlotServiceClient): Plot?
	return GetPlot:InvokeServer()
end

function PlotServiceClient.getData(
	self: PlotServiceClient,
	path: { string } | string 
): any
	return GetData:InvokeServer()
end

function PlotServiceClient.setData(
	self: PlotServiceClient,
	value: any
): any
	return SetData:FireServer(value)
end

return PlotServiceClient
