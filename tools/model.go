package tools

import (
	"context"
	"fmt"
	"os"

	"github.com/mark3labs/mcp-go/mcp"
)

// ModelTool implements functionality to generate Dojo model prompts
type ModelTool struct {
	name        string
	description string
	definition  *mcp.Tool
}

// NewModelTool creates a new Dojo model tool
func NewModelTool() *ModelTool {
	tool := &ModelTool{
		name:        "dojo_model",
		description: "Generate a prompt for creating Dojo models in Cairo with comprehensive documentation",
	}

	// Create MCP tool definition
	definition := mcp.NewTool(tool.Name(),
		mcp.WithDescription(tool.Description()),
		mcp.WithString("prompt",
			mcp.Required(),
			mcp.Description("Your specific request about Dojo models (e.g., 'Create a Position model with x,y coordinates')"),
		),
	)

	tool.definition = &definition
	return tool
}

// Name returns the tool's name
func (t *ModelTool) Name() string {
	return t.name
}

// Description returns the tool's description
func (t *ModelTool) Description() string {
	return t.description
}

// Definition returns the MCP tool definition
func (t *ModelTool) Definition() *mcp.Tool {
	return t.definition
}

// Execute handles the Dojo model tool execution
func (t *ModelTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	userPrompt, ok := request.Params.Arguments["prompt"].(string)
	if !ok {
		return mcp.NewToolResultError("prompt must be a string"), nil
	}

	// Read the model documentation from the insights file
	modelDocs, err := os.ReadFile("static/insights/model.txt")
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("Failed to read model documentation: %v", err)), nil
	}

	// Combine the user's specific prompt with our comprehensive model documentation
	fullPrompt := fmt.Sprintf("Using the Dojo model documentation below, please help with the following request:\n\n%s\n\n--- DOJO MODEL DOCUMENTATION ---\n\n%s", userPrompt, string(modelDocs))

	return mcp.NewToolResultText(fullPrompt), nil
}
