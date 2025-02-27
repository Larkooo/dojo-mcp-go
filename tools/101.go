package tools

import (
	"dojo-mcp/common"
)

// NewConfigTool creates a new Dojo config generation tool
func New101Tool(renderer common.PromptRenderer) *InsightTool {
	return NewInsightTool(
		"dojo_101",
		"A 101 introduction on how to make a Dojo game",
		"101",
		"101",
		renderer,
	)
}
