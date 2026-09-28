package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type updateThoughtRecordOptions struct {
	Event           string
	At              string
	ClearAt         bool
	AlternativeView string
	FeelingsNow     string
}

var updateThoughtRecordOpts updateThoughtRecordOptions

// updateThoughtRecordCmd changes the free text columns of a thought record.
var updateThoughtRecordCmd = &cobra.Command{
	Use:     "thought-record [id]",
	Aliases: []string{"record", "tr"},
	Short:   "Change the columns of a thought record",
	Long: `Change the columns of a thought record.

Only the columns you name are changed, so a record can be filled in a piece at
a time. To work through a record properly, use "cbt challenge" instead: it
records the same columns and marks the record as done.`,
	Example: `  cbt update thought-record 3 --event "a clearer description of what happened"
  cbt update thought-record 3 --at yesterday`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runUpdateThoughtRecord,
}

func init() {
	updateCmd.AddCommand(updateThoughtRecordCmd)

	flags := updateThoughtRecordCmd.Flags()
	flags.StringVar(&updateThoughtRecordOpts.Event, "event", "", "What happened")
	flags.StringVar(&updateThoughtRecordOpts.At, "at", "", "When the event happened (YYYY-MM-DD, \"yesterday\", \"3h ago\")")
	flags.BoolVar(&updateThoughtRecordOpts.ClearAt, "clear-at", false, "Forget when the event happened")
	flags.StringVar(&updateThoughtRecordOpts.AlternativeView, "alternative", "", "Is there any other way you can look at this?")
	flags.StringVar(&updateThoughtRecordOpts.FeelingsNow, "feelings-now", "", "How do you feel now?")

	updateThoughtRecordCmd.MarkFlagsMutuallyExclusive("at", "clear-at")
}

func runUpdateThoughtRecord(cmd *cobra.Command, args []string) error {
	req, err := buildUpdateThoughtRecordRequest(args, updateThoughtRecordOpts, cmd.Flags(), time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	record, err := proto.NewRecordServiceClient(conn).UpdateThoughtRecord(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to update the thought record: %w", err)
	}

	return writeThoughtRecordLine(cmd.OutOrStdout(), record)
}

// flagLookup is the subset of pflag.FlagSet used to tell "not given" from
// "given as empty". It is an interface so the request builder can be tested
// without constructing a command.
type flagLookup interface {
	Changed(name string) bool
}

// buildUpdateThoughtRecordRequest assembles the wire request from the parsed
// flags. Only flags the user actually typed are sent: a column left off the
// command line keeps whatever it already held, which is what allows a record
// to be completed a piece at a time. Sending every flag unconditionally would
// blank the columns the user did not mention.
func buildUpdateThoughtRecordRequest(args []string, opts updateThoughtRecordOptions, flags flagLookup, now time.Time) (*proto.UpdateThoughtRecordRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	req := &proto.UpdateThoughtRecordRequest{Id: id, ClearOccurredAt: opts.ClearAt}

	if flags.Changed("event") {
		req.Event = &opts.Event
	}
	if flags.Changed("alternative") {
		req.AlternativeView = &opts.AlternativeView
	}
	if flags.Changed("feelings-now") {
		req.FeelingsNow = &opts.FeelingsNow
	}
	if flags.Changed("at") {
		occurredAt, err := parseEventTime(opts.At, now)
		if err != nil {
			return nil, err
		}
		if occurredAt != nil {
			req.OccurredAt = timestamppb.New(*occurredAt)
		}
	}

	return req, nil
}
