local Server = require(script.PlotServiceServer)
local Client = require(script.PlotServiceClient)

export type server = Server.PlotServiceServer
export type client = Client.PlotServiceClient

return {
	server = Server,
	client = Client,
}
