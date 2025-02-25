package tools

import (
	"context"
	"fmt"

	"github.com/mark3labs/mcp-go/mcp"
)

// HelloWorldTool implements the hello world functionality
type HelloWorldTool struct {
	BaseTool
}

// NewHelloWorldTool creates a new hello world tool
func NewHelloWorldTool() *HelloWorldTool {
	tool := &HelloWorldTool{
		BaseTool: NewBaseTool("hello_world", "Say hello to someone"),
	}

	// Create MCP tool definition
	definition := mcp.NewTool(tool.Name(),
		mcp.WithDescription(tool.Description()),
		mcp.WithString("name",
			mcp.Required(),
			mcp.Description("Name of the person to greet"),
		),
	)

	tool.SetDefinition(&definition)
	return tool
}

// Execute handles the hello world tool execution
func (t *HelloWorldTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	name, ok := request.Params.Arguments["name"].(string)
	if !ok {
		return mcp.NewToolResultError("name must be a string"), nil
	}

	return mcp.NewToolResultText(fmt.Sprintf("Hello, %s!", name)), nil
}
