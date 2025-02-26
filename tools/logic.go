package tools

import (
	"dojo-mcp/common"
)

// NewCodeTool creates a new Dojo code generation tool
func NewCodeTool(renderer common.PromptRenderer) *InsightTool {
	return NewInsightTool(
		"dojo_code",
		"Generate Dojo systems and code in Cairo with comprehensive documentation. This tool should be called whenever the user asks for a system or code to be generated apart from model struct generation.",
		"logic.txt",
		"code.txt",
		renderer,
	)
}
