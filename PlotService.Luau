local PlotServiceServer = require(script.PlotServiceServer)
local PlotServiceClient = require(script.PlotServiceClient)

export type server = PlotServiceServer.PlotServiceServer
export type client = PlotServiceClient.PlotServiceClient

return {
	server = PlotServiceServer :: server,
	client = PlotServiceClient :: client,
}