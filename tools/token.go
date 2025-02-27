package tools

import (
	"dojo-mcp/common"
)

// NewConfigTool creates a new Dojo config generation tool
func NewTokenTool(renderer common.PromptRenderer) *InsightTool {
	return NewInsightTool(
		"dojo_token",
		"Generate config for Dojo systems in Cairo with comprehensive documentation",
		"token",
		"token",
		renderer,
	)
}
