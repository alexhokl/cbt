package database

import (
	"errors"
	"fmt"
	"strings"
	"time"

	"gorm.io/gorm"
)

var (
	// ErrMapOfWorryNotFound is returned when a map of worry does not exist.
	ErrMapOfWorryNotFound = errors.New("map of worry not found")
	// ErrMapDerivedFromSelf is returned when a map is set to be derived from
	// itself.
	ErrMapDerivedFromSelf = errors.New("a map of worry must not be derived from itself")
	// ErrMapHasAlternatives is returned when deleting a map that other maps
	// were derived from. Deleting it would strip the alternatives of the
	// contrast that gives them their meaning.
	ErrMapHasAlternatives = errors.New("map of worry still has alternatives derived from it")
)

// MapOfWorryFilter narrows a listing of maps of worry.
type MapOfWorryFilter struct {
	// Since restricts the listing to maps whose event occurred on or after
	// this instant, falling back to the creation time where the user did not
	// say when the event happened.
	Since *time.Time
	// Search matches free text across every column of the map, case
	// insensitively.
	Search string
}

// CreateMapOfWorryInput is a new map of worry as supplied by the caller. Only
// Event is required.
type CreateMapOfWorryInput struct {
	Event                 string
	OccurredAt            *time.Time
	Thoughts              string
	WhatTheseThoughtsMean string
	PhysicalSensations    string
	ResultantBehaviour    string
	// DerivedFromID marks this map as an alternative reworking of an existing
	// one. The two are then read side by side.
	DerivedFromID *uint
	Feelings      []FeelingInput
}

// UpdateMapOfWorryInput carries the columns to change on an existing map. A
// nil field is left as it is.
type UpdateMapOfWorryInput struct {
	Event                 *string
	OccurredAt            *time.Time
	ClearOccurredAt       bool
	Thoughts              *string
	WhatTheseThoughtsMean *string
	PhysicalSensations    *string
	ResultantBehaviour    *string
}

// CreateMapOfWorry creates a map of worry together with any feelings supplied
// up front.
func CreateMapOfWorry(db *gorm.DB, userID uint, input CreateMapOfWorryInput) (*MapOfWorry, error) {
	event := strings.TrimSpace(input.Event)
	if event == "" {
		return nil, ErrEventEmpty
	}

	var mapOfWorry MapOfWorry
	err := db.Transaction(func(tx *gorm.DB) error {
		if input.DerivedFromID != nil {
			var origin MapOfWorry
			if err := findMapOfWorry(tx, userID, *input.DerivedFromID, &origin); err != nil {
				return err
			}
		}

		mapOfWorry = MapOfWorry{
			Event:                 event,
			OccurredAt:            input.OccurredAt,
			Thoughts:              strings.TrimSpace(input.Thoughts),
			WhatTheseThoughtsMean: strings.TrimSpace(input.WhatTheseThoughtsMean),
			PhysicalSensations:    strings.TrimSpace(input.PhysicalSensations),
			ResultantBehaviour:    strings.TrimSpace(input.ResultantBehaviour),
			DerivedFromID:         input.DerivedFromID,
			UserID:                userID,
		}
		if err := tx.Create(&mapOfWorry).Error; err != nil {
			return fmt.Errorf("failed to create the map of worry: %w", err)
		}

		if len(input.Feelings) > 0 {
			feelings, err := buildFeelings(input.Feelings, userID, nil, &mapOfWorry.ID)
			if err != nil {
				return err
			}
			if err := tx.Create(&feelings).Error; err != nil {
				return fmt.Errorf("failed to create the feelings: %w", err)
			}
		}

		return loadMapOfWorry(tx, userID, mapOfWorry.ID, &mapOfWorry)
	})
	if err != nil {
		return nil, err
	}

	return &mapOfWorry, nil
}

// ListMapsOfWorry returns the user's maps of worry, most recent event first.
func ListMapsOfWorry(db *gorm.DB, userID uint, filter MapOfWorryFilter) ([]MapOfWorry, error) {
	query := db.Preload("Feelings").Where("user_id = ?", userID)

	if filter.Since != nil {
		query = query.Where("COALESCE(occurred_at, created_at) >= ?", *filter.Since)
	}
	if search := strings.TrimSpace(filter.Search); search != "" {
		pattern := "%" + strings.ToLower(search) + "%"
		query = query.Where(
			db.Where("LOWER(event) LIKE ?", pattern).
				Or("LOWER(thoughts) LIKE ?", pattern).
				Or("LOWER(what_these_thoughts_mean) LIKE ?", pattern).
				Or("LOWER(physical_sensations) LIKE ?", pattern).
				Or("LOWER(resultant_behaviour) LIKE ?", pattern),
		)
	}

	var maps []MapOfWorry
	if err := query.Order("COALESCE(occurred_at, created_at) DESC, id DESC").Find(&maps).Error; err != nil {
		return nil, fmt.Errorf("failed to list the maps of worry: %w", err)
	}

	return maps, nil
}

// GetMapOfWorry returns a single map with its feelings and, when it is an
// alternative, the map it was derived from.
func GetMapOfWorry(db *gorm.DB, userID uint, id uint) (*MapOfWorry, error) {
	var mapOfWorry MapOfWorry
	if err := loadMapOfWorry(db, userID, id, &mapOfWorry); err != nil {
		return nil, err
	}

	return &mapOfWorry, nil
}

// ListAlternatives returns the maps derived from the given map, so the
// original and its reworkings can be presented together.
func ListAlternatives(db *gorm.DB, userID uint, id uint) ([]MapOfWorry, error) {
	var alternatives []MapOfWorry
	if err := db.
		Preload("Feelings").
		Where("user_id = ?", userID).
		Where("derived_from_id = ?", id).
		Order("id ASC").
		Find(&alternatives).Error; err != nil {
		return nil, fmt.Errorf("failed to list the alternative maps of worry: %w", err)
	}

	return alternatives, nil
}

// UpdateMapOfWorry changes the free text columns of a map. Fields left nil
// keep their current value.
func UpdateMapOfWorry(db *gorm.DB, userID uint, id uint, input UpdateMapOfWorryInput) (*MapOfWorry, error) {
	var mapOfWorry MapOfWorry
	err := db.Transaction(func(tx *gorm.DB) error {
		if err := findMapOfWorry(tx, userID, id, &mapOfWorry); err != nil {
			return err
		}

		updates := map[string]any{}
		if input.Event != nil {
			event := strings.TrimSpace(*input.Event)
			if event == "" {
				return ErrEventEmpty
			}
			updates["event"] = event
		}
		if input.ClearOccurredAt {
			updates["occurred_at"] = nil
		} else if input.OccurredAt != nil {
			updates["occurred_at"] = *input.OccurredAt
		}
		if input.Thoughts != nil {
			updates["thoughts"] = strings.TrimSpace(*input.Thoughts)
		}
		if input.WhatTheseThoughtsMean != nil {
			updates["what_these_thoughts_mean"] = strings.TrimSpace(*input.WhatTheseThoughtsMean)
		}
		if input.PhysicalSensations != nil {
			updates["physical_sensations"] = strings.TrimSpace(*input.PhysicalSensations)
		}
		if input.ResultantBehaviour != nil {
			updates["resultant_behaviour"] = strings.TrimSpace(*input.ResultantBehaviour)
		}

		if len(updates) > 0 {
			if err := tx.Model(&mapOfWorry).Updates(updates).Error; err != nil {
				return fmt.Errorf("failed to update the map of worry: %w", err)
			}
		}

		return loadMapOfWorry(tx, userID, id, &mapOfWorry)
	})
	if err != nil {
		return nil, err
	}

	return &mapOfWorry, nil
}

// DeleteMapOfWorry removes a map along with its feelings. A map other maps
// were derived from is reported rather than deleted: the alternative exists to
// be contrasted with the original, so removing the original silently would
// leave it stranded.
func DeleteMapOfWorry(db *gorm.DB, userID uint, id uint) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var mapOfWorry MapOfWorry
		if err := findMapOfWorry(tx, userID, id, &mapOfWorry); err != nil {
			return err
		}

		var count int64
		if err := tx.
			Model(&MapOfWorry{}).
			Where("derived_from_id = ?", id).
			Where("user_id = ?", userID).
			Count(&count).Error; err != nil {
			return fmt.Errorf("failed to count the alternative maps of worry: %w", err)
		}
		if count > 0 {
			return fmt.Errorf("%w: %d alternative(s)", ErrMapHasAlternatives, count)
		}

		if err := tx.Where("map_of_worry_id = ?", id).Where("user_id = ?", userID).Delete(&Feeling{}).Error; err != nil {
			return fmt.Errorf("failed to delete the feelings: %w", err)
		}
		if err := tx.Delete(&mapOfWorry).Error; err != nil {
			return fmt.Errorf("failed to delete the map of worry: %w", err)
		}

		return nil
	})
}

// findMapOfWorry loads a map by identifier without its associations,
// translating a missing row into ErrMapOfWorryNotFound. The query is scoped to
// the given user so cross-user access is reported as not found rather than
// leaking existence.
func findMapOfWorry(tx *gorm.DB, userID uint, id uint, mapOfWorry *MapOfWorry) error {
	err := tx.Where("user_id = ?", userID).First(mapOfWorry, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrMapOfWorryNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the map of worry: %w", err)
	}

	return nil
}

// loadMapOfWorry loads a map together with its feelings and the map it was
// derived from, when it is an alternative.
func loadMapOfWorry(tx *gorm.DB, userID uint, id uint, mapOfWorry *MapOfWorry) error {
	err := tx.
		Preload("Feelings").
		Preload("DerivedFrom").
		Preload("DerivedFrom.Feelings").
		Where("user_id = ?", userID).
		First(mapOfWorry, id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return fmt.Errorf("%w: %d", ErrMapOfWorryNotFound, id)
	}
	if err != nil {
		return fmt.Errorf("failed to query the map of worry: %w", err)
	}

	return nil
}
