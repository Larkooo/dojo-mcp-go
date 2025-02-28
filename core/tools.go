package core

import (
	"dojo-mcp/tools"

	"github.com/rs/zerolog/log"
)

// RegisterDefaultTools registers all default tools with the registry
func RegisterDefaultTools(registry *Registry) {
	// Register all prompts as tools
	registerPromptTools(registry)
}

// registerPromptTools creates tools from all loaded prompts
func registerPromptTools(registry *Registry) {
	// First load the prompts
	if err := registry.LoadPrompts(); err != nil {
		log.Warn().
			Str("component", "tools").
			Err(err).
			Msg("Failed to load prompts")
		return
	}

	log.Info().
		Str("component", "tools").
		Int("count", len(registry.GetAllPrompts())).
		Msg("Loaded prompts with resource embedding capability")

	// Then create a tool for each prompt
	for name, prompt := range registry.GetAllPrompts() {
		// Create a tool for this prompt
		tool := tools.NewPromptTool(
			name,
			prompt.Description,
			name,
			registry,
		)

		// Register the tool
		registry.Register(tool)

		log.Debug().
			Str("component", "tools").
			Str("prompt", name).
			Msg("Created tool from prompt")
	}
}
