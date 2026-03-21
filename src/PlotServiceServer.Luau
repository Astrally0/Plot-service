--[[
MIT License

Copyright PlotService© 2026 by Astrally0
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local GetPlot = script.Parent.remotes.getPlot
local GetData = script.Parent.remotes.getData
local SetData = script.Parent.remotes.setData

local Plot = require(script.Parent.Plot)

if RunService:IsClient() then
	return nil
end

type PlotOptions = {
	plot: Model,
	plotNodes: { [number]: Instance },
}

type Plot = {
	plot: Model,
	signal: Plot.Plot,
	owner: Player,
	plotData: { [any]: any },
}

local PlotServiceServer = {
	_playerRemoveCallback = nil,
	_loadCallback = nil,
	_plots = {} :: { [Player]: Plot },
	options = {} :: PlotOptions
}

export type PlotServiceServer = typeof(PlotServiceServer) & {}

function PlotServiceServer.init(options: PlotOptions)
	local self = PlotServiceServer :: PlotServiceServer
	
	GetPlot.OnServerInvoke = function(__player: Player)
		return PlotServiceServer:getPlot(__player)
	end
	
	GetData.OnServerInvoke = function(__player: Player, path: { string } | string )
		return PlotServiceServer:getData(__player, path)
	end
	
	SetData.OnServerEvent:Connect(function(__player: Player, value: any)
		PlotServiceServer:setData(__player, value)
	end)
	
	local plots = Instance.new("Folder", workspace)	plots.Name = "Plots"
	
	for _, node in options.plotNodes do
		if node == nil then
			error("[ERROR]: plot nodes not provided!!!")
		else
			continue
		end
	end
	
	assert(RunService:IsServer(), "[ERROR]: PlotService can only be initialized on the server")
	assert(options.plot ~= nil, "[ERROR]: plot model Not provided!!!")
	
	self.options = {
		plot = options.plot,
		plotNodes = options.plotNodes,
	}
	
	task.spawn(function()
		local Nodes = self.options.plotNodes :: { [number]: Instance }
		
		for _, Node in Nodes do
            Node:SetAttribute("owned", false)
		end
		
		Players.PlayerAdded:Connect(function(_player: Player)
			self.onPlayerInit(self, _player)
		end)
		
		Players.PlayerRemoving:Connect(function(_player: Player, reason: Enum.PlayerExitReason)
			local plotData = self._plots[_player]
			assert(plotData ~= nil, "[ERROR]: Player has no plot data")

			-- TODO: destroy plot
			if plotData["signal"] ~= nil then
				plotData.signal:Disconnect()
			else
				warn("[WARNING]: Player has no signal suported!!!")
			end
			
			self._plots[_player] = nil
			
			if self._playerRemoveCallback ~= nil then
				self._playerRemoveCallback(_player)
			end
		end)
	end)
	
	return self
end

function PlotServiceServer.getPlot(self: PlotServiceServer, _player: Player): Plot?
	assert(_player ~= nil, "[ERROR]: Player is not valid")
	local plotData = self._plots[_player]
	assert(plotData ~= nil, "[ERROR]: Player has no plot data")
	return plotData
end

function PlotServiceServer.setPlotLoadCallback(self: PlotServiceServer, callback: (player: Player, plot: Model) -> ())
	assert(callback ~= nil, "[ERROR]: Callback is not valid")
	self._loadCallback = callback
	return self
end

function PlotServiceServer.getData(
	self: PlotServiceServer,
	_player: Player,
	path: { string } | string 
): any
	
	local __data = self._plots[_player]
	assert(__data ~= nil, "[ERROR]: Player has no plot data")
	local value = __data.plotData
	
	if type(path) == "string" then
		local newValue = value[path]
		
		if newValue then
			return newValue
		else
			error("[ERROR]: "..path.." not found in data")
		end
	elseif type(path) == "table" then
		for _, key in path do
			local newValue = value[key]

			if newValue then
				value = newValue
			else
				error("[ERROR]: "..key.." not found in data")
			end
		end
	else
		return value
	end
end

function PlotServiceServer:setData(_player: Player, data: any)
	assert(_player ~= nil, "[ERROR]: Player is not valid")
	local __data = self._plots[_player]
	assert(__data ~= nil, "[ERROR]: Player has no plot data")
	table.insert(__data.plotData, data)
	return self
end

function PlotServiceServer.setPlayerRemoveCallback(self: PlotServiceServer, callback: (player: Player) -> ())
	self._playerRemoveCallback = callback
end

function PlotServiceServer.onPlayerInit(self: PlotServiceServer, _player: Player)
	assert(self.options.plot ~= nil, "[ERROR]: No plot model provided")
	assert(self._plots[_player] == nil, "[ERROR]: Player already has a plot")
	local Nodes = self.options.plotNodes :: { [number]: Instance }
	local Node = function(): Part
		for _, Node in Nodes do
			local owned = Node:GetAttribute("owned")
			if owned == false then	return Node	else	continue	end
		end
	end
	local plot = self.options.plot:Clone()
	local node = Node()
	if node == nil then
		_player:Kick("Max plots reached!")
		return nil
	end
	plot.Parent = workspace:FindFirstChild("Plots") or workspace
	plot.Name = _player.UserId.."_Plot"
	plot:PivotTo(node:GetPivot())
	local plotData = {
		plot = plot,
		
		signal = nil,
		
		owner = _player,
		plotData = {},
	}
	
	self._plots[_player] = plotData
	
	task.wait(1)
	
	self._plots[_player].signal = Plot.new({
		plot = plot,
		owner = _player,
		loadCallback = self._loadCallback,
		plotData = {},
	})
end

return PlotServiceServer
