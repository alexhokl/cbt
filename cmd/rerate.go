package cmd

import (
	"errors"
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type rerateOptions struct {
	Believe            string
	BelieveAlternative string
}

var rerateOpts rerateOptions

// rerateCmd adds a rating of both beliefs to a positive data log.
var rerateCmd = &cobra.Command{
	Use:   "rerate [data log id]",
	Short: "Rate the beliefs of a positive data log again",
	Long: `Come back to a positive data log and rate how strongly you now believe the
self-critical belief and the alternative. The earlier ratings are kept, so
"cbt get data-log" shows each one with its date.

Either rating may be left out, but not both.`,
	Example:     `  cbt rerate 4 --believe 55 --believe-alternative 45`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runRerate,
}

func init() {
	rootCmd.AddCommand(rerateCmd)

	flags := rerateCmd.Flags()
	flags.StringVar(&rerateOpts.Believe, "believe", "", "How strongly you now believe the self-critical belief, 0-100")
	flags.StringVar(&rerateOpts.BelieveAlternative, "believe-alternative", "", "How strongly you now believe the alternative belief, 0-100")
}

func runRerate(cmd *cobra.Command, args []string) error {
	req, err := buildRerateRequest(args, rerateOpts)
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	log, err := proto.NewRecordServiceClient(conn).RateBeliefs(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to rate the beliefs: %w", err)
	}

	return writePositiveDataLogLine(cmd.OutOrStdout(), log)
}

// buildRerateRequest assembles the wire request from the parsed flags. A
// rating of neither belief would record nothing, so it is refused here rather
// than sent.
func buildRerateRequest(args []string, opts rerateOptions) (*proto.RateBeliefsRequest, error) {
	logID, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	believe, err := parsePercent("--believe", opts.Believe)
	if err != nil {
		return nil, err
	}
	believeAlternative, err := parsePercent("--believe-alternative", opts.BelieveAlternative)
	if err != nil {
		return nil, err
	}
	if believe == nil && believeAlternative == nil {
		return nil, errors.New("nothing to rate: give --believe, --believe-alternative or both")
	}

	return &proto.RateBeliefsRequest{
		LogId:              logID,
		BeliefPercent:      believe,
		AlternativePercent: believeAlternative,
	}, nil
}
