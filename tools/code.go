package tools

// NewCodeTool creates a new Dojo code generation tool
func NewCodeTool() *InsightTool {
	const promptTemplate = "Using the Dojo systems and code documentation below, please help with the following request:\n\n%s\n\n--- DOJO SYSTEMS AND CODE DOCUMENTATION ---\n\n%s"

	return NewInsightTool(
		"dojo_code",
		"Generate Dojo systems and code in Cairo with comprehensive documentation. This tool should be called whenever the user asks for a system or code to be generated apart from model struct generation.",
		"logic.txt",
		promptTemplate,
	)
}
