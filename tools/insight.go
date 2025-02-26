package tools

import (
	"context"
	"dojo-mcp/common"
	"fmt"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/rs/zerolog/log"
)

// InsightTool is a tool that uses insight files to enhance prompts
type InsightTool struct {
	mcp.Tool
	insight  string
	prompt   string
	renderer common.PromptRenderer
}

func (t *InsightTool) Name() string {
	return t.Tool.Name
}

func (t *InsightTool) Description() string {
	return t.Tool.Description
}

func (t *InsightTool) Definition() mcp.Tool {
	return t.Tool
}

// NewInsightTool creates a new tool that uses an insight file
func NewInsightTool(name, description, insight, prompt string, renderer common.PromptRenderer) *InsightTool {
	tool := &InsightTool{
		Tool: mcp.NewTool(name,
			mcp.WithDescription(description),
			mcp.WithString("prompt",
				mcp.Required(),
				mcp.Description("Your specific request related to "+name),
			),
		),
		insight:  insight,
		prompt:   prompt,
		renderer: renderer,
	}

	return tool
}

// Execute handles the insight tool execution
func (t *InsightTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	userPrompt, ok := request.Params.Arguments["prompt"].(string)
	if !ok {
		return mcp.NewToolResultError("prompt must be a string"), nil
	}

	// Create variables map for rendering
	vars := map[string]string{
		"prompt":  userPrompt,
		"insight": "insight:" + t.insight,
	}

	// Render the prompt using the registry
	fullPrompt, err := t.renderer.RenderPrompt(t.prompt, vars)
	if err != nil {
		log.Warn().
			Str("tool", t.Name()).
			Str("prompt", t.prompt).
			Str("component", "tools").
			Msgf("Failed rendering prompt: %v", err)
		return mcp.NewToolResultError(fmt.Sprintf("Failed to render prompt: %v", err)), nil
	}

	return mcp.NewToolResultText(fullPrompt), nil
}
