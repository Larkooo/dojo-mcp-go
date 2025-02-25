package tools

import (
	"context"
	"fmt"
	"os"

	"github.com/mark3labs/mcp-go/mcp"
)

// CodeTool implements functionality to generate Dojo systems and code
type CodeTool struct {
	name        string
	description string
	definition  *mcp.Tool
}

// NewCodeTool creates a new Dojo code generation tool
func NewCodeTool() *CodeTool {
	tool := &CodeTool{
		name:        "dojo_code",
		description: "Generate Dojo systems and code in Cairo with comprehensive documentation",
	}

	// Create MCP tool definition
	definition := mcp.NewTool(tool.Name(),
		mcp.WithDescription(tool.Description()),
		mcp.WithString("prompt",
			mcp.Required(),
			mcp.Description("Your specific request about Dojo systems/code (e.g., 'Create a movement system that updates a Position model')"),
		),
	)

	tool.definition = &definition
	return tool
}

// Name returns the tool's name
func (t *CodeTool) Name() string {
	return t.name
}

// Description returns the tool's description
func (t *CodeTool) Description() string {
	return t.description
}

// Definition returns the MCP tool definition
func (t *CodeTool) Definition() *mcp.Tool {
	return t.definition
}

// Execute handles the Dojo code tool execution
func (t *CodeTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	userPrompt, ok := request.Params.Arguments["prompt"].(string)
	if !ok {
		return mcp.NewToolResultError("prompt must be a string"), nil
	}

	// Read the logic documentation from the insights file
	logicDocs, err := os.ReadFile("static/insights/logic.txt")
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("Failed to read logic documentation: %v", err)), nil
	}

	// Combine the user's specific prompt with our comprehensive logic documentation
	fullPrompt := fmt.Sprintf("Using the Dojo systems and code documentation below, please help with the following request:\n\n%s\n\n--- DOJO SYSTEMS AND CODE DOCUMENTATION ---\n\n%s", userPrompt, string(logicDocs))

	return mcp.NewToolResultText(fullPrompt), nil
}
