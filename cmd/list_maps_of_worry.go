package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type listMapsOfWorryOptions struct {
	Since  string
	Search string
}

var listMapsOfWorryOpts listMapsOfWorryOptions

// listMapsOfWorryCmd lists maps of worry.
var listMapsOfWorryCmd = &cobra.Command{
	Use:         "maps-of-worry",
	Aliases:     []string{"maps"},
	Short:       "List maps of worry",
	Example:     `  cbt list maps-of-worry --since 30d`,
	Args:        cobra.NoArgs,
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runListMapsOfWorry,
}

func init() {
	listCmd.AddCommand(listMapsOfWorryCmd)

	flags := listMapsOfWorryCmd.Flags()
	flags.StringVar(&listMapsOfWorryOpts.Since, "since", "", "Only events on or after this time (YYYY-MM-DD, \"30d\", \"yesterday\")")
	flags.StringVar(&listMapsOfWorryOpts.Search, "search", "", "Match any column of the map")
}

func runListMapsOfWorry(cmd *cobra.Command, _ []string) error {
	req, err := buildListMapsOfWorryRequest(listMapsOfWorryOpts, time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	response, err := proto.NewRecordServiceClient(conn).ListMapsOfWorry(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to list the maps of worry: %w", err)
	}

	return writeMapOfWorryTable(cmd.OutOrStdout(), response.GetMaps())
}

// buildListMapsOfWorryRequest assembles the wire request from the parsed flags.
func buildListMapsOfWorryRequest(opts listMapsOfWorryOptions, now time.Time) (*proto.ListMapsOfWorryRequest, error) {
	req := &proto.ListMapsOfWorryRequest{Search: opts.Search}

	since, err := parseSince(opts.Since, now)
	if err != nil {
		return nil, err
	}
	if since != nil {
		req.Since = timestamppb.New(*since)
	}

	return req, nil
}
