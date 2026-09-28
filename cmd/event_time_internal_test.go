package cmd

import (
	"testing"
	"time"
)

// referenceNow is a fixed instant so the relative forms produce predictable
// results regardless of when the tests run.
var referenceNow = time.Date(2026, 9, 27, 14, 30, 0, 0, time.Local)

func TestParseEventTimeAcceptsTheFormsPeopleActuallyType(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected time.Time
	}{
		{"a date", "2026-09-25", time.Date(2026, 9, 25, 0, 0, 0, 0, time.Local)},
		{"a date and time", "2026-09-25 08:15", time.Date(2026, 9, 25, 8, 15, 0, 0, time.Local)},
		{"an ISO separator", "2026-09-25T08:15", time.Date(2026, 9, 25, 8, 15, 0, 0, time.Local)},
		{"with seconds", "2026-09-25 08:15:30", time.Date(2026, 9, 25, 8, 15, 30, 0, time.Local)},
		{"now", "now", referenceNow},
		{"today", "today", time.Date(2026, 9, 27, 0, 0, 0, 0, time.Local)},
		{"yesterday", "yesterday", time.Date(2026, 9, 26, 0, 0, 0, 0, time.Local)},
		{"minutes ago", "90m ago", referenceNow.Add(-90 * time.Minute)},
		{"hours ago", "3h ago", referenceNow.Add(-3 * time.Hour)},
		{"days ago", "2d ago", referenceNow.AddDate(0, 0, -2)},
		{"weeks ago", "1w ago", referenceNow.AddDate(0, 0, -7)},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			parsed, err := parseEventTime(test.input, referenceNow)
			if err != nil {
				t.Fatalf("failed to parse %q: %v", test.input, err)
			}
			if parsed == nil {
				t.Fatalf("expected a time for %q but got nothing", test.input)
			}
			if !parsed.Equal(test.expected) {
				t.Errorf("expected %v but got %v", test.expected, *parsed)
			}
		})
	}
}

func TestParseEventTimeIsCaseInsensitiveForKeywords(t *testing.T) {
	// The keywords are typed in a hurry, so casing must not matter.
	for _, input := range []string{"Yesterday", "YESTERDAY", "  yesterday  "} {
		t.Run(input, func(t *testing.T) {
			parsed, err := parseEventTime(input, referenceNow)
			if err != nil {
				t.Fatalf("failed to parse %q: %v", input, err)
			}
			expected := time.Date(2026, 9, 26, 0, 0, 0, 0, time.Local)
			if !parsed.Equal(expected) {
				t.Errorf("expected %v but got %v", expected, *parsed)
			}
		})
	}
}

func TestParseEventTimeTreatsBlankAsUnset(t *testing.T) {
	// An unset --at means "I am not saying when", which is distinct from the
	// zero time and must not be sent as one.
	parsed, err := parseEventTime("   ", referenceNow)
	if err != nil {
		t.Fatalf("expected a blank value to be accepted but got %v", err)
	}
	if parsed != nil {
		t.Errorf("expected no time but got %v", *parsed)
	}
}

func TestParseEventTimeRejectsNonsense(t *testing.T) {
	tests := []string{
		"tomorrow",
		"3x ago",
		"ago",
		"-3h ago",
		"25/09/2026",
		"2026-13-45",
	}

	for _, input := range tests {
		t.Run(input, func(t *testing.T) {
			if _, err := parseEventTime(input, referenceNow); err == nil {
				t.Errorf("expected %q to be rejected", input)
			}
		})
	}
}

func TestParseSinceAcceptsABareWindow(t *testing.T) {
	// "--since 7d" reads more naturally as a window than "7d ago" does, so the
	// bare form is accepted and rewritten.
	parsed, err := parseSince("7d", referenceNow)
	if err != nil {
		t.Fatalf("failed to parse the window: %v", err)
	}
	expected := referenceNow.AddDate(0, 0, -7)
	if !parsed.Equal(expected) {
		t.Errorf("expected %v but got %v", expected, *parsed)
	}
}

func TestParseSinceStillAcceptsADate(t *testing.T) {
	parsed, err := parseSince("2026-09-01", referenceNow)
	if err != nil {
		t.Fatalf("failed to parse the date: %v", err)
	}
	expected := time.Date(2026, 9, 1, 0, 0, 0, 0, time.Local)
	if !parsed.Equal(expected) {
		t.Errorf("expected %v but got %v", expected, *parsed)
	}
}
