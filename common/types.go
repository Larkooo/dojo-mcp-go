package common

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

	// Tool returns the MCP tool
	Definition() mcp.Tool

	// Execute handles the tool execution
	Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error)
}

// Resource represents a text resource that can be provided to LLMs
type Resource struct {
	Name    string
	Content string
}

// Prompt represents a predefined prompt template for LLMs
type Prompt struct {
	Name        string
	Description string
	Template    string
	Variables   []string
}

// PromptRenderer is an interface for rendering prompts with variables
type PromptRenderer interface {
	// RenderPrompt fills a prompt template with the provided variables
	RenderPrompt(name string, vars map[string]string) (string, error)

	// GetPrompt returns a specific prompt by name
	GetPrompt(name string) (Prompt, bool)
}
