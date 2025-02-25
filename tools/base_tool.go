package tools

import (
	"github.com/mark3labs/mcp-go/mcp"
)

// BaseTool provides common functionality for all tools
type BaseTool struct {
	name        string
	description string
	definition  *mcp.Tool
}

// NewBaseTool creates a new base tool
func NewBaseTool(name, description string) BaseTool {
	return BaseTool{
		name:        name,
		description: description,
	}
}

// Name returns the tool's name
func (t BaseTool) Name() string {
	return t.name
}

// Description returns the tool's description
func (t BaseTool) Description() string {
	return t.description
}

// Definition returns the MCP tool definition
func (t BaseTool) Definition() *mcp.Tool {
	return t.definition
}

// SetDefinition sets the MCP tool definition
func (t *BaseTool) SetDefinition(def *mcp.Tool) {
	t.definition = def
}
