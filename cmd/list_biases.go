package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

// listBiasesCmd lists the cognitive bias vocabulary.
var listBiasesCmd = &cobra.Command{
	Use:     "biases",
	Aliases: []string{"bias"},
	Short:   "List the cognitive biases available to name in a thought",
	Long: `List the cognitive biases available to name in a thought.

The nine builtin biases are the ones catalogued in the source material and
cannot be renamed or deleted, so a past record always reads the same way. Any
bias you add yourself sits alongside them.`,
	Args:        cobra.NoArgs,
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runListBiases,
}

func init() {
	listCmd.AddCommand(listBiasesCmd)
}

func runListBiases(cmd *cobra.Command, _ []string) error {
	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	response, err := proto.NewRecordServiceClient(conn).ListBiases(cmd.Context(), &proto.ListBiasesRequest{})
	if err != nil {
		return fmt.Errorf("failed to list the cognitive biases: %w", err)
	}

	return writeBiasTable(cmd.OutOrStdout(), response.GetBiases())
}
