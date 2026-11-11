package cmd

import (
	"fmt"
	"io"
	"sort"
	"strings"
	"text/tabwriter"
	"time"

	"github.com/alexhokl/cbt/proto"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// eventColumnWidth and feelingColumnWidth are how much of each is shown in a
// listing. Six prose columns will not survive an eighty column terminal, so
// the table stays narrow and the full text is left to the detail view.
//
// The widths are chosen so the widest row fits inside eighty columns once
// tabwriter has added its two space padding: 4 for the id, 13 for the date, 32
// for the event, 20 for the feeling and 10 for the last column.
const (
	eventColumnWidth   = 30
	feelingColumnWidth = 18
)

// detailWrapWidth is the column at which prose is wrapped in the detail view.
// It is comfortably inside eighty columns once the label indent is accounted
// for.
const detailWrapWidth = 72

// writeThoughtRecordTable renders thought records as a narrow aligned table.
// The columns answer the two questions a listing is for: what happened, and is
// there still work to do on it.
func writeThoughtRecordTable(out io.Writer, records []*proto.ThoughtRecord) error {
	if len(records) == 0 {
		if _, err := fmt.Fprintln(out, "  (none)"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		return nil
	}

	writer := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "ID\tWHEN\tEVENT\tFEELING\tCHALLENGED"); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	for _, record := range records {
		challenged := "no"
		if record.ChallengedAt != nil {
			challenged = "yes"
		}

		if _, err := fmt.Fprintf(
			writer,
			"%d\t%s\t%s\t%s\t%s\n",
			record.GetId(),
			formatEventDate(record.OccurredAt, record.GetCreatedAt().AsTime()),
			truncate(record.GetEvent(), eventColumnWidth),
			strongestFeeling(record.GetFeelings()),
			challenged,
		); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeMapOfWorryTable renders maps of worry as a narrow aligned table.
func writeMapOfWorryTable(out io.Writer, maps []*proto.MapOfWorry) error {
	if len(maps) == 0 {
		if _, err := fmt.Fprintln(out, "  (none)"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		return nil
	}

	writer := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "ID\tWHEN\tEVENT\tFEELING\tALT OF"); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	for _, mapOfWorry := range maps {
		alternativeTo := "-"
		if mapOfWorry.DerivedFromId != nil {
			alternativeTo = fmt.Sprintf("%d", mapOfWorry.GetDerivedFromId())
		}

		if _, err := fmt.Fprintf(
			writer,
			"%d\t%s\t%s\t%s\t%s\n",
			mapOfWorry.GetId(),
			formatEventDate(mapOfWorry.OccurredAt, mapOfWorry.GetCreatedAt().AsTime()),
			truncate(mapOfWorry.GetEvent(), eventColumnWidth),
			strongestFeeling(mapOfWorry.GetFeelings()),
			alternativeTo,
		); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeBehaviouralExperimentTable renders behavioural experiments as a narrow
// aligned table. Like the thought record listing, it answers what was tried
// and whether there is still work to do on it.
func writeBehaviouralExperimentTable(out io.Writer, experiments []*proto.BehaviouralExperiment) error {
	if len(experiments) == 0 {
		if _, err := fmt.Fprintln(out, "  (none)"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		return nil
	}

	writer := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "ID\tWHEN\tPLAN\tFEELING\tCOMPLETED"); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	for _, experiment := range experiments {
		completed := "no"
		if experiment.CompletedAt != nil {
			completed = "yes"
		}

		if _, err := fmt.Fprintf(
			writer,
			"%d\t%s\t%s\t%s\t%s\n",
			experiment.GetId(),
			formatEventDate(experiment.OccurredAt, experiment.GetCreatedAt().AsTime()),
			truncate(experiment.GetPlan(), eventColumnWidth),
			strongestFeeling(experiment.GetFeelings()),
			completed,
		); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writePositiveDataLogTable renders positive data logs as a narrow aligned
// table. Beside the belief it shows the first and latest rating of each
// belief exactly as the user gave them, and how much evidence has been
// written down.
func writePositiveDataLogTable(out io.Writer, logs []*proto.PositiveDataLog) error {
	if len(logs) == 0 {
		if _, err := fmt.Fprintln(out, "  (none)"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		return nil
	}

	writer := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "ID\tUPDATED\tBELIEF\tBELIEVE\tALT\tEVIDENCE"); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	for _, log := range logs {
		if _, err := fmt.Fprintf(
			writer,
			"%d\t%s\t%s\t%s\t%s\t%d\n",
			log.GetId(),
			log.GetUpdatedAt().AsTime().Local().Format(time.DateOnly),
			truncate(log.GetBelief(), eventColumnWidth),
			ratingSpan(log.GetRatings(), (*proto.BeliefRating).GetBeliefPercent, func(r *proto.BeliefRating) bool { return r.BeliefPercent != nil }),
			ratingSpan(log.GetRatings(), (*proto.BeliefRating).GetAlternativePercent, func(r *proto.BeliefRating) bool { return r.AlternativePercent != nil }),
			len(log.GetEvidence()),
		); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// ratingSpan renders the first and latest rating of one belief, such as
// "70->55", or the single rating when there has been only one. Sittings that
// left this belief unrated are skipped.
func ratingSpan(ratings []*proto.BeliefRating, value func(*proto.BeliefRating) int32, rated func(*proto.BeliefRating) bool) string {
	var given []int32
	for _, rating := range ratings {
		if rated(rating) {
			given = append(given, value(rating))
		}
	}

	switch len(given) {
	case 0:
		return "-"
	case 1:
		return fmt.Sprintf("%d", given[0])
	default:
		return fmt.Sprintf("%d->%d", given[0], given[len(given)-1])
	}
}

// writeFormulationTable renders formulations as a narrow aligned table. A
// formulation can be started from any column, so the summary is its beliefs
// where written and otherwise its first written column.
func writeFormulationTable(out io.Writer, formulations []*proto.Formulation) error {
	if len(formulations) == 0 {
		if _, err := fmt.Fprintln(out, "  (none)"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		return nil
	}

	writer := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "ID\tUPDATED\tSUMMARY"); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	for _, formulation := range formulations {
		if _, err := fmt.Fprintf(
			writer,
			"%d\t%s\t%s\n",
			formulation.GetId(),
			formulation.GetUpdatedAt().AsTime().Local().Format(time.DateOnly),
			truncate(formulationSummary(formulation), formulationSummaryWidth),
		); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// formulationSummaryWidth leaves room for the id and date columns inside
// eighty columns: 4 for the id, 12 for the date, and their padding.
const formulationSummaryWidth = 60

// formulationSummary is the column that stands for a formulation in a
// listing: its beliefs where written, otherwise its first written column.
func formulationSummary(formulation *proto.Formulation) string {
	if beliefs := strings.TrimSpace(formulation.GetBeliefs()); beliefs != "" {
		return beliefs
	}
	for _, column := range formulationColumns {
		if value := strings.TrimSpace(column.value(formulation)); value != "" {
			return value
		}
	}
	return "-"
}

// writeBiasTable renders the cognitive bias vocabulary.
func writeBiasTable(out io.Writer, biases []*proto.CognitiveBias) error {
	if len(biases) == 0 {
		if _, err := fmt.Fprintln(out, "  (none)"); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		return nil
	}

	writer := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	if _, err := fmt.Fprintln(writer, "ID\tNAME\tSOURCE"); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	for _, bias := range biases {
		source := "yours"
		if bias.GetIsBuiltin() {
			source = "builtin"
		}
		if _, err := fmt.Fprintf(writer, "%d\t%s\t%s\n", bias.GetId(), bias.GetName(), source); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
	}

	if err := writer.Flush(); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeThoughtRecordLine renders a single record as a one line confirmation.
func writeThoughtRecordLine(out io.Writer, record *proto.ThoughtRecord) error {
	details := []string{fmt.Sprintf("id %d", record.GetId())}
	if len(record.GetThoughts()) > 0 {
		details = append(details, fmt.Sprintf("thoughts %d", len(record.GetThoughts())))
	}
	if len(record.GetFeelings()) > 0 {
		details = append(details, fmt.Sprintf("feelings %d", len(record.GetFeelings())))
	}
	if record.ChallengedAt != nil {
		details = append(details, "challenged")
	}

	if _, err := fmt.Fprintf(out, "%s (%s)\n", truncate(record.GetEvent(), eventColumnWidth), strings.Join(details, ", ")); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeMapOfWorryLine renders a single map as a one line confirmation.
func writeMapOfWorryLine(out io.Writer, mapOfWorry *proto.MapOfWorry) error {
	details := []string{fmt.Sprintf("id %d", mapOfWorry.GetId())}
	if mapOfWorry.DerivedFromId != nil {
		details = append(details, fmt.Sprintf("alternative to %d", mapOfWorry.GetDerivedFromId()))
	}
	if len(mapOfWorry.GetFeelings()) > 0 {
		details = append(details, fmt.Sprintf("feelings %d", len(mapOfWorry.GetFeelings())))
	}

	if _, err := fmt.Fprintf(out, "%s (%s)\n", truncate(mapOfWorry.GetEvent(), eventColumnWidth), strings.Join(details, ", ")); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeBehaviouralExperimentLine renders a single experiment as a one line
// confirmation.
func writeBehaviouralExperimentLine(out io.Writer, experiment *proto.BehaviouralExperiment) error {
	details := []string{fmt.Sprintf("id %d", experiment.GetId())}
	if len(experiment.GetFeelings()) > 0 {
		details = append(details, fmt.Sprintf("feelings %d", len(experiment.GetFeelings())))
	}
	if experiment.CompletedAt != nil {
		details = append(details, "completed")
	}

	if _, err := fmt.Fprintf(out, "%s (%s)\n", truncate(experiment.GetPlan(), eventColumnWidth), strings.Join(details, ", ")); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writePositiveDataLogLine renders a single log as a one line confirmation.
func writePositiveDataLogLine(out io.Writer, log *proto.PositiveDataLog) error {
	details := []string{fmt.Sprintf("id %d", log.GetId())}
	if len(log.GetEvidence()) > 0 {
		details = append(details, fmt.Sprintf("evidence %d", len(log.GetEvidence())))
	}
	if len(log.GetRatings()) > 0 {
		details = append(details, fmt.Sprintf("ratings %d", len(log.GetRatings())))
	}

	if _, err := fmt.Fprintf(out, "%s (%s)\n", truncate(log.GetBelief(), eventColumnWidth), strings.Join(details, ", ")); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// writeFormulationLine renders a single formulation as a one line
// confirmation.
func writeFormulationLine(out io.Writer, formulation *proto.Formulation) error {
	written := 0
	for _, column := range formulationColumns {
		if strings.TrimSpace(column.value(formulation)) != "" {
			written++
		}
	}

	if _, err := fmt.Fprintf(out, "%s (id %d, columns %d of %d)\n", truncate(formulationSummary(formulation), eventColumnWidth), formulation.GetId(), written, len(formulationColumns)); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}

// formatEventDate renders when an event happened, falling back to when the
// record was written where the user did not say. The fallback is marked with a
// tilde so the two are never confused.
func formatEventDate(occurredAt *timestamppb.Timestamp, createdAt time.Time) string {
	if occurredAt != nil {
		return occurredAt.AsTime().Local().Format(time.DateOnly)
	}
	return "~" + createdAt.Local().Format(time.DateOnly)
}

// strongestFeeling renders the highest rated feeling, which is the one worth
// showing when only one fits. Unrated feelings sort below rated ones: a rating
// is a judgement the user made, and an absent one is not a zero.
func strongestFeeling(feelings []*proto.Feeling) string {
	if len(feelings) == 0 {
		return "-"
	}

	sorted := make([]*proto.Feeling, len(feelings))
	copy(sorted, feelings)
	sort.SliceStable(sorted, func(i, j int) bool {
		left, right := sorted[i], sorted[j]
		if (left.IntensityBefore == nil) != (right.IntensityBefore == nil) {
			return left.IntensityBefore != nil
		}
		if left.IntensityBefore == nil {
			return false
		}
		return left.GetIntensityBefore() > right.GetIntensityBefore()
	})

	strongest := sorted[0]
	suffix := ""
	if len(sorted) > 1 {
		suffix = fmt.Sprintf(" +%d", len(sorted)-1)
	}

	rendered := strongest.GetName()
	if strongest.IntensityBefore != nil {
		rendered = fmt.Sprintf("%s %d%%", rendered, strongest.GetIntensityBefore())
	}

	// The count of remaining feelings is never truncated away: it is what
	// tells the reader the cell is not the whole story.
	return truncate(rendered, feelingColumnWidth-len([]rune(suffix))) + suffix
}

// truncate shortens a string to the given width, marking the cut with an
// ellipsis so a clipped event is never mistaken for a short one.
func truncate(value string, width int) string {
	collapsed := strings.Join(strings.Fields(value), " ")
	runes := []rune(collapsed)
	if len(runes) <= width {
		return collapsed
	}
	return string(runes[:width-1]) + "…"
}

// wrap breaks prose onto lines no longer than the given width, indenting every
// line after the first so a wrapped paragraph reads as one block.
func wrap(value string, width int, indent string) string {
	fields := strings.Fields(value)
	if len(fields) == 0 {
		return ""
	}

	var lines []string
	current := fields[0]
	for _, field := range fields[1:] {
		if len([]rune(current))+1+len([]rune(field)) > width {
			lines = append(lines, current)
			current = field
			continue
		}
		current += " " + field
	}
	lines = append(lines, current)

	return strings.Join(lines, "\n"+indent)
}
