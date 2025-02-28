package tools

import (
	"context"
	"dojo-mcp/common"
	"fmt"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/rs/zerolog/log"
)

// PromptTool is a tool that uses prompt templates
type PromptTool struct {
	mcp.Tool
	promptName string
	renderer   common.PromptRenderer
}

func (t *PromptTool) Name() string {
	return t.Tool.Name
}

func (t *PromptTool) Description() string {
	return t.Tool.Description
}

func (t *PromptTool) Definition() mcp.Tool {
	return t.Tool
}

// NewPromptTool creates a new tool that uses a prompt template
func NewPromptTool(name, description, promptName string, renderer common.PromptRenderer) *PromptTool {
	// Get the prompt to extract its variables
	prompt, exists := renderer.GetPrompt(promptName)
	if !exists {
		log.Error().
			Str("component", "tools").
			Str("prompt", promptName).
			Msg("Prompt not found when creating tool")

		// Create a basic tool with just a prompt parameter
		return &PromptTool{
			Tool: mcp.NewTool(name,
				mcp.WithDescription(description),
			),
			promptName: promptName,
			renderer:   renderer,
		}
	}

	// Create a slice of tool options
	options := []mcp.ToolOption{
		mcp.WithDescription(description),
	}

	// Add a parameter for each variable in the prompt
	for _, varName := range prompt.Variables {
		options = append(options, mcp.WithString(varName,
			mcp.Required(),
			mcp.Description(fmt.Sprintf("Parameter %s for %s", varName, name)),
		))
	}

	// Create the tool with all options
	tool := mcp.NewTool(name, options...)

	return &PromptTool{
		Tool:       tool,
		promptName: promptName,
		renderer:   renderer,
	}
}

// Execute handles the prompt tool execution
func (t *PromptTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	// Convert all arguments to strings for the prompt renderer
	vars := make(map[string]string)
	for key, value := range request.Params.Arguments {
		if strValue, ok := value.(string); ok {
			vars[key] = strValue
		} else {
			vars[key] = fmt.Sprintf("%v", value)
		}
	}

	// Render the prompt using the registry
	fullPrompt, err := t.renderer.RenderPrompt(t.promptName, vars)
	if err != nil {
		log.Warn().
			Str("tool", t.Name()).
			Str("prompt", t.promptName).
			Str("component", "tools").
			Msgf("Failed rendering prompt: %v", err)
		return mcp.NewToolResultError(fmt.Sprintf("Failed to render prompt: %v", err)), nil
	}

	// Return the rendered prompt without the additional message about retrieving the resource
	// since resources are now embedded directly in the prompt
	return mcp.NewToolResultText(fullPrompt), nil
}
