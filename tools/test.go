package tools

import (
	"context"
	"fmt"
	"os"

	"github.com/mark3labs/mcp-go/mcp"
)

// TestTool implements functionality to generate Dojo test code
type TestTool struct {
	name        string
	description string
	definition  *mcp.Tool
}

// NewTestTool creates a new Dojo test generation tool
func NewTestTool() *TestTool {
	tool := &TestTool{
		name:        "dojo_test",
		description: "Generate test code for Dojo systems in Cairo with comprehensive documentation",
	}

	// Create MCP tool definition
	definition := mcp.NewTool(tool.Name(),
		mcp.WithDescription(tool.Description()),
		mcp.WithString("prompt",
			mcp.Required(),
			mcp.Description("Your specific request about Dojo tests (e.g., 'Create tests for a movement system that updates a Position model')"),
		),
	)

	tool.definition = &definition
	return tool
}

// Name returns the tool's name
func (t *TestTool) Name() string {
	return t.name
}

// Description returns the tool's description
func (t *TestTool) Description() string {
	return t.description
}

// Definition returns the MCP tool definition
func (t *TestTool) Definition() *mcp.Tool {
	return t.definition
}

// Execute handles the Dojo test tool execution
func (t *TestTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	userPrompt, ok := request.Params.Arguments["prompt"].(string)
	if !ok {
		return mcp.NewToolResultError("prompt must be a string"), nil
	}

	// Read the testing documentation from the insights file
	testingDocs, err := os.ReadFile("static/insights/testing.txt")
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("Failed to read testing documentation: %v", err)), nil
	}

	// Combine the user's specific prompt with our comprehensive testing documentation
	fullPrompt := fmt.Sprintf("Using the Dojo testing documentation below, please help write tests for the following request:\n\n%s\n\n--- DOJO TESTING DOCUMENTATION ---\n\n%s", userPrompt, string(testingDocs))

	return mcp.NewToolResultText(fullPrompt), nil
}
