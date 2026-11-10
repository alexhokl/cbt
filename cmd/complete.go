package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type completeOptions struct {
	Outcome   string
	Learned   string
	BuildOn   string
	Reratings []string
	Feelings  []string
}

var completeOpts completeOptions

// completeCmd records the second sitting of a behavioural experiment.
var completeCmd = &cobra.Command{
	Use:   "complete [id]",
	Short: "Write up a behavioural experiment: what happened, what you learned",
	Long: `Record the second part of a behavioural experiment, once it has been carried
out: what actually happened, what you have learned from this, how you can
build on this, and how each feeling you predicted actually felt. This takes
the experiment out of the queue that "cbt list experiments --not-completed"
shows.

--rerate rates a feeling you predicted; --feeling records one you felt but did
not predict. Run "cbt get experiment <id>" first to see the feeling ids.`,
	Example: `  cbt complete 2 --outcome "two people said they had the same question" \
    --learned "the question was worth asking" \
    --build-on "ask the next one during the meeting" \
    --rerate 5=20 --feeling relieved=50`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runComplete,
}

func init() {
	rootCmd.AddCommand(completeCmd)

	flags := completeCmd.Flags()
	flags.StringVar(&completeOpts.Outcome, "outcome", "", "What actually happened?")
	flags.StringVar(&completeOpts.Learned, "learned", "", "What have you learned from this?")
	flags.StringVar(&completeOpts.BuildOn, "build-on", "", "How can you build on this?")
	flags.StringArrayVar(&completeOpts.Reratings, "rerate", nil, "How a predicted feeling actually felt, as feeling-id=rating (repeatable)")
	flags.StringArrayVar(&completeOpts.Feelings, "feeling", nil, "A feeling you felt but did not predict, as name=rating (repeatable)")
	cobra.CheckErr(completeCmd.RegisterFlagCompletionFunc("feeling", completeFeeling))
}

func runComplete(cmd *cobra.Command, args []string) error {
	req, err := buildCompleteRequest(args, completeOpts)
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	experiment, err := proto.NewRecordServiceClient(conn).CompleteBehaviouralExperiment(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to complete the behavioural experiment: %w", err)
	}

	return writeBehaviouralExperimentDetail(cmd.OutOrStdout(), experiment)
}

// buildCompleteRequest assembles the wire request from the parsed flags.
func buildCompleteRequest(args []string, opts completeOptions) (*proto.CompleteBehaviouralExperimentRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	newFeelings, err := parseFeelings(opts.Feelings)
	if err != nil {
		return nil, err
	}

	req := &proto.CompleteBehaviouralExperimentRequest{
		Id:          id,
		Outcome:     opts.Outcome,
		Learned:     opts.Learned,
		BuildOn:     opts.BuildOn,
		NewFeelings: newFeelings,
	}

	for _, value := range opts.Reratings {
		rerating, err := parseRerating(value)
		if err != nil {
			return nil, err
		}
		req.FeelingReratings = append(req.FeelingReratings, rerating)
	}

	return req, nil
}
