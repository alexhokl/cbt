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
	if err := writeField(out, "evidence for it", record.GetEvidenceForAlternative()); err != nil {
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

// writeBehaviouralExperimentDetail renders an experiment as a vertical layout
// in the order of its columns: what was tried, the prediction, what actually
// happened, what was learned, how to build on it. Feelings sit between the
// prediction and the outcome, so each prediction can be read against how it
// actually felt.
func writeBehaviouralExperimentDetail(out io.Writer, experiment *proto.BehaviouralExperiment) error {
	header := fmt.Sprintf("Behavioural experiment %d", experiment.GetId())
	if experiment.CompletedAt != nil {
		header += fmt.Sprintf(" (completed %s)", experiment.GetCompletedAt().AsTime().Local().Format(time.DateOnly))
	} else {
		header += " (not yet completed)"
	}
	if _, err := fmt.Fprintln(out, header); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	when := "when written"
	value := experiment.GetCreatedAt().AsTime()
	if experiment.OccurredAt != nil {
		when = "when"
		value = experiment.GetOccurredAt().AsTime()
	}
	if err := writeField(out, when, value.Local().Format("2006-01-02 15:04")); err != nil {
		return err
	}

	if err := writeField(out, "what I am going to try", experiment.GetPlan()); err != nil {
		return err
	}
	if err := writeField(out, "what I predict will happen and how I will feel", experiment.GetPrediction()); err != nil {
		return err
	}

	if len(experiment.GetFeelings()) > 0 {
		if _, err := fmt.Fprintln(out, "feelings:"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		for _, feeling := range experiment.GetFeelings() {
			if err := writeFeeling(out, feeling); err != nil {
				return err
			}
		}
	}

	for _, field := range []struct {
		label string
		value string
	}{
		{"what actually happened", experiment.GetOutcome()},
		{"what I have learned from this", experiment.GetLearned()},
		{"how I can build on this", experiment.GetBuildOn()},
	} {
		if err := writeField(out, field.label, field.value); err != nil {
			return err
		}
	}

	return nil
}

// writePositiveDataLogDetail renders a log as a vertical label and paragraph
// layout: both beliefs, every rating with its date, oldest first, and every
// row of evidence. The ratings are shown as given; nothing is derived from
// them.
func writePositiveDataLogDetail(out io.Writer, log *proto.PositiveDataLog) error {
	if _, err := fmt.Fprintf(out, "Positive data log %d\n", log.GetId()); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	if err := writeField(out, "self-critical belief", log.GetBelief()); err != nil {
		return err
	}
	if err := writeField(out, "alternative belief", log.GetAlternativeBelief()); err != nil {
		return err
	}

	if len(log.GetRatings()) > 0 {
		if _, err := fmt.Fprintln(out, "how strongly I believe this:"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		for _, rating := range log.GetRatings() {
			if err := writeBeliefRating(out, rating); err != nil {
				return err
			}
		}
	}

	if len(log.GetEvidence()) > 0 {
		if _, err := fmt.Fprintln(out, "evidence to support the alternative belief and weaken the old belief:"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		for _, evidence := range log.GetEvidence() {
			prefix := fmt.Sprintf("[%d] %s  ", evidence.GetId(), formatEventDate(evidence.NotedAt, evidence.GetCreatedAt().AsTime()))
			// Continuation lines align under the text rather than the id.
			indent := labelIndent + strings.Repeat(" ", len([]rune(prefix)))
			if _, err := fmt.Fprintf(out, "%s%s%s\n", labelIndent, prefix, wrap(evidence.GetBody(), detailWrapWidth-len([]rune(prefix)), indent)); err != nil {
				return fmt.Errorf("failed to write output: %w", err)
			}
		}
	}

	return nil
}

// writeBeliefRating renders one sitting's rating of both beliefs. A belief
// left unrated at that sitting is shown as "-", not as zero.
func writeBeliefRating(out io.Writer, rating *proto.BeliefRating) error {
	belief, alternative := "-", "-"
	if rating.BeliefPercent != nil {
		belief = fmt.Sprintf("%d%%", rating.GetBeliefPercent())
	}
	if rating.AlternativePercent != nil {
		alternative = fmt.Sprintf("%d%%", rating.GetAlternativePercent())
	}

	if _, err := fmt.Fprintf(out, "%s%s  belief %-4s  alternative %s\n", labelIndent, rating.GetRatedAt().AsTime().Local().Format("2006-01-02 15:04"), belief, alternative); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeFormulationDetail renders a formulation as a vertical label and
// paragraph layout, in the order the exercise is written. Empty columns are
// omitted, so a formulation in progress reads as what has been written.
func writeFormulationDetail(out io.Writer, formulation *proto.Formulation) error {
	if _, err := fmt.Fprintf(out, "Formulation %d\n", formulation.GetId()); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	for _, column := range formulationColumns {
		if err := writeField(out, column.label, column.value(formulation)); err != nil {
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
	if evidence := thought.GetEvidence(); evidence != "" {
		// Continuation lines align under the text rather than the label.
		line += fmt.Sprintf("\n%s      evidence: %s", labelIndent, wrap(evidence, detailWrapWidth-len("evidence: "), labelIndent+"                "))
	}
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
	if thought.BeliefAfter != nil {
		line += fmt.Sprintf("\n%s      (still believe %d%%)", labelIndent, thought.GetBeliefAfter())
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
