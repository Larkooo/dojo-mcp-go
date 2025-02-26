package tools

import (
	"dojo-mcp/common"
)

// NewModelTool creates a new Dojo model tool
func NewModelTool(renderer common.PromptRenderer) *InsightTool {
	return NewInsightTool(
		"dojo_model",
		"Generate Dojo models in Cairo with comprehensive documentation.",
		"model.txt",
		"model.txt",
		renderer,
	)
}
