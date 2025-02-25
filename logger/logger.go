package logger

import (
	"fmt"
	"os"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// Configure sets up the global logger with pretty console output
func Configure() {
	// Configure pretty logging with colors
	log.Logger = log.Output(zerolog.ConsoleWriter{
		Out:        os.Stdout,
		TimeFormat: time.RFC3339,
		NoColor:    false,
		PartsOrder: []string{
			zerolog.TimestampFieldName,
			zerolog.LevelFieldName,
			"component",
			zerolog.MessageFieldName,
		},
		FieldsExclude: []string{"component"},
		FormatFieldValue: func(i interface{}) string {
			// Only apply gray color to string values for the component field
			// For other types, just convert to string
			switch v := i.(type) {
			case string:
				return "\x1b[90m" + v + "\x1b[0m"
			default:
				// Convert other types to string using default formatting
				return fmt.Sprint(i)
			}
		},
		FormatFieldName: func(i interface{}) string {
			fieldName := i.(string)
			if fieldName == "component" {
				// Gray color for component field name
				return "\x1b[90m" + fieldName + ":\x1b[0m"
			}
			// Match the blue color from the log output
			return "\x1b[36m" + fieldName + "\x1b[0m="
		},
	})

	// Set global log level
	zerolog.SetGlobalLevel(zerolog.InfoLevel)
}
