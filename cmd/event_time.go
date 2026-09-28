package cmd

import (
	"fmt"
	"strconv"
	"strings"
	"time"
)

// parseEventTime interprets the value of the --at flag as the moment an event
// happened.
//
// Records are written at the keyboard but describe something that happened
// elsewhere in time, so the accepted forms are the ones a person actually
// reaches for when backfilling: a date, a date and time, "yesterday", "today",
// and relative offsets such as "3h ago" or "2d ago". Everything is interpreted
// in the local time zone, because a date the user typed means that day where
// they are, not in UTC.
func parseEventTime(value string, now time.Time) (*time.Time, error) {
	raw := strings.TrimSpace(value)
	if raw == "" {
		return nil, nil
	}
	// Keywords and offsets are matched case insensitively, but the absolute
	// layouts are matched against the original text so an ISO "T" separator
	// still parses.
	lowered := strings.ToLower(raw)

	switch lowered {
	case "now":
		return &now, nil
	case "today":
		return startOfDay(now), nil
	case "yesterday":
		return startOfDay(now.AddDate(0, 0, -1)), nil
	}

	if offset, ok, err := parseRelativeOffset(lowered, now); ok {
		return offset, err
	}

	// Layouts are tried longest first so that a value carrying a time is not
	// silently truncated to midnight by the date-only layout.
	layouts := []string{
		"2006-01-02 15:04:05",
		"2006-01-02 15:04",
		"2006-01-02T15:04:05",
		"2006-01-02T15:04",
		time.DateOnly,
	}
	for _, layout := range layouts {
		if parsed, err := time.ParseInLocation(layout, raw, time.Local); err == nil {
			return &parsed, nil
		}
	}

	return nil, fmt.Errorf(
		"invalid time %q: expected YYYY-MM-DD, YYYY-MM-DD HH:MM, now, today, yesterday, or a relative offset such as \"3h ago\"",
		value,
	)
}

// parseRelativeOffset handles the "<n><unit> ago" form. The boolean reports
// whether the value looked like an offset at all, so that a value which is not
// one falls through to the absolute layouts rather than being reported as a
// malformed offset.
func parseRelativeOffset(value string, now time.Time) (*time.Time, bool, error) {
	if !strings.HasSuffix(value, " ago") {
		return nil, false, nil
	}

	quantity := strings.TrimSpace(strings.TrimSuffix(value, " ago"))
	if quantity == "" {
		return nil, true, fmt.Errorf("invalid relative time %q: expected a quantity such as \"3h ago\"", value)
	}

	unit := quantity[len(quantity)-1:]
	amount, err := strconv.Atoi(strings.TrimSpace(quantity[:len(quantity)-1]))
	if err != nil || amount < 0 {
		return nil, true, fmt.Errorf("invalid relative time %q: expected a whole number of units, such as \"3h ago\"", value)
	}

	var result time.Time
	switch unit {
	case "m":
		result = now.Add(-time.Duration(amount) * time.Minute)
	case "h":
		result = now.Add(-time.Duration(amount) * time.Hour)
	case "d":
		result = now.AddDate(0, 0, -amount)
	case "w":
		result = now.AddDate(0, 0, -amount*7)
	default:
		return nil, true, fmt.Errorf("invalid relative time %q: expected a unit of m, h, d or w", value)
	}

	return &result, true, nil
}

// startOfDay returns midnight local time on the day of the given instant. A
// bare date carries no time of day, so anchoring it at midnight keeps it
// distinct from a record written at the moment it is typed.
func startOfDay(value time.Time) *time.Time {
	result := time.Date(value.Year(), value.Month(), value.Day(), 0, 0, 0, 0, time.Local)
	return &result
}
