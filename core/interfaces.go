package core

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

// Resource represents a text resource that can be provided to LLMs
type Resource struct {
	Name    string
	Content string
}
