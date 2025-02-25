package core

import (
	"dojo-mcp/tools"
)

// RegisterDefaultTools registers all default tools in the registry
func RegisterDefaultTools(registry *Registry) {
	registry.Register(tools.NewModelTool())
	registry.Register(tools.NewCodeTool())
}
