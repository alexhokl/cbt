package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type createBehaviouralExperimentOptions struct {
	At         string
	Prediction string
	Feelings   []string
}

var createBehaviouralExperimentOpts createBehaviouralExperimentOptions

// createBehaviouralExperimentCmd creates a behavioural experiment.
var createBehaviouralExperimentCmd = &cobra.Command{
	Use:     "experiment [what you are going to try]",
	Aliases: []string{"behavioural-experiment", "be"},
	Short:   "Create a behavioural experiment",
	Long: `Create a behavioural experiment: what you are going to try, and what you
predict will happen and how you will feel.

An experiment is written in two parts. The plan and the prediction come
before; what actually happened, what you learned from it and how you can build
on it come after, with "cbt complete". --feeling rates a feeling you predict,
so it can be set beside how it actually felt.`,
	Example: `  cbt create experiment "ask a question at the end of the team meeting" \
    --prediction "someone will think it is obvious" \
    --feeling embarrassed=70`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runCreateBehaviouralExperiment,
}

func init() {
	createCmd.AddCommand(createBehaviouralExperimentCmd)

	flags := createBehaviouralExperimentCmd.Flags()
	flags.StringVar(&createBehaviouralExperimentOpts.At, "at", "", "When the experiment was carried out (YYYY-MM-DD, \"yesterday\", \"3h ago\")")
	flags.StringVar(&createBehaviouralExperimentOpts.Prediction, "prediction", "", "What do you predict will happen and how will you feel?")
	flags.StringArrayVar(&createBehaviouralExperimentOpts.Feelings, "feeling", nil, "A feeling you predict and its 0-100 rating, as name=rating (repeatable)")
	cobra.CheckErr(createBehaviouralExperimentCmd.RegisterFlagCompletionFunc("feeling", completeFeeling))
}

func runCreateBehaviouralExperiment(cmd *cobra.Command, args []string) error {
	req, err := buildCreateBehaviouralExperimentRequest(args, createBehaviouralExperimentOpts, time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	experiment, err := proto.NewRecordServiceClient(conn).CreateBehaviouralExperiment(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to create the behavioural experiment: %w", err)
	}

	return writeBehaviouralExperimentLine(cmd.OutOrStdout(), experiment)
}

// buildCreateBehaviouralExperimentRequest assembles the wire request from the
// parsed flags.
func buildCreateBehaviouralExperimentRequest(args []string, opts createBehaviouralExperimentOptions, now time.Time) (*proto.CreateBehaviouralExperimentRequest, error) {
	occurredAt, err := parseEventTime(opts.At, now)
	if err != nil {
		return nil, err
	}

	feelings, err := parseFeelings(opts.Feelings)
	if err != nil {
		return nil, err
	}

	req := &proto.CreateBehaviouralExperimentRequest{
		Plan:       args[0],
		Prediction: opts.Prediction,
		Feelings:   feelings,
	}
	if occurredAt != nil {
		req.OccurredAt = timestamppb.New(*occurredAt)
	}

	return req, nil
}
