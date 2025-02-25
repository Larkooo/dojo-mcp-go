package tools

import (
	"context"
	"fmt"

	"github.com/mark3labs/mcp-go/mcp"
)

// HelloWorldTool implements the hello world functionality
type HelloWorldTool struct {
	name        string
	description string
	definition  *mcp.Tool
}

// NewHelloWorldTool creates a new hello world tool
func NewHelloWorldTool() *HelloWorldTool {
	tool := &HelloWorldTool{
		name:        "hello_world",
		description: "Say hello to someone",
	}

	// Create MCP tool definition
	definition := mcp.NewTool(tool.Name(),
		mcp.WithDescription(tool.Description()),
		mcp.WithString("name",
			mcp.Required(),
			mcp.Description("Name of the person to greet"),
		),
	)

	tool.definition = &definition
	return tool
}

// Name returns the tool's name
func (t *HelloWorldTool) Name() string {
	return t.name
}

// Description returns the tool's description
func (t *HelloWorldTool) Description() string {
	return t.description
}

// Definition returns the MCP tool definition
func (t *HelloWorldTool) Definition() *mcp.Tool {
	return t.definition
}

// Execute handles the hello world tool execution
func (t *HelloWorldTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	name, ok := request.Params.Arguments["name"].(string)
	if !ok {
		return mcp.NewToolResultError("name must be a string"), nil
	}

	return mcp.NewToolResultText(fmt.Sprintf("Hello, %s!", name)), nil
}
