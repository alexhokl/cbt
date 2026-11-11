package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type updatePositiveDataLogOptions struct {
	Belief      string
	Alternative string
}

var updatePositiveDataLogOpts updatePositiveDataLogOptions

// updatePositiveDataLogCmd rewords the beliefs of a positive data log.
var updatePositiveDataLogCmd = &cobra.Command{
	Use:     "data-log [id]",
	Aliases: []string{"positive-data-log", "pdl"},
	Short:   "Reword the beliefs of a positive data log",
	Long: `Reword the self-critical or the alternative belief of a positive data log.

Only the beliefs you name are changed. Ratings are not changed here: "cbt
rerate" adds a new one and keeps the old.`,
	Example:     `  cbt update data-log 4 --alternative "I am on time for nearly everything"`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runUpdatePositiveDataLog,
}

func init() {
	updateCmd.AddCommand(updatePositiveDataLogCmd)

	flags := updatePositiveDataLogCmd.Flags()
	flags.StringVar(&updatePositiveDataLogOpts.Belief, "belief", "", "The self-critical belief")
	flags.StringVar(&updatePositiveDataLogOpts.Alternative, "alternative", "", "The alternative belief")
}

func runUpdatePositiveDataLog(cmd *cobra.Command, args []string) error {
	req, err := buildUpdatePositiveDataLogRequest(args, updatePositiveDataLogOpts, cmd.Flags())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	log, err := proto.NewRecordServiceClient(conn).UpdatePositiveDataLog(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to update the positive data log: %w", err)
	}

	return writePositiveDataLogLine(cmd.OutOrStdout(), log)
}

// buildUpdatePositiveDataLogRequest assembles the wire request from the
// parsed flags. Only flags the user typed are sent, so an unmentioned belief
// keeps its wording.
func buildUpdatePositiveDataLogRequest(args []string, opts updatePositiveDataLogOptions, flags flagLookup) (*proto.UpdatePositiveDataLogRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	req := &proto.UpdatePositiveDataLogRequest{Id: id}
	if flags.Changed("belief") {
		req.Belief = &opts.Belief
	}
	if flags.Changed("alternative") {
		req.AlternativeBelief = &opts.Alternative
	}

	return req, nil
}
