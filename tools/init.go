package tools

// RegisterDefaultTools registers all default tools in the registry
func RegisterDefaultTools(registry *Registry) {
	// Register hello world tool
	registry.Register(NewHelloWorldTool())

	// Register other tools as needed
	// registry.Register(NewCalculatorTool())
	// registry.Register(NewWeatherTool())
	// etc.
}
