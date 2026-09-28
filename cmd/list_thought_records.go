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

type listThoughtRecordsOptions struct {
	Unchallenged bool
	Challenged   bool
	Since        string
	Search       string
}

var listThoughtRecordsOpts listThoughtRecordsOptions

// listThoughtRecordsCmd lists thought records.
var listThoughtRecordsCmd = &cobra.Command{
	Use:     "thought-records",
	Aliases: []string{"records", "trs"},
	Short:   "List thought records",
	Long: `List thought records, most recent event first.

--unchallenged is the day's work queue: the records that have been written but
not yet worked through.`,
	Example: `  cbt list thought-records
  cbt list thought-records --unchallenged
  cbt list thought-records --since 7d --search meeting`,
	Args:        cobra.NoArgs,
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runListThoughtRecords,
}

func init() {
	listCmd.AddCommand(listThoughtRecordsCmd)

	flags := listThoughtRecordsCmd.Flags()
	flags.BoolVar(&listThoughtRecordsOpts.Unchallenged, "unchallenged", false, "Only records not yet challenged")
	flags.BoolVar(&listThoughtRecordsOpts.Challenged, "challenged", false, "Only records already challenged")
	flags.StringVar(&listThoughtRecordsOpts.Since, "since", "", "Only events on or after this time (YYYY-MM-DD, \"7d\", \"yesterday\")")
	flags.StringVar(&listThoughtRecordsOpts.Search, "search", "", "Match the event, the alternative view or a thought")

	listThoughtRecordsCmd.MarkFlagsMutuallyExclusive("unchallenged", "challenged")
}

func runListThoughtRecords(cmd *cobra.Command, _ []string) error {
	req, err := buildListThoughtRecordsRequest(listThoughtRecordsOpts, time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	response, err := proto.NewRecordServiceClient(conn).ListThoughtRecords(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to list the thought records: %w", err)
	}

	return writeThoughtRecordTable(cmd.OutOrStdout(), response.GetRecords())
}

// buildListThoughtRecordsRequest assembles the wire request from the parsed
// flags. The two challenge flags are mutually exclusive at the flag level, so
// only one of them can be set here.
func buildListThoughtRecordsRequest(opts listThoughtRecordsOptions, now time.Time) (*proto.ListThoughtRecordsRequest, error) {
	req := &proto.ListThoughtRecordsRequest{Search: opts.Search}

	switch {
	case opts.Unchallenged:
		unchallenged := false
		req.Challenged = &unchallenged
	case opts.Challenged:
		challenged := true
		req.Challenged = &challenged
	}

	since, err := parseSince(opts.Since, now)
	if err != nil {
		return nil, err
	}
	if since != nil {
		req.Since = timestamppb.New(*since)
	}

	return req, nil
}

// parseSince interprets the --since flag. It accepts the same forms as --at
// plus a bare duration such as "7d", which reads more naturally as a window
// than "7d ago" does.
func parseSince(value string, now time.Time) (*time.Time, error) {
	trimmed := strings.TrimSpace(value)
	if trimmed == "" {
		return nil, nil
	}

	// A bare "7d" is a window looking back, so it is rewritten into the
	// relative form the event time parser already understands.
	if len(trimmed) > 1 && !strings.HasSuffix(strings.ToLower(trimmed), " ago") {
		unit := trimmed[len(trimmed)-1:]
		if strings.Contains("mhdw", strings.ToLower(unit)) {
			if _, err := strconv.Atoi(trimmed[:len(trimmed)-1]); err == nil {
				trimmed += " ago"
			}
		}
	}

	return parseEventTime(trimmed, now)
}
