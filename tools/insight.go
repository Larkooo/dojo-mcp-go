package tools

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"github.com/mark3labs/mcp-go/mcp"
)

// InsightTool is a tool that uses insight files to enhance prompts
type InsightTool struct {
	mcp.Tool
	insightFile    string
	promptTemplate string
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
func NewInsightTool(name, description, insightFile, promptTemplate string) *InsightTool {
	tool := &InsightTool{
		Tool: mcp.NewTool(name,
			mcp.WithDescription(description),
			mcp.WithString("prompt",
				mcp.Required(),
				mcp.Description("Your specific request related to "+name),
			),
		),
		insightFile:    insightFile,
		promptTemplate: promptTemplate,
	}

	return tool
}

// Execute handles the insight tool execution
func (t *InsightTool) Execute(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
	userPrompt, ok := request.Params.Arguments["prompt"].(string)
	if !ok {
		return mcp.NewToolResultError("prompt must be a string"), nil
	}

	// Read the insight file
	insightPath := filepath.Join("static/insights", t.insightFile)
	insightContent, err := os.ReadFile(insightPath)
	if err != nil {
		return mcp.NewToolResultError(fmt.Sprintf("Failed to read insight file: %v", err)), nil
	}

	// Format the prompt using the template and insight content
	fullPrompt := fmt.Sprintf(t.promptTemplate, userPrompt, string(insightContent))

	return mcp.NewToolResultText(fullPrompt), nil
}
