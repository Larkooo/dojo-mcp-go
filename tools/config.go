package tools

import (
	"dojo-mcp/common"
)

// NewConfigTool creates a new Dojo config generation tool
func NewConfigTool(renderer common.PromptRenderer) *InsightTool {
	return NewInsightTool(
		"dojo_config",
		"Generate config for Dojo systems in Cairo with comprehensive documentation",
		"config",
		"config",
		renderer,
	)
}
