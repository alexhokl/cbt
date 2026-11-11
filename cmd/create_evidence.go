package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type createEvidenceOptions struct {
	At string
}

var createEvidenceOpts createEvidenceOptions

// createEvidenceCmd adds a row of evidence to a positive data log.
var createEvidenceCmd = &cobra.Command{
	Use:   "evidence [data log id] [evidence]",
	Short: "Add evidence to a positive data log",
	Long: `Add a row of evidence to a positive data log: something that supports the
alternative belief and weakens the old one.

Write it down when you notice it; --at records when it happened if that was
earlier.`,
	Example: `  cbt create evidence 4 "caught the first train on Monday"
  cbt create evidence 4 "arrived early for the dentist" --at yesterday`,
	Args:        cobra.ExactArgs(2),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runCreateEvidence,
}

func init() {
	createCmd.AddCommand(createEvidenceCmd)

	flags := createEvidenceCmd.Flags()
	flags.StringVar(&createEvidenceOpts.At, "at", "", "When it happened (YYYY-MM-DD, \"yesterday\", \"3h ago\")")
}

func runCreateEvidence(cmd *cobra.Command, args []string) error {
	req, err := buildCreateEvidenceRequest(args, createEvidenceOpts, time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	log, err := proto.NewRecordServiceClient(conn).AddDataLogEvidence(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to add the evidence: %w", err)
	}

	return writePositiveDataLogLine(cmd.OutOrStdout(), log)
}

// buildCreateEvidenceRequest assembles the wire request from the parsed
// arguments and flags.
func buildCreateEvidenceRequest(args []string, opts createEvidenceOptions, now time.Time) (*proto.AddDataLogEvidenceRequest, error) {
	logID, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	evidence, err := buildDataLogEvidenceInput(args[1], opts.At, now)
	if err != nil {
		return nil, err
	}

	return &proto.AddDataLogEvidenceRequest{LogId: logID, Evidence: evidence}, nil
}
