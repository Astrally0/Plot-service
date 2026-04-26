local Players = game:GetService("Players")
local Networker = require(script.Parent.networker)
local Sift = require(script.Parent.Sift)
local Signal = require(script.Parent.Signal)

local PlotServiceServer = {
	_template = nil :: Model?,
	_plots = {} :: {[Player]: PlotServer.PlotServer},
	_changedPlotsSignal = Signal.new() :: Signal.Signal<RBXScriptConnection>?,
	networker = nil :: Networker.Server
}

local ErrorToString = require(script.Parent.utils.ErrorToString)
local PlotServer = require(script.Parent.classes.PlotServer)

export type PlotServiceServer = typeof(PlotServiceServer) & {
	networker: Networker.Server
}

type options = {
	template: Model,
	exclude: {Player}?,
}

function PlotServiceServer.init(self: PlotServiceServer, options: options)
	self.networker = Networker.server.new("PlotService", self, {
		self.PivotToPlot,
		self.getChangedPlotsSignal
	})
	
	self._plots = {} :: {[Player]: PlotServer.PlotServer}
	self._template = options.template
	
	Players.PlayerAdded:Connect(function(player: Player)
		if options.exclude and table.find(options.exclude, player.Name) then
			warn(ErrorToString("Player detected in exclude list", "notification"))
			return 
		end
		
		self:PlayerAdded(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player: Player)
		self:PlayerRemoving(player)
	end)
end

function PlotServiceServer.PlayerAdded(self: PlotServiceServer, player: Player)
	local isAdded = Sift.Array.find(self._plots, player)
	
	if isAdded then
		return
	end
	
	self._plots[player] = PlotServer.new(player, self._template)
	self._changedPlotsSignal:Fire(player, self:getPlot(player))
	self.networker:fire(player, "PlayerAdded")
end

function PlotServiceServer.PlayerRemoving(self: PlotServiceServer, player: Player)
	local data = self._plots[player] :: PlotServer.PlotServer
	
	if data then
		data:Destroy()
	end
end

function PlotServiceServer.PivotToPlot(self: PlotServiceServer, player: Player, offset: Vector3?)
	assert(player ~= nil, ErrorToString("Player is not provided", "runtime"))
	
	local data = self._plots[player] :: PlotServer.PlotServer
	
	if not data then
		return
	end
	
	data:PivotToPlot(player, offset)
end

function PlotServiceServer.getPlot(self: PlotServiceServer, player: Player)
	assert(player ~= nil, ErrorToString("Player is not provided", "runtime"))
	
	local data = self._plots[player] :: PlotServer.PlotServer
	assert(data ~= nil, ErrorToString("Player has no plot", "runtime"))
	local plot = data:getPlot()
	
	return plot
end

function PlotServiceServer.getChangedPlotsSignal(self: PlotServiceServer)
	local signal = self._changedPlotsSignal
	assert(signal ~= nil, ErrorToString("signal is not valid", "runtime"))
	return signal
end

return PlotServiceServer
