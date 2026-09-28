package cmd

import (
	"bytes"
	"strings"
	"testing"
	"time"

	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// int32Ptr returns a pointer to the given rating, for the optional wire
// intensity fields.
func int32Ptr(value int32) *int32 {
	return &value
}

func TestWriteThoughtRecordTableStaysNarrow(t *testing.T) {
	var out bytes.Buffer

	records := []*proto.ThoughtRecord{
		{
			Id:        1,
			Event:     "the last train was cancelled and I got home two hours later than I meant to",
			CreatedAt: timestamppb.New(time.Date(2026, 9, 25, 8, 0, 0, 0, time.Local)),
			Feelings: []*proto.Feeling{
				{Id: 1, Name: "tired", IntensityBefore: int32Ptr(40)},
				{Id: 2, Name: "restless", IntensityBefore: int32Ptr(85)},
			},
		},
	}

	if err := writeThoughtRecordTable(&out, records); err != nil {
		t.Fatalf("failed to write the table: %v", err)
	}

	// Six columns of prose will not survive an eighty column terminal, so the
	// listing is deliberately narrow and the full text is left to the detail
	// view.
	for _, line := range strings.Split(strings.TrimRight(out.String(), "\n"), "\n") {
		if width := len([]rune(line)); width > 80 {
			t.Errorf("expected every line to fit in 80 columns but got %d: %q", width, line)
		}
	}
}

func TestWriteThoughtRecordTableShowsTheStrongestFeeling(t *testing.T) {
	var out bytes.Buffer

	records := []*proto.ThoughtRecord{
		{
			Id:        1,
			Event:     "an event",
			CreatedAt: timestamppb.New(referenceNow),
			Feelings: []*proto.Feeling{
				{Id: 1, Name: "tired", IntensityBefore: int32Ptr(40)},
				{Id: 2, Name: "restless", IntensityBefore: int32Ptr(85)},
				{Id: 3, Name: "flat"},
			},
		},
	}

	if err := writeThoughtRecordTable(&out, records); err != nil {
		t.Fatalf("failed to write the table: %v", err)
	}

	// Only one feeling fits, so it must be the one the user rated highest.
	if !strings.Contains(out.String(), "restless 85%") {
		t.Errorf("expected the strongest feeling to be shown but got:\n%s", out.String())
	}
	if !strings.Contains(out.String(), "+2") {
		t.Errorf("expected the remaining feelings to be counted but got:\n%s", out.String())
	}
}

func TestStrongestFeelingPrefersARatedFeeling(t *testing.T) {
	// A rating is a judgement the user made; an absent one is not a zero, so
	// an unrated feeling must not outrank a rated one.
	feelings := []*proto.Feeling{
		{Name: "flat"},
		{Name: "anxious", IntensityBefore: int32Ptr(10)},
	}

	if got := strongestFeeling(feelings); !strings.HasPrefix(got, "anxious") {
		t.Errorf("expected the rated feeling first but got %q", got)
	}
}

func TestStrongestFeelingHandlesNoFeelings(t *testing.T) {
	if got := strongestFeeling(nil); got != "-" {
		t.Errorf("expected a dash but got %q", got)
	}
}

func TestFormatEventDateMarksTheFallback(t *testing.T) {
	created := time.Date(2026, 9, 27, 21, 0, 0, 0, time.Local)
	occurred := timestamppb.New(time.Date(2026, 9, 25, 8, 0, 0, 0, time.Local))

	t.Run("when the user said", func(t *testing.T) {
		if got := formatEventDate(occurred, created); got != "2026-09-25" {
			t.Errorf("expected the event date but got %q", got)
		}
	})

	t.Run("when the user did not", func(t *testing.T) {
		// The two must never be confused: a record typed days later would
		// otherwise look like it happened that day.
		if got := formatEventDate(nil, created); got != "~2026-09-27" {
			t.Errorf("expected a marked fallback but got %q", got)
		}
	})
}

func TestWriteThoughtRecordDetailOmitsEmptyColumns(t *testing.T) {
	var out bytes.Buffer

	record := &proto.ThoughtRecord{
		Id:        3,
		Event:     "a meeting was moved without telling me",
		CreatedAt: timestamppb.New(referenceNow),
		UpdatedAt: timestamppb.New(referenceNow),
	}

	if err := writeThoughtRecordDetail(&out, record); err != nil {
		t.Fatalf("failed to write the detail: %v", err)
	}

	rendered := out.String()
	if !strings.Contains(rendered, "not yet challenged") {
		t.Errorf("expected the record to be shown as unchallenged but got:\n%s", rendered)
	}
	// A record in progress should read as what has been written so far, not as
	// a form with blanks in it.
	for _, label := range []string{"another way to look at this", "how I feel now", "thoughts:", "feelings:"} {
		if strings.Contains(rendered, label) {
			t.Errorf("expected the empty column %q to be omitted but got:\n%s", label, rendered)
		}
	}
}

func TestWriteThoughtRecordDetailShowsTheChallengeWork(t *testing.T) {
	var out bytes.Buffer

	record := &proto.ThoughtRecord{
		Id:              3,
		Event:           "a meeting was moved without telling me",
		AlternativeView: "the invite may simply have failed to send",
		FeelingsNow:     "calmer",
		ChallengedAt:    timestamppb.New(referenceNow),
		CreatedAt:       timestamppb.New(referenceNow),
		UpdatedAt:       timestamppb.New(referenceNow),
		Thoughts: []*proto.NegativeThought{
			{
				Id:     7,
				Body:   "they do not think my input matters",
				IsHot:  true,
				Biases: []*proto.CognitiveBias{{Id: 5, Name: "catastrophising"}},
			},
			{Id: 8, Body: "I will be left out of the next one"},
		},
		Feelings: []*proto.Feeling{
			{Id: 4, Name: "anxious", IntensityBefore: int32Ptr(80), IntensityAfter: int32Ptr(20)},
		},
	}

	if err := writeThoughtRecordDetail(&out, record); err != nil {
		t.Fatalf("failed to write the detail: %v", err)
	}

	rendered := out.String()

	// Seeing the before and after ratings together is the point of re-rating.
	if !strings.Contains(rendered, "80% -> 20%") {
		t.Errorf("expected both ratings to be shown but got:\n%s", rendered)
	}
	// The strongest thought is conventionally circled on paper; an asterisk is
	// the closest a terminal gets.
	if !strings.Contains(rendered, "* [7]") {
		t.Errorf("expected the strongest thought to be marked but got:\n%s", rendered)
	}
	if !strings.Contains(rendered, "(catastrophising)") {
		t.Errorf("expected the bias to be shown against its thought but got:\n%s", rendered)
	}
	if !strings.Contains(rendered, "challenged 2026-09-27") {
		t.Errorf("expected the challenge date but got:\n%s", rendered)
	}
}

func TestWriteMapContrastShowsBothReadings(t *testing.T) {
	var out bytes.Buffer

	origin := &proto.MapOfWorry{
		Id:                 1,
		Event:              "a report came back covered in comments",
		ResultantBehaviour: "put off opening the review until the next morning",
		CreatedAt:          timestamppb.New(referenceNow),
		UpdatedAt:          timestamppb.New(referenceNow),
	}
	originID := uint32(1)
	alternative := &proto.MapOfWorry{
		Id:                 2,
		Event:              "a report came back covered in comments",
		ResultantBehaviour: "worked through the comments one at a time",
		DerivedFromId:      &originID,
		CreatedAt:          timestamppb.New(referenceNow),
		UpdatedAt:          timestamppb.New(referenceNow),
	}

	response := &proto.GetMapOfWorryResponse{
		Map:          alternative,
		DerivedFrom:  origin,
		Alternatives: nil,
	}

	if err := writeMapContrast(&out, response); err != nil {
		t.Fatalf("failed to write the contrast: %v", err)
	}

	rendered := out.String()
	// The contrast between two readings of the same event is the therapeutic
	// payload, so both must appear without a second command.
	if !strings.Contains(rendered, "put off opening the review") {
		t.Errorf("expected the original behaviour but got:\n%s", rendered)
	}
	if !strings.Contains(rendered, "worked through the comments") {
		t.Errorf("expected the reworked behaviour but got:\n%s", rendered)
	}
	if !strings.Contains(rendered, "the map this reworks") {
		t.Errorf("expected the two to be labelled but got:\n%s", rendered)
	}
}

func TestWriteBiasTableDistinguishesBuiltins(t *testing.T) {
	var out bytes.Buffer

	biases := []*proto.CognitiveBias{
		{Id: 1, Name: "catastrophising", IsBuiltin: true},
		{Id: 10, Name: "comparing myself to others"},
	}

	if err := writeBiasTable(&out, biases); err != nil {
		t.Fatalf("failed to write the table: %v", err)
	}

	rendered := out.String()
	if !strings.Contains(rendered, "builtin") || !strings.Contains(rendered, "yours") {
		t.Errorf("expected the two sources to be distinguished but got:\n%s", rendered)
	}
}

func TestEmptyListingsSaySoExplicitly(t *testing.T) {
	// A silent empty listing is indistinguishable from a broken command.
	tests := []struct {
		name string
		run  func(*bytes.Buffer) error
	}{
		{"thought records", func(out *bytes.Buffer) error { return writeThoughtRecordTable(out, nil) }},
		{"maps of worry", func(out *bytes.Buffer) error { return writeMapOfWorryTable(out, nil) }},
		{"biases", func(out *bytes.Buffer) error { return writeBiasTable(out, nil) }},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			var out bytes.Buffer
			if err := test.run(&out); err != nil {
				t.Fatalf("failed to write: %v", err)
			}
			if !strings.Contains(out.String(), "(none)") {
				t.Errorf("expected an explicit empty marker but got %q", out.String())
			}
		})
	}
}

func TestTruncateMarksTheCut(t *testing.T) {
	long := strings.Repeat("a", 60)

	got := truncate(long, 20)
	if len([]rune(got)) != 20 {
		t.Errorf("expected 20 runes but got %d", len([]rune(got)))
	}
	// A clipped event must never be mistaken for a short one.
	if !strings.HasSuffix(got, "…") {
		t.Errorf("expected an ellipsis but got %q", got)
	}
}

func TestTruncateCollapsesWhitespace(t *testing.T) {
	// A pasted event can carry newlines, which would otherwise break the table
	// alignment entirely.
	if got := truncate("one\n  two\tthree", 40); got != "one two three" {
		t.Errorf("expected collapsed whitespace but got %q", got)
	}
}

func TestWrapKeepsLinesWithinWidth(t *testing.T) {
	text := strings.Repeat("word ", 40)

	wrapped := wrap(text, 30, "  ")
	for _, line := range strings.Split(wrapped, "\n") {
		if width := len([]rune(strings.TrimLeft(line, " "))); width > 30 {
			t.Errorf("expected lines within 30 columns but got %d: %q", width, line)
		}
	}
}

func TestWriteMapOfWorryTableStaysNarrow(t *testing.T) {
	var out bytes.Buffer

	originID := uint32(1)
	maps := []*proto.MapOfWorry{
		{
			Id:            2,
			Event:         "a report came back covered in comments and I could not face opening it",
			DerivedFromId: &originID,
			CreatedAt:     timestamppb.New(referenceNow),
			Feelings: []*proto.Feeling{
				{Id: 1, Name: "overwhelmingly self-critical", IntensityBefore: int32Ptr(85)},
				{Id: 2, Name: "tired", IntensityBefore: int32Ptr(40)},
			},
		},
	}

	if err := writeMapOfWorryTable(&out, maps); err != nil {
		t.Fatalf("failed to write the table: %v", err)
	}

	for _, line := range strings.Split(strings.TrimRight(out.String(), "\n"), "\n") {
		if width := len([]rune(line)); width > 80 {
			t.Errorf("expected every line to fit in 80 columns but got %d: %q", width, line)
		}
	}
}

func TestStrongestFeelingAlwaysKeepsTheRemainingCount(t *testing.T) {
	// The count is what tells the reader the cell is not the whole story, so
	// truncation must never eat it.
	feelings := []*proto.Feeling{
		{Name: "utterly and comprehensively overwhelmed", IntensityBefore: int32Ptr(90)},
		{Name: "tired"},
		{Name: "flat"},
	}

	got := strongestFeeling(feelings)
	if !strings.HasSuffix(got, "+2") {
		t.Errorf("expected the remaining count to survive truncation but got %q", got)
	}
	if len([]rune(got)) > feelingColumnWidth {
		t.Errorf("expected the cell to fit in %d columns but got %d: %q", feelingColumnWidth, len([]rune(got)), got)
	}
}

func TestWriteThoughtRecordDetailMarksAFactualThought(t *testing.T) {
	var out bytes.Buffer

	record := &proto.ThoughtRecord{
		Id:        3,
		Event:     "the last train was cancelled",
		CreatedAt: timestamppb.New(referenceNow),
		UpdatedAt: timestamppb.New(referenceNow),
		Thoughts: []*proto.NegativeThought{
			{Id: 7, Body: "I will not get home before midnight", IsFactual: true},
			{Id: 8, Body: "the evening is ruined"},
		},
	}

	if err := writeThoughtRecordDetail(&out, record); err != nil {
		t.Fatalf("failed to write the detail: %v", err)
	}

	rendered := out.String()
	// Accepting that a thought was accurate is an outcome of the exercise, so
	// it is shown rather than left as a blank where a bias would be.
	if !strings.Contains(rendered, "(factual)") {
		t.Errorf("expected the factual thought to be marked but got:\n%s", rendered)
	}
	if strings.Count(rendered, "(factual)") != 1 {
		t.Errorf("expected only the judged thought to be marked but got:\n%s", rendered)
	}
}

func TestWriteThoughtRecordDetailNeverShowsBothJudgements(t *testing.T) {
	var out bytes.Buffer

	// The combination is refused by the database, but the renderer must not
	// rely on that: a thought is never both distorted and accurate.
	record := &proto.ThoughtRecord{
		Id:        3,
		Event:     "a meeting was moved without telling me",
		CreatedAt: timestamppb.New(referenceNow),
		UpdatedAt: timestamppb.New(referenceNow),
		Thoughts: []*proto.NegativeThought{
			{
				Id:        7,
				Body:      "they do not think my input matters",
				IsFactual: true,
				Biases:    []*proto.CognitiveBias{{Id: 2, Name: "mind-reading"}},
			},
		},
	}

	if err := writeThoughtRecordDetail(&out, record); err != nil {
		t.Fatalf("failed to write the detail: %v", err)
	}

	rendered := out.String()
	if strings.Contains(rendered, "(factual)") && strings.Contains(rendered, "mind-reading") {
		t.Errorf("expected only one judgement to be shown but got:\n%s", rendered)
	}
}
