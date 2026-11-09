package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type listBehaviouralExperimentsOptions struct {
	NotCompleted bool
	Completed    bool
	Since        string
	Search       string
}

var listBehaviouralExperimentsOpts listBehaviouralExperimentsOptions

// listBehaviouralExperimentsCmd lists behavioural experiments.
var listBehaviouralExperimentsCmd = &cobra.Command{
	Use:     "experiments",
	Aliases: []string{"behavioural-experiments", "bes"},
	Short:   "List behavioural experiments",
	Long: `List behavioural experiments, most recent first.

--not-completed is the queue of experiments planned but not yet written up.`,
	Example: `  cbt list experiments
  cbt list experiments --not-completed
  cbt list experiments --since 30d --search meeting`,
	Args:        cobra.NoArgs,
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runListBehaviouralExperiments,
}

func init() {
	listCmd.AddCommand(listBehaviouralExperimentsCmd)

	flags := listBehaviouralExperimentsCmd.Flags()
	flags.BoolVar(&listBehaviouralExperimentsOpts.NotCompleted, "not-completed", false, "Only experiments not yet written up")
	flags.BoolVar(&listBehaviouralExperimentsOpts.Completed, "completed", false, "Only experiments already written up")
	flags.StringVar(&listBehaviouralExperimentsOpts.Since, "since", "", "Only experiments on or after this time (YYYY-MM-DD, \"30d\", \"yesterday\")")
	flags.StringVar(&listBehaviouralExperimentsOpts.Search, "search", "", "Match any column of the experiment")

	listBehaviouralExperimentsCmd.MarkFlagsMutuallyExclusive("not-completed", "completed")
}

func runListBehaviouralExperiments(cmd *cobra.Command, _ []string) error {
	req, err := buildListBehaviouralExperimentsRequest(listBehaviouralExperimentsOpts, time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	response, err := proto.NewRecordServiceClient(conn).ListBehaviouralExperiments(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to list the behavioural experiments: %w", err)
	}

	return writeBehaviouralExperimentTable(cmd.OutOrStdout(), response.GetExperiments())
}

// buildListBehaviouralExperimentsRequest assembles the wire request from the
// parsed flags. The two completion flags are mutually exclusive at the flag
// level, so only one of them can be set here.
func buildListBehaviouralExperimentsRequest(opts listBehaviouralExperimentsOptions, now time.Time) (*proto.ListBehaviouralExperimentsRequest, error) {
	req := &proto.ListBehaviouralExperimentsRequest{Search: opts.Search}

	switch {
	case opts.NotCompleted:
		notCompleted := false
		req.Completed = &notCompleted
	case opts.Completed:
		completed := true
		req.Completed = &completed
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
