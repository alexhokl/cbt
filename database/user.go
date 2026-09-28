package database

import (
	"fmt"

	"gorm.io/gorm"
)

// LocalUsername is the user the server runs as when Tailscale authentication
// is not enabled. The dummy interceptor injects a fixed user identifier, so a
// single local user owns everything written against a local server.
const LocalUsername = "local"

// EnsureUser resolves a username to a user, creating it on first sight, and
// seeds the builtin cognitive biases for it.
//
// Seeding happens here rather than at the call sites because a user without
// the catalogue cannot challenge a record: the bias names would not resolve.
// It is idempotent, so calling this for an existing user is cheap and also
// backfills anyone created before a name was added to the catalogue.
func EnsureUser(db *gorm.DB, username string) (*User, error) {
	var user User
	if err := db.FirstOrCreate(&user, User{Username: username}).Error; err != nil {
		return nil, fmt.Errorf("failed to resolve the user: %w", err)
	}
	if err := SeedBuiltinBiases(db, user.ID); err != nil {
		return nil, err
	}

	return &user, nil
}
