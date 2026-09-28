package database

import (
	"fmt"
	"log/slog"
	"os"
	"path/filepath"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// Open opens (creating it if required) the SQLite database at the given path
// and applies any outstanding schema migrations. The parent directory is
// created if it does not already exist.
//
// The database is not encrypted at rest. This is a deliberate decision: the
// alternative (SQLCipher) means a passphrase prompt on every invocation, which
// is friction at precisely the moment the user is least willing to tolerate
// it, and the deployment model already restricts reach to a tailnet. See
// AGENTS.md.
func Open(path string) (*gorm.DB, error) {
	if path == "" {
		return nil, fmt.Errorf("database file path cannot be empty")
	}

	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0o750); err != nil {
		slog.Warn(
			"failed to create directory",
			slog.String("path", dir),
			slog.String("error", err.Error()),
		)
	}

	db, err := gorm.Open(
		sqlite.Open(path),
		&gorm.Config{
			Logger: logger.New(
				slog.NewLogLogger(slog.NewJSONHandler(os.Stdout, nil), slog.LevelInfo),
				logger.Config{
					IgnoreRecordNotFoundError: true,
				},
			),
		},
	)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	if err := AutoMigrate(db); err != nil {
		return nil, fmt.Errorf("failed to migrate database schema: %w", err)
	}

	return db, nil
}
