package tools

import (
	"dojo-mcp/common"
)

// NewTestTool creates a new Dojo test generation tool
func NewTestTool(renderer common.PromptRenderer) *InsightTool {
	return NewInsightTool(
		"dojo_test",
		"Generate test code for Dojo systems in Cairo with comprehensive documentation",
		"test",
		"test",
		renderer,
	)
}
