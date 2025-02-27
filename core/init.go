package core

import (
	"dojo-mcp/tools"
)

// RegisterDefaultTools registers all default tools in the registry
func RegisterDefaultTools(registry *Registry) {
	registry.Register(tools.NewModelTool(registry))
	registry.Register(tools.NewCodeTool(registry))
	registry.Register(tools.NewTestTool(registry))
	registry.Register(tools.NewConfigTool(registry))
	registry.Register(tools.NewTokenTool(registry))
	registry.Register(tools.New101Tool(registry))
}
