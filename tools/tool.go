package tools

import (
	"context"

	"github.com/mark3labs/mcp-go/mcp"
)

// Tool is an interface that all MCP tools must implement
type Tool interface {
	// Name returns the tool's name
	Name() string

	// Description returns the tool's description
	Description() string

	// Definition returns the MCP tool definition
	Definition() *mcp.Tool

	// Execute handles the tool execution
	Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error)
}

// Registry stores all registered tools
type Registry struct {
	tools map[string]Tool
}

// NewRegistry creates a new tool registry
func NewRegistry() *Registry {
	return &Registry{
		tools: make(map[string]Tool),
	}
}

// Register adds a tool to the registry
func (r *Registry) Register(tool Tool) {
	r.tools[tool.Name()] = tool
}

// GetAll returns all registered tools
func (r *Registry) GetAll() map[string]Tool {
	return r.tools
}
