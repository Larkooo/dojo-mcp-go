package core

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/rs/zerolog/log"
)

// Registry stores all registered tools, resources and prompts
type Registry struct {
	tools       map[string]Tool
	resources   map[string]Resource
	prompts     map[string]Prompt
	resourceDir string
	promptDir   string
}

// NewRegistry creates a new registry
func NewRegistry() *Registry {
	return &Registry{
		tools:       make(map[string]Tool),
		resources:   make(map[string]Resource),
		prompts:     make(map[string]Prompt),
		resourceDir: "static/insights", // Default directory for resources
		promptDir:   "static/prompts",  // Default directory for prompts
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

// RegisterTools registers multiple tools at once
func (r *Registry) RegisterTools(tools ...Tool) {
	for _, tool := range tools {
		r.Register(tool)
	}
	log.Debug().
		Str("component", "registry").
		Int("count", len(tools)).
		Msg("Registered multiple tools")
}

// GetAllTools returns all registered tools
func (r *Registry) GetAllTools() map[string]Tool {
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

// SetPromptDirectory sets the directory where prompts are located
func (r *Registry) SetPromptDirectory(dir string) {
	r.promptDir = dir
	log.Debug().
		Str("component", "registry").
		Str("dir", dir).
		Msg("Set prompt directory")
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

// LoadPrompts loads all prompt templates from the prompt directory
func (r *Registry) LoadPrompts() error {
	log.Debug().
		Str("component", "registry").
		Str("dir", r.promptDir).
		Msg("Loading prompts")

	return filepath.Walk(r.promptDir, func(path string, info os.FileInfo, err error) error {
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
					Msg("Failed to read prompt file")
				return err
			}

			// Parse the prompt file
			// Format: First line is name, second line is description, rest is template
			lines := strings.Split(string(content), "\n")
			if len(lines) < 3 {
				log.Warn().
					Str("component", "registry").
					Str("file", path).
					Msg("Prompt file has invalid format (needs at least 3 lines)")
				return nil
			}

			name := strings.TrimSpace(lines[0])
			description := strings.TrimSpace(lines[1])
			template := strings.Join(lines[2:], "\n")

			// Extract variables from template (format: {{variable}})
			variables := extractVariables(template)

			r.prompts[name] = Prompt{
				Name:        name,
				Description: description,
				Template:    template,
				Variables:   variables,
			}

			log.Debug().
				Str("component", "registry").
				Str("prompt", name).
				Int("vars", len(variables)).
				Msg("Loaded prompt template")
		}

		return nil
	})
}

// extractVariables finds all variables in the format {{variable}} in a template
func extractVariables(template string) []string {
	var variables []string
	varMap := make(map[string]bool) // To ensure uniqueness

	// Simple regex-like parsing for {{variable}}
	start := 0
	for {
		start = strings.Index(template[start:], "{{")
		if start == -1 {
			break
		}

		end := strings.Index(template[start:], "}}")
		if end == -1 {
			break
		}

		varName := strings.TrimSpace(template[start+2 : start+end])
		if varName != "" && !varMap[varName] {
			variables = append(variables, varName)
			varMap[varName] = true
		}

		start += end + 2
	}

	return variables
}

// RegisterPrompt manually adds a prompt to the registry
func (r *Registry) RegisterPrompt(prompt Prompt) {
	r.prompts[prompt.Name] = prompt
	log.Debug().
		Str("component", "registry").
		Str("prompt", prompt.Name).
		Msg("Registered prompt")
}

// GetPrompt returns a specific prompt by name
func (r *Registry) GetPrompt(name string) (Prompt, bool) {
	prompt, exists := r.prompts[name]
	return prompt, exists
}

// GetAllPrompts returns all registered prompts
func (r *Registry) GetAllPrompts() map[string]Prompt {
	return r.prompts
}

// RenderPrompt fills a prompt template with the provided variables
func (r *Registry) RenderPrompt(name string, vars map[string]string) (string, error) {
	prompt, exists := r.prompts[name]
	if !exists {
		return "", fmt.Errorf("prompt '%s' not found", name)
	}

	result := prompt.Template
	for key, value := range vars {
		result = strings.ReplaceAll(result, "{{"+key+"}}", value)
	}

	// Check if any variables are still in the template
	for _, v := range prompt.Variables {
		if strings.Contains(result, "{{"+v+"}}") {
			return "", fmt.Errorf("variable '%s' not provided for prompt '%s'", v, name)
		}
	}

	return result, nil
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

// GetPromptResult renders a prompt and returns it in MCP format
func (r *Registry) GetPromptResult(name string, request mcp.GetPromptRequest) (*mcp.GetPromptResult, error) {
	prompt, exists := r.prompts[name]
	if !exists {
		return nil, fmt.Errorf("prompt '%s' not found", name)
	}

	// Render the prompt
	renderedPrompt, err := r.RenderPrompt(name, request.Params.Arguments)
	if err != nil {
		return nil, fmt.Errorf("failed to render prompt: %v", err)
	}

	return &mcp.GetPromptResult{
		Description: prompt.Description,
		Messages: []mcp.PromptMessage{
			{
				Role:    "user",
				Content: renderedPrompt,
			},
		},
	}, nil
}
