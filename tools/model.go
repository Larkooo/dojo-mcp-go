package tools

// NewModelTool creates a new Dojo model tool
func NewModelTool() *InsightTool {
	const promptTemplate = "Using the Dojo model documentation below, please help with the following request:\n\n%s\n\n--- DOJO MODEL DOCUMENTATION ---\n\n%s"

	return NewInsightTool(
		"dojo_model",
		"Generate a prompt for creating Dojo models in Cairo with comprehensive documentation.",
		"model.txt",
		promptTemplate,
	)
}
