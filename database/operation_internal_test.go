package database

import (
	"testing"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// testUserID is the identifier of the user created by setupTestDB. It matches
// the identifier injected by the dummy authentication interceptor, so the
// database tests and the server tests exercise the same scoping.
const testUserID uint = 1

// otherUserID is a second user used to prove that every operation is scoped:
// one user's records must be invisible to another rather than merely
// unreadable.
const otherUserID uint = 2

// setupTestDB opens an in-memory database, migrates it, and creates two users
// with their builtin biases seeded.
func setupTestDB(t *testing.T) *gorm.DB {
	t.Helper()

	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{
		// The query log is silenced so a failing assertion is not buried
		// under several hundred lines of SQL, including the expected
		// "record not found" lines that the find-or-create paths produce.
		Logger: logger.Discard,
	})
	if err != nil {
		t.Fatalf("failed to open test database: %v", err)
	}
	if err := AutoMigrate(db); err != nil {
		t.Fatalf("failed to migrate test database: %v", err)
	}

	for _, username := range []string{"testuser", "otheruser"} {
		user := User{Username: username}
		if err := db.Create(&user).Error; err != nil {
			t.Fatalf("failed to create the user %q: %v", username, err)
		}
		if err := SeedBuiltinBiases(db, user.ID); err != nil {
			t.Fatalf("failed to seed biases for %q: %v", username, err)
		}
	}

	return db
}

// intPtr returns a pointer to the given rating, for the many optional
// intensity fields.
func intPtr(value int) *int {
	return &value
}

func TestAutoMigrateIsIdempotent(t *testing.T) {
	db := setupTestDB(t)

	// Every server start calls AutoMigrate, so a second run against an
	// existing schema must be a no-op rather than an error.
	if err := AutoMigrate(db); err != nil {
		t.Fatalf("expected a repeated migration to succeed but got %v", err)
	}
}

func TestAutoMigrateCreatesExpectedTables(t *testing.T) {
	db := setupTestDB(t)

	// The trigger statements name their tables as strings, so a change to the
	// naming convention would otherwise fail only at runtime.
	tables := []string{
		"users",
		"tailscale_addresses",
		"cognitive_biases",
		"thought_records",
		"map_of_worries",
		"negative_thoughts",
		"feelings",
		"thought_biases",
	}

	for _, table := range tables {
		t.Run(table, func(t *testing.T) {
			if !db.Migrator().HasTable(table) {
				t.Errorf("expected the table %q to exist", table)
			}
		})
	}
}
