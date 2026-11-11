package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type listPositiveDataLogsOptions struct {
	Search string
}

var listPositiveDataLogsOpts listPositiveDataLogsOptions

// listPositiveDataLogsCmd lists positive data logs.
var listPositiveDataLogsCmd = &cobra.Command{
	Use:     "data-logs",
	Aliases: []string{"positive-data-logs", "pdls"},
	Short:   "List positive data logs",
	Long: `List positive data logs, the most recently added to first, with the first
and latest rating of each belief.`,
	Example: `  cbt list data-logs
  cbt list data-logs --search train`,
	Args:        cobra.NoArgs,
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runListPositiveDataLogs,
}

func init() {
	listCmd.AddCommand(listPositiveDataLogsCmd)

	flags := listPositiveDataLogsCmd.Flags()
	flags.StringVar(&listPositiveDataLogsOpts.Search, "search", "", "Match either belief or any evidence")
}

func runListPositiveDataLogs(cmd *cobra.Command, _ []string) error {
	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	response, err := proto.NewRecordServiceClient(conn).ListPositiveDataLogs(cmd.Context(), buildListPositiveDataLogsRequest(listPositiveDataLogsOpts))
	if err != nil {
		return fmt.Errorf("failed to list the positive data logs: %w", err)
	}

	return writePositiveDataLogTable(cmd.OutOrStdout(), response.GetLogs())
}

// buildListPositiveDataLogsRequest assembles the wire request from the parsed
// flags.
func buildListPositiveDataLogsRequest(opts listPositiveDataLogsOptions) *proto.ListPositiveDataLogsRequest {
	return &proto.ListPositiveDataLogsRequest{Search: opts.Search}
}
