package main

import (
	"os"

	"github.com/mark3labs/mcp-go/server"
	"github.com/rs/zerolog/log"

	"dojo-mcp/core"
	"dojo-mcp/logger"
)

func main() {
	// Configure logging
	logger.Configure()

	log.Info().
		Str("component", "main").
		Msg("Starting Dojo MCP server")

	// Create MCP server
	s := server.NewMCPServer(
		"Dojo MCP",
		"0.0.1",
	)

	// Create registry
	registry := core.NewRegistry()

	// Register all tools
	core.RegisterDefaultTools(registry)
	log.Info().
		Str("component", "core").
		Msg("Registered default tools")

	// Load resources from static/insights directory
	if err := registry.LoadResources(); err != nil {
		log.Warn().
			Str("component", "resources").
			Err(err).
			Msg("Failed to load resources")
	} else {
		log.Info().
			Str("component", "resources").
			Int("count", len(registry.GetAllResources())).
			Msg("Successfully loaded resources")
	}

	// Add all tools to the server
	for _, tool := range registry.GetAllTools() {
		s.AddTool(*tool.Definition(), tool.Execute)
		log.Debug().
			Str("component", "server").
			Str("tool", tool.Name()).
			Msg("Added tool to server")
	}

	log.Info().
		Str("component", "server").
		Str("address", "localhost:4040").
		Msg("Starting SSE server")

	// Start the SSE server
	sse := server.NewSSEServer(s, "")
	if err := sse.Start("localhost:4040"); err != nil {
		log.Error().
			Str("component", "server").
			Err(err).
			Msg("Failed to start SSE server")
		os.Exit(1)
	}
}
