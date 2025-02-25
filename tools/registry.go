package tools

import (
	"context"
	"os"
	"path/filepath"
	"strings"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/rs/zerolog/log"
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

// Registry stores all registered tools and resources
type Registry struct {
	tools       map[string]Tool
	resources   map[string]Resource
	resourceDir string
}

// NewRegistry creates a new tool registry
func NewRegistry() *Registry {
	return &Registry{
		tools:       make(map[string]Tool),
		resources:   make(map[string]Resource),
		resourceDir: "static/insights", // Default directory for resources
	}
}

// Register adds a tool to the registry
func (r *Registry) Register(tool Tool) {
	r.tools[tool.Name()] = tool
	log.Debug().
		Str("component", "registry").
		Str("tool", tool.Name()).
		Msg("Registered tool")
}

// GetAll returns all registered tools
func (r *Registry) GetAll() map[string]Tool {
	return r.tools
}

// SetResourceDirectory sets the directory where resources are located
func (r *Registry) SetResourceDirectory(dir string) {
	r.resourceDir = dir
	log.Debug().
		Str("component", "registry").
		Str("dir", dir).
		Msg("Set resource directory")
}

// LoadResources loads all .txt files from the resource directory
func (r *Registry) LoadResources() error {
	log.Debug().
		Str("component", "registry").
		Str("dir", r.resourceDir).
		Msg("Loading resources")

	return filepath.Walk(r.resourceDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			log.Error().
				Str("component", "registry").
				Str("path", path).
				Err(err).
				Msg("Error accessing path")
			return err
		}

		if !info.IsDir() && strings.HasSuffix(strings.ToLower(path), ".txt") {
			content, err := os.ReadFile(path)
			if err != nil {
				log.Error().
					Str("component", "registry").
					Str("file", path).
					Err(err).
					Msg("Failed to read file")
				return err
			}

			// Use the filename (without extension) as the resource name
			name := strings.TrimSuffix(filepath.Base(path), filepath.Ext(path))
			r.resources[name] = Resource{
				Name:    name,
				Content: string(content),
			}

			log.Debug().
				Str("component", "registry").
				Str("resource", name).
				Int("size", len(content)).
				Msg("Loaded resource")
		}

		return nil
	})
}

// GetResource returns a specific resource by name
func (r *Registry) GetResource(name string) (Resource, bool) {
	resource, exists := r.resources[name]
	return resource, exists
}

// GetAllResources returns all loaded resources
func (r *Registry) GetAllResources() map[string]Resource {
	return r.resources
}
