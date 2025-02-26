package tools

// NewTestTool creates a new Dojo test generation tool
func NewTestTool() *InsightTool {
	const promptTemplate = "Using the Dojo testing documentation below, please help write tests for the following request:\n\n%s\n\n--- DOJO TESTING DOCUMENTATION ---\n\n%s"

	return NewInsightTool(
		"dojo_test",
		"Generate test code for Dojo systems in Cairo with comprehensive documentation",
		"testing.txt",
		promptTemplate,
	)
}
