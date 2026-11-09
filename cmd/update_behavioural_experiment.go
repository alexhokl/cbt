package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type updateBehaviouralExperimentOptions struct {
	Plan       string
	At         string
	ClearAt    bool
	Prediction string
	Outcome    string
	Learned    string
	BuildOn    string
}

var updateBehaviouralExperimentOpts updateBehaviouralExperimentOptions

// updateBehaviouralExperimentCmd changes the free text columns of a
// behavioural experiment.
var updateBehaviouralExperimentCmd = &cobra.Command{
	Use:     "experiment [id]",
	Aliases: []string{"behavioural-experiment", "be"},
	Short:   "Change the columns of a behavioural experiment",
	Long: `Change the columns of a behavioural experiment.

Only the columns you name are changed. Correcting what actually happened here
does not mark the experiment completed; "cbt complete" does that.`,
	Example:     `  cbt update experiment 2 --prediction "someone will think it is obvious, or nobody will answer"`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runUpdateBehaviouralExperiment,
}

func init() {
	updateCmd.AddCommand(updateBehaviouralExperimentCmd)

	flags := updateBehaviouralExperimentCmd.Flags()
	flags.StringVar(&updateBehaviouralExperimentOpts.Plan, "plan", "", "What are you going to try?")
	flags.StringVar(&updateBehaviouralExperimentOpts.At, "at", "", "When the experiment was carried out (YYYY-MM-DD, \"yesterday\", \"3h ago\")")
	flags.BoolVar(&updateBehaviouralExperimentOpts.ClearAt, "clear-at", false, "Forget when the experiment was carried out")
	flags.StringVar(&updateBehaviouralExperimentOpts.Prediction, "prediction", "", "What do you predict will happen and how will you feel?")
	flags.StringVar(&updateBehaviouralExperimentOpts.Outcome, "outcome", "", "What actually happened?")
	flags.StringVar(&updateBehaviouralExperimentOpts.Learned, "learned", "", "What have you learned from this?")
	flags.StringVar(&updateBehaviouralExperimentOpts.BuildOn, "build-on", "", "How can you build on this?")

	updateBehaviouralExperimentCmd.MarkFlagsMutuallyExclusive("at", "clear-at")
}

func runUpdateBehaviouralExperiment(cmd *cobra.Command, args []string) error {
	req, err := buildUpdateBehaviouralExperimentRequest(args, updateBehaviouralExperimentOpts, cmd.Flags(), time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	experiment, err := proto.NewRecordServiceClient(conn).UpdateBehaviouralExperiment(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to update the behavioural experiment: %w", err)
	}

	return writeBehaviouralExperimentLine(cmd.OutOrStdout(), experiment)
}

// buildUpdateBehaviouralExperimentRequest assembles the wire request from the
// parsed flags. As with a thought record, only flags the user typed are sent
// so that unmentioned columns keep their value.
func buildUpdateBehaviouralExperimentRequest(args []string, opts updateBehaviouralExperimentOptions, flags flagLookup, now time.Time) (*proto.UpdateBehaviouralExperimentRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	req := &proto.UpdateBehaviouralExperimentRequest{Id: id, ClearOccurredAt: opts.ClearAt}

	optional := []struct {
		flag   string
		value  *string
		target **string
	}{
		{"plan", &opts.Plan, &req.Plan},
		{"prediction", &opts.Prediction, &req.Prediction},
		{"outcome", &opts.Outcome, &req.Outcome},
		{"learned", &opts.Learned, &req.Learned},
		{"build-on", &opts.BuildOn, &req.BuildOn},
	}
	for _, field := range optional {
		if flags.Changed(field.flag) {
			*field.target = field.value
		}
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
