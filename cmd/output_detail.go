package cmd

import (
	"fmt"
	"io"
	"strings"
	"time"

	"github.com/alexhokl/cbt/proto"
)

// labelIndent is the indent applied to wrapped prose so a paragraph reads as
// one block under its label.
const labelIndent = "  "

// writeThoughtRecordDetail renders a record as a vertical label and paragraph
// layout rather than a table. Six columns of prose cannot be aligned into
// readable columns, and the detail view is where the full text belongs.
//
// Empty columns are omitted entirely. A record in progress should look like
// what has been written so far, not like a form with blanks in it.
func writeThoughtRecordDetail(out io.Writer, record *proto.ThoughtRecord) error {
	header := fmt.Sprintf("Thought record %d", record.GetId())
	if record.ChallengedAt != nil {
		header += fmt.Sprintf(" (challenged %s)", record.GetChallengedAt().AsTime().Local().Format(time.DateOnly))
	} else {
		header += " (not yet challenged)"
	}
	if _, err := fmt.Fprintln(out, header); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	when := "when written"
	value := record.GetCreatedAt().AsTime()
	if record.OccurredAt != nil {
		when = "when"
		value = record.GetOccurredAt().AsTime()
	}
	if err := writeField(out, when, value.Local().Format("2006-01-02 15:04")); err != nil {
		return err
	}

	if err := writeField(out, "event", record.GetEvent()); err != nil {
		return err
	}

	if len(record.GetThoughts()) > 0 {
		if _, err := fmt.Fprintln(out, "\nthoughts:"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		for _, thought := range record.GetThoughts() {
			if err := writeThought(out, thought); err != nil {
				return err
			}
		}
	}

	if len(record.GetFeelings()) > 0 {
		if _, err := fmt.Fprintln(out, "\nfeelings:"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		for _, feeling := range record.GetFeelings() {
			if err := writeFeeling(out, feeling); err != nil {
				return err
			}
		}
	}

	if _, err := fmt.Fprintln(out); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}
	if err := writeField(out, "another way to look at this", record.GetAlternativeView()); err != nil {
		return err
	}
	if err := writeField(out, "how I feel now", record.GetFeelingsNow()); err != nil {
		return err
	}

	return nil
}

// writeMapOfWorryDetail renders a map as a vertical layout following the chain
// the exercise traces: event, thoughts, meaning, sensations, feelings,
// behaviour.
func writeMapOfWorryDetail(out io.Writer, mapOfWorry *proto.MapOfWorry) error {
	header := fmt.Sprintf("Map of worry %d", mapOfWorry.GetId())
	if mapOfWorry.DerivedFromId != nil {
		header += fmt.Sprintf(" (alternative to %d)", mapOfWorry.GetDerivedFromId())
	}
	if _, err := fmt.Fprintln(out, header); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	when := "when written"
	value := mapOfWorry.GetCreatedAt().AsTime()
	if mapOfWorry.OccurredAt != nil {
		when = "when"
		value = mapOfWorry.GetOccurredAt().AsTime()
	}
	if err := writeField(out, when, value.Local().Format("2006-01-02 15:04")); err != nil {
		return err
	}

	fields := []struct {
		label string
		value string
	}{
		{"event", mapOfWorry.GetEvent()},
		{"thoughts", mapOfWorry.GetThoughts()},
		{"what these thoughts mean", mapOfWorry.GetWhatTheseThoughtsMean()},
		{"physical sensations", mapOfWorry.GetPhysicalSensations()},
	}
	for _, field := range fields {
		if err := writeField(out, field.label, field.value); err != nil {
			return err
		}
	}

	if len(mapOfWorry.GetFeelings()) > 0 {
		if _, err := fmt.Fprintln(out, "\nfeelings:"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		for _, feeling := range mapOfWorry.GetFeelings() {
			if err := writeFeeling(out, feeling); err != nil {
				return err
			}
		}
		if _, err := fmt.Fprintln(out); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	return writeField(out, "resultant behaviour", mapOfWorry.GetResultantBehaviour())
}

// writeMapContrast renders a map alongside the maps it should be read against.
// The contrast between two readings of the same event is the therapeutic
// payload of the exercise, so the alternatives are printed with it rather than
// left to a second command.
func writeMapContrast(out io.Writer, response *proto.GetMapOfWorryResponse) error {
	if response.GetDerivedFrom() != nil {
		if _, err := fmt.Fprintln(out, "--- the map this reworks ---"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		if err := writeMapOfWorryDetail(out, response.GetDerivedFrom()); err != nil {
			return err
		}
		if _, err := fmt.Fprintln(out, "\n--- the reworking ---"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	if err := writeMapOfWorryDetail(out, response.GetMap()); err != nil {
		return err
	}

	for _, alternative := range response.GetAlternatives() {
		if _, err := fmt.Fprintln(out, "\n--- an alternative reading of the same event ---"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		if err := writeMapOfWorryDetail(out, alternative); err != nil {
			return err
		}
	}

	return nil
}

// writeField renders one labelled paragraph, wrapped and indented. An empty
// value produces no output at all, so a record in progress reads as what has
// been written rather than as a form with blanks.
func writeField(out io.Writer, label, value string) error {
	if strings.TrimSpace(value) == "" {
		return nil
	}

	if _, err := fmt.Fprintf(out, "%s:\n%s%s\n", label, labelIndent, wrap(value, detailWrapWidth, labelIndent)); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeThought renders one negative thought with its biases, marking the
// strongest one.
func writeThought(out io.Writer, thought *proto.NegativeThought) error {
	marker := " "
	if thought.GetIsHot() {
		// The strongest thought is conventionally circled on paper; an
		// asterisk is the closest a terminal gets.
		marker = "*"
	}

	line := fmt.Sprintf("%s [%d] %s", marker, thought.GetId(), wrap(thought.GetBody(), detailWrapWidth, labelIndent+"      "))
	// A thought is never both distorted and accurate, so at most one of these
	// ever appears.
	switch {
	case len(thought.GetBiases()) > 0:
		names := make([]string, 0, len(thought.GetBiases()))
		for _, bias := range thought.GetBiases() {
			names = append(names, bias.GetName())
		}
		line += fmt.Sprintf("\n%s      (%s)", labelIndent, strings.Join(names, ", "))
	case thought.GetIsFactual():
		line += fmt.Sprintf("\n%s      (factual)", labelIndent)
	}

	if _, err := fmt.Fprintf(out, "%s%s\n", labelIndent, line); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeFeeling renders one feeling with its rating, showing the before and
// after ratings together once the record has been challenged. Seeing the two
// side by side is the point of re-rating.
func writeFeeling(out io.Writer, feeling *proto.Feeling) error {
	rating := "unrated"
	if feeling.IntensityBefore != nil {
		rating = fmt.Sprintf("%d%%", feeling.GetIntensityBefore())
	}
	if feeling.IntensityAfter != nil {
		rating += fmt.Sprintf(" -> %d%%", feeling.GetIntensityAfter())
	}

	if _, err := fmt.Fprintf(out, "%s  [%d] %s %s\n", labelIndent, feeling.GetId(), feeling.GetName(), rating); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}
