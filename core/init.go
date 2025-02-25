package core

import (
	"github.com/rs/zerolog/log"

	"dojo-mcp/tools"
)

// RegisterDefaultTools registers all default tools in the registry
func RegisterDefaultTools(registry *Registry) {
	// Register hello world tool
	registry.Register(tools.NewHelloWorldTool())
	log.Debug().
		Str("component", "core").
		Str("tool", "hello_world").
		Msg("Registered hello world tool")

	// Register other tools as needed
	// registry.Register(tools.NewCalculatorTool())
	// registry.Register(tools.NewWeatherTool())
	// etc.
}
