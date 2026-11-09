package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type updateThoughtOptions struct {
	Evidence string
}

var updateThoughtOpts updateThoughtOptions

// updateThoughtCmd records what supports a thought, at any time after it was
// written.
var updateThoughtCmd = &cobra.Command{
	Use:     "thought [thought-id]",
	Aliases: []string{"t"},
	Short:   "Record the evidence for a thought",
	Long: `Record what supports a negative thought.

Evidence is often gathered some time after the thought was written, so it can
be added or changed at any point. Doing so does not mark the record as
challenged. Run "cbt get thought-record <id>" first to see the thought ids.`,
	Example: `  cbt update thought 7 --evidence "two of the last five trains ran late"
  cbt update thought 7 --evidence ""`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runUpdateThought,
}

func init() {
	updateCmd.AddCommand(updateThoughtCmd)

	flags := updateThoughtCmd.Flags()
	flags.StringVar(&updateThoughtOpts.Evidence, "evidence", "", "What evidence supports this thought? An empty value removes it")
}

func runUpdateThought(cmd *cobra.Command, args []string) error {
	req, err := buildUpdateThoughtRequest(args, updateThoughtOpts, cmd.Flags())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	record, err := proto.NewRecordServiceClient(conn).SetThoughtEvidence(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to update the thought: %w", err)
	}

	return writeThoughtRecordDetail(cmd.OutOrStdout(), record)
}

// buildUpdateThoughtRequest assembles the wire request from the parsed flags.
// The evidence replaces whatever the thought carried, so a command with no
// --evidence at all is rejected rather than read as an instruction to blank
// it; typing --evidence "" is how it is removed on purpose.
func buildUpdateThoughtRequest(args []string, opts updateThoughtOptions, flags flagLookup) (*proto.SetThoughtEvidenceRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	if !flags.Changed("evidence") {
		return nil, fmt.Errorf("nothing to change: give --evidence")
	}

	return &proto.SetThoughtEvidenceRequest{Id: id, Evidence: opts.Evidence}, nil
}
