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

type createPositiveDataLogOptions struct {
	Alternative        string
	Believe            string
	BelieveAlternative string
	Evidence           []string
}

var createPositiveDataLogOpts createPositiveDataLogOptions

// createPositiveDataLogCmd creates a positive data log.
var createPositiveDataLogCmd = &cobra.Command{
	Use:     "data-log [self-critical belief]",
	Aliases: []string{"positive-data-log", "pdl"},
	Short:   "Create a positive data log",
	Long: `Create a positive data log: a self-critical belief, an alternative belief,
how strongly you believe each, and the evidence that supports the alternative
and weakens the old belief.

A log is meant to be returned to. Add evidence as you notice it with
"cbt create evidence", and come back later to rate both beliefs again with
"cbt rerate"; earlier ratings are kept.`,
	Example: `  cbt create data-log "I am always late" \
    --alternative "I am on time for most things" \
    --believe 70 --believe-alternative 30 \
    --evidence "arrived early for the dentist"`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runCreatePositiveDataLog,
}

func init() {
	createCmd.AddCommand(createPositiveDataLogCmd)

	flags := createPositiveDataLogCmd.Flags()
	flags.StringVar(&createPositiveDataLogOpts.Alternative, "alternative", "", "The alternative belief")
	flags.StringVar(&createPositiveDataLogOpts.Believe, "believe", "", "How strongly you believe the self-critical belief, 0-100")
	flags.StringVar(&createPositiveDataLogOpts.BelieveAlternative, "believe-alternative", "", "How strongly you believe the alternative belief, 0-100")
	flags.StringArrayVar(&createPositiveDataLogOpts.Evidence, "evidence", nil, "Evidence that supports the alternative and weakens the old belief (repeatable)")
}

func runCreatePositiveDataLog(cmd *cobra.Command, args []string) error {
	req, err := buildCreatePositiveDataLogRequest(args, createPositiveDataLogOpts)
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	log, err := proto.NewRecordServiceClient(conn).CreatePositiveDataLog(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to create the positive data log: %w", err)
	}

	return writePositiveDataLogLine(cmd.OutOrStdout(), log)
}

// buildCreatePositiveDataLogRequest assembles the wire request from the
// parsed flags.
func buildCreatePositiveDataLogRequest(args []string, opts createPositiveDataLogOptions) (*proto.CreatePositiveDataLogRequest, error) {
	believe, err := parsePercent("--believe", opts.Believe)
	if err != nil {
		return nil, err
	}
	believeAlternative, err := parsePercent("--believe-alternative", opts.BelieveAlternative)
	if err != nil {
		return nil, err
	}

	req := &proto.CreatePositiveDataLogRequest{
		Belief:             args[0],
		AlternativeBelief:  opts.Alternative,
		BeliefPercent:      believe,
		AlternativePercent: believeAlternative,
	}
	for _, evidence := range opts.Evidence {
		if strings.TrimSpace(evidence) == "" {
			return nil, fmt.Errorf("invalid --evidence: expected some text")
		}
		req.Evidence = append(req.Evidence, &proto.DataLogEvidenceInput{Body: evidence})
	}

	return req, nil
}

// buildDataLogEvidenceInput assembles a row of evidence with its optional
// time.
func buildDataLogEvidenceInput(body string, at string, now time.Time) (*proto.DataLogEvidenceInput, error) {
	if strings.TrimSpace(body) == "" {
		return nil, fmt.Errorf("invalid evidence: expected some text")
	}

	notedAt, err := parseEventTime(at, now)
	if err != nil {
		return nil, err
	}

	input := &proto.DataLogEvidenceInput{Body: body}
	if notedAt != nil {
		input.NotedAt = timestamppb.New(*notedAt)
	}

	return input, nil
}

// parsePercent turns an optional 0-100 rating flag into its wire form. An
// empty value is "not rated", which stays distinct from a rating of zero.
func parsePercent(flag string, value string) (*int32, error) {
	trimmed := strings.TrimSpace(strings.TrimSuffix(strings.TrimSpace(value), "%"))
	if trimmed == "" {
		return nil, nil
	}

	percent, err := strconv.Atoi(trimmed)
	if err != nil || percent < 0 || percent > 100 {
		return nil, fmt.Errorf("invalid %s %q: expected a rating between 0 and 100", flag, value)
	}

	// Range checked immediately above, so the conversion is safe.
	narrowed := int32(percent) // #nosec G109
	return &narrowed, nil
}
