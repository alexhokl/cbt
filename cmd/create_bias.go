package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

// createBiasCmd adds a user defined cognitive bias.
var createBiasCmd = &cobra.Command{
	Use:   "bias [name]",
	Short: "Add a cognitive bias to your vocabulary",
	Long: `Add a cognitive bias alongside the nine builtin ones.

Names are matched case insensitively, so "Comparing" and "comparing" are the
same bias.`,
	Example:     `  cbt create bias "comparing myself to others"`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runCreateBias,
}

func init() {
	createCmd.AddCommand(createBiasCmd)
}

func runCreateBias(cmd *cobra.Command, args []string) error {
	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	bias, err := proto.NewRecordServiceClient(conn).CreateBias(cmd.Context(), &proto.CreateBiasRequest{Name: args[0]})
	if err != nil {
		return fmt.Errorf("failed to create the cognitive bias: %w", err)
	}

	if _, err := fmt.Fprintf(cmd.OutOrStdout(), "%s (id %d)\n", bias.GetName(), bias.GetId()); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}
