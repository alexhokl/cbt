package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type listFormulationsOptions struct {
	Search string
}

var listFormulationsOpts listFormulationsOptions

// listFormulationsCmd lists formulations.
var listFormulationsCmd = &cobra.Command{
	Use:     "formulations",
	Aliases: []string{"fms"},
	Short:   "List formulations",
	Long:    `List formulations, the most recently changed first.`,
	Example: `  cbt list formulations
  cbt list formulations --search lunch`,
	Args:        cobra.NoArgs,
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runListFormulations,
}

func init() {
	listCmd.AddCommand(listFormulationsCmd)

	flags := listFormulationsCmd.Flags()
	flags.StringVar(&listFormulationsOpts.Search, "search", "", "Match any column of the formulation")
}

func runListFormulations(cmd *cobra.Command, _ []string) error {
	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	response, err := proto.NewRecordServiceClient(conn).ListFormulations(cmd.Context(), buildListFormulationsRequest(listFormulationsOpts))
	if err != nil {
		return fmt.Errorf("failed to list the formulations: %w", err)
	}

	return writeFormulationTable(cmd.OutOrStdout(), response.GetFormulations())
}

// buildListFormulationsRequest assembles the wire request from the parsed
// flags.
func buildListFormulationsRequest(opts listFormulationsOptions) *proto.ListFormulationsRequest {
	return &proto.ListFormulationsRequest{Search: opts.Search}
}
