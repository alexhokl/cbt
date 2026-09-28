package database

import (
	"fmt"

	"gorm.io/gorm"
)

// AutoMigrate creates or updates the database schema for all known models.
// Application invariants that the ORM cannot express as struct tags are
// enforced via SQLite triggers, since SQLite does not support adding CHECK
// constraints to an existing table without a full table rebuild.
//
// There is no versioned migration logic. AutoMigrate adds tables and columns
// but never rewrites or drops them, so an incompatible change requires a fresh
// database.
func AutoMigrate(db *gorm.DB) error {
	if err := db.AutoMigrate(
		&User{},
		&TailscaleAddress{},
		&CognitiveBias{},
		&ThoughtRecord{},
		&MapOfWorry{},
		&NegativeThought{},
		&Feeling{},
	); err != nil {
		return err
	}

	for _, trigger := range schemaTriggers() {
		if err := db.Exec(trigger.statement()).Error; err != nil {
			return fmt.Errorf("failed to create %s trigger: %w", trigger.Name, err)
		}
	}

	return nil
}

// schemaTrigger describes a BEFORE INSERT/UPDATE trigger that aborts when the
// given condition holds. SQLite has no ALTER TABLE ADD CONSTRAINT, so
// invariants the ORM cannot express are enforced this way. CREATE TRIGGER IF
// NOT EXISTS keeps AutoMigrate idempotent.
type schemaTrigger struct {
	Name      string
	Event     string
	Table     string
	Condition string
	Message   string
}

func (t schemaTrigger) statement() string {
	return fmt.Sprintf(
		"CREATE TRIGGER IF NOT EXISTS %s BEFORE %s ON %s WHEN %s BEGIN SELECT RAISE(ABORT, '%s'); END",
		t.Name, t.Event, t.Table, t.Condition, t.Message,
	)
}

// schemaTriggers returns every trigger enforcing a model invariant. Each
// invariant is registered for both INSERT and UPDATE so that a stray write,
// or a future code path that bypasses the operations in this package, cannot
// leave a row the rest of the application cannot make sense of.
func schemaTriggers() []schemaTrigger {
	invariants := []struct {
		name      string
		table     string
		condition string
		message   string
	}{
		{
			// A feeling hangs off exactly one parent. Neither would orphan it;
			// both would make it appear on two unrelated records.
			name:      "feelings_single_parent",
			table:     "feelings",
			condition: "(NEW.thought_record_id IS NULL AND NEW.map_of_worry_id IS NULL) OR (NEW.thought_record_id IS NOT NULL AND NEW.map_of_worry_id IS NOT NULL)",
			message:   "a feeling must belong to exactly one of a thought record or a map of worry",
		},
		{
			// Ratings are percentages. A value outside the range is a bug at
			// the call site, not a preference of the user.
			name:      "feelings_intensity_range",
			table:     "feelings",
			condition: "(NEW.intensity_before IS NOT NULL AND (NEW.intensity_before < 0 OR NEW.intensity_before > 100)) OR (NEW.intensity_after IS NOT NULL AND (NEW.intensity_after < 0 OR NEW.intensity_after > 100))",
			message:   "a feeling intensity must be between 0 and 100",
		},
		{
			// Re-rating belongs to the challenge step, which only a thought
			// record has. A map of worry rates its feelings once.
			name:      "feelings_after_needs_record",
			table:     "feelings",
			condition: "NEW.intensity_after IS NOT NULL AND NEW.thought_record_id IS NULL",
			message:   "only a feeling on a thought record can be re-rated",
		},
		{
			// The hot thought is the single strongest thought of a record.
			// Several would defeat the purpose of singling one out.
			name:      "thoughts_single_hot",
			table:     "negative_thoughts",
			condition: "NEW.is_hot = 1 AND EXISTS (SELECT 1 FROM negative_thoughts WHERE thought_record_id = NEW.thought_record_id AND is_hot = 1 AND deleted_at IS NULL AND id <> NEW.id)",
			message:   "a thought record must not carry more than one hot thought",
		},
	}

	triggers := make([]schemaTrigger, 0, len(invariants)*2+1)
	for _, invariant := range invariants {
		for _, event := range []string{"INSERT", "UPDATE"} {
			triggers = append(triggers, schemaTrigger{
				Name:      fmt.Sprintf("%s_on_%s", invariant.name, event),
				Event:     event,
				Table:     invariant.table,
				Condition: invariant.condition,
				Message:   invariant.message,
			})
		}
	}

	// A map cannot be its own alternative. This is only registered for UPDATE:
	// in a BEFORE INSERT trigger the row's rowid has not been assigned yet, so
	// NEW.id is null and the comparison could never fire. CreateMapOfWorry
	// covers the insert path, where the identifier is not knowable in advance
	// anyway.
	triggers = append(triggers, schemaTrigger{
		Name:      "maps_no_self_derivation_on_UPDATE",
		Event:     "UPDATE",
		Table:     "map_of_worries",
		Condition: "NEW.derived_from_id IS NOT NULL AND NEW.derived_from_id = NEW.id",
		Message:   "a map of worry must not be derived from itself",
	})

	return triggers
}
