package cmd

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type createThoughtRecordOptions struct {
	At              string
	Thoughts        []string
	HotThought      string
	Biases          []string
	Feelings        []string
	AlternativeView string
	FeelingsNow     string
}

var createThoughtRecordOpts createThoughtRecordOptions

// createThoughtRecordCmd creates a six column thought record.
var createThoughtRecordCmd = &cobra.Command{
	Use:     "thought-record [event]",
	Aliases: []string{"record", "tr"},
	Short:   "Create a thought record",
	Long: `Create a thought record from an event.

Only the event is required. A record is normally opened in the moment with
little more than that, and completed later with "cbt challenge".`,
	Example: `  cbt create thought-record "a meeting was moved without telling me"
  cbt create thought-record "a message I sent went unanswered" --thought "I must have said something wrong" --feeling anxious=70
  cbt create thought-record "my name was left off the invite" --hot-thought "they do not think my input matters" --bias mind-reading
  cbt create thought-record "the last train was cancelled" --at "3h ago" --feeling annoyed=80 --feeling tired=40`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runCreateThoughtRecord,
}

func init() {
	createCmd.AddCommand(createThoughtRecordCmd)

	flags := createThoughtRecordCmd.Flags()
	flags.StringVar(&createThoughtRecordOpts.At, "at", "", "When the event happened (YYYY-MM-DD, \"yesterday\", \"3h ago\")")
	flags.StringArrayVar(&createThoughtRecordOpts.Thoughts, "thought", nil, "A negative thought about the event (repeatable)")
	flags.StringVar(&createThoughtRecordOpts.HotThought, "hot-thought", "", "The strongest thought, the one worth challenging first")
	flags.StringArrayVar(&createThoughtRecordOpts.Biases, "bias", nil, "A cognitive bias in the strongest thought, by name (repeatable)")
	flags.StringArrayVar(&createThoughtRecordOpts.Feelings, "feeling", nil, "A feeling and its 0-100 rating, as name=rating (repeatable)")
	flags.StringVar(&createThoughtRecordOpts.AlternativeView, "alternative", "", "Another way to look at this, if you already have one")
	flags.StringVar(&createThoughtRecordOpts.FeelingsNow, "feelings-now", "", "How you feel now, if you already know")
}

func runCreateThoughtRecord(cmd *cobra.Command, args []string) error {
	req, err := buildCreateThoughtRecordRequest(args, createThoughtRecordOpts, time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	record, err := proto.NewRecordServiceClient(conn).CreateThoughtRecord(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to create the thought record: %w", err)
	}

	return writeThoughtRecordLine(cmd.OutOrStdout(), record)
}

// buildCreateThoughtRecordRequest assembles the wire request from the parsed
// flags.
//
// The --bias flag attaches to the strongest thought rather than to the record,
// because a bias belongs to a thought: two thoughts about the same event
// routinely carry different distortions. Naming biases without a strongest
// thought is therefore rejected rather than silently dropped.
func buildCreateThoughtRecordRequest(args []string, opts createThoughtRecordOptions, now time.Time) (*proto.CreateThoughtRecordRequest, error) {
	occurredAt, err := parseEventTime(opts.At, now)
	if err != nil {
		return nil, err
	}

	if len(opts.Biases) > 0 && strings.TrimSpace(opts.HotThought) == "" {
		return nil, fmt.Errorf("--bias applies to the strongest thought, so --hot-thought is required alongside it")
	}

	req := &proto.CreateThoughtRecordRequest{
		Event:           args[0],
		AlternativeView: opts.AlternativeView,
		FeelingsNow:     opts.FeelingsNow,
	}
	if occurredAt != nil {
		req.OccurredAt = timestamppb.New(*occurredAt)
	}

	if hot := strings.TrimSpace(opts.HotThought); hot != "" {
		req.Thoughts = append(req.Thoughts, &proto.ThoughtInput{
			Body:   hot,
			IsHot:  true,
			Biases: opts.Biases,
		})
	}
	for _, body := range opts.Thoughts {
		req.Thoughts = append(req.Thoughts, &proto.ThoughtInput{Body: body})
	}

	feelings, err := parseFeelings(opts.Feelings)
	if err != nil {
		return nil, err
	}
	req.Feelings = feelings

	return req, nil
}

// parseFeelings turns the repeatable name=rating flag into wire feelings. The
// rating is optional: writing down that you felt ashamed is worth something
// even when you are in no state to put a number on it.
func parseFeelings(values []string) ([]*proto.FeelingInput, error) {
	feelings := make([]*proto.FeelingInput, 0, len(values))
	for _, value := range values {
		name, rating, hasRating := strings.Cut(value, "=")
		name = strings.TrimSpace(name)
		if name == "" {
			return nil, fmt.Errorf("invalid feeling %q: expected a name, optionally followed by =rating", value)
		}

		feeling := &proto.FeelingInput{Name: name}
		if hasRating {
			intensity, err := strconv.Atoi(strings.TrimSpace(strings.TrimSuffix(rating, "%")))
			if err != nil {
				return nil, fmt.Errorf("invalid rating in %q: expected a whole number between 0 and 100", value)
			}
			if intensity < 0 || intensity > 100 {
				return nil, fmt.Errorf("invalid rating in %q: expected a number between 0 and 100", value)
			}
			// Range checked immediately above, so the conversion is safe.
			narrowed := int32(intensity) // #nosec G109
			feeling.Intensity = &narrowed
		}

		feelings = append(feelings, feeling)
	}

	return feelings, nil
}
