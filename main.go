package main

import (
	"context"
	"fmt"
	"os"

	"github.com/mark3labs/mcp-go/mcp"
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

	// Create MCP server with prompt capabilities enabled
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

	// Load prompts from static/prompts directory
	if err := registry.LoadPrompts(); err != nil {
		log.Warn().
			Str("component", "prompts").
			Err(err).
			Msg("Failed to load prompts")
	} else {
		log.Info().
			Str("component", "prompts").
			Int("count", len(registry.GetAllPrompts())).
			Msg("Successfully loaded prompts")
	}

	// Add all tools to the server
	for _, tool := range registry.GetAllTools() {
		s.AddTool(tool.Definition(), tool.Execute)
		log.Debug().
			Str("component", "server").
			Str("tool", tool.Name()).
			Msg("Added tool to server")
	}

	// Add all prompts to the server using the native prompt functionality
	for name, prompt := range registry.GetAllPrompts() {
		// Convert our prompt format to MCP prompt format
		mcpPromptArgs := make([]mcp.PromptArgument, 0, len(prompt.Variables))
		for _, varName := range prompt.Variables {
			mcpPromptArgs = append(mcpPromptArgs, mcp.PromptArgument{
				Name:        varName,
				Description: fmt.Sprintf("Variable %s for prompt %s", varName, name),
				Required:    true,
			})
		}

		mcpPrompt := mcp.Prompt{
			Name:        name,
			Description: prompt.Description,
			Arguments:   mcpPromptArgs,
		}

		// Add the prompt to the MCP server
		s.AddPrompt(mcpPrompt, func(ctx context.Context, request mcp.GetPromptRequest) (*mcp.GetPromptResult, error) {
			return registry.GetPromptResult(name, request)
		})

		log.Info().
			Str("component", "server").
			Str("prompt", name).
			Msg("Added prompt to MCP server")
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
