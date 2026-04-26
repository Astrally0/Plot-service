local PlotServer = {}
PlotServer.__index = PlotServer

local ErrorToString = require(script.Parent.Parent.utils.ErrorToString)

export type PlotServer = typeof(setmetatable(
	{} :: {
		owner: Player,
		plot: Model,
	},
	PlotServer
	)
)

function PlotServer.new(player: Player, plot: Model?)
	assert(plot ~= nil, ErrorToString("Plot template is not provided", "runtime"))
	assert(player ~= nil, ErrorToString("Player is not provided", "runtime"))
	
	local self = setmetatable({}, PlotServer)
	
	self.owner = player
	self.plot = plot:Clone()
	
	self.plot.Parent = workspace
	self.plot.Name = player.UserId
	
	return self
end

function PlotServer.getPlot(self: PlotServer)
	return self.plot
end

function PlotServer.PivotToPlot(self: PlotServer, player: Player, offset: Vector3?)
	assert(player ~= nil, ErrorToString("Player is not provided", "runtime"))
	
	local plot = self.plot :: Model
	local character = player.Character :: Model
	
	local plotCFrame = plot:GetPivot()

	local offset = offset or Vector3.new(0, 5, 0)
	
	character:PivotTo(plotCFrame + offset)
end

function PlotServer.Destroy(self: PlotServer)
	self.plot:Destroy()
	self.plot = nil
	self.owner = nil
	self = nil
end

return PlotServer
