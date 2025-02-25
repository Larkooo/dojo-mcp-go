package main

import (
	"github.com/mark3labs/mcp-go/server"

	"dojo-mcp/tools" // Import your tools package
)

func main() {
	// Create MCP server
	s := server.NewMCPServer(
		"Dojo MCP",
		"0.0.1",
	)

	// Create tool registry
	registry := tools.NewRegistry()

	// Register all tools
	tools.RegisterDefaultTools(registry)

	// Add all tools to the server
	for _, tool := range registry.GetAll() {
		s.AddTool(*tool.Definition(), tool.Execute)
	}

	// Start the SSE server
	sse := server.NewSSEServer(s, "")
	if err := sse.Start("localhost:4040"); err != nil {
		println("fail: ", err.Error())
	}
}
