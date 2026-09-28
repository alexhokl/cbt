package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type updateMapOfWorryOptions struct {
	Event              string
	At                 string
	ClearAt            bool
	Thoughts           string
	Meaning            string
	PhysicalSensations string
	Behaviour          string
}

var updateMapOfWorryOpts updateMapOfWorryOptions

// updateMapOfWorryCmd changes the free text columns of a map of worry.
var updateMapOfWorryCmd = &cobra.Command{
	Use:     "map-of-worry [id]",
	Aliases: []string{"map"},
	Short:   "Change the columns of a map of worry",
	Long: `Change the columns of a map of worry.

Only the columns you name are changed, so a map can be filled in a piece at a
time as you work down the chain.`,
	Example:     `  cbt update map-of-worry 1 --behaviour "went for the walk anyway"`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runUpdateMapOfWorry,
}

func init() {
	updateCmd.AddCommand(updateMapOfWorryCmd)

	flags := updateMapOfWorryCmd.Flags()
	flags.StringVar(&updateMapOfWorryOpts.Event, "event", "", "What happened")
	flags.StringVar(&updateMapOfWorryOpts.At, "at", "", "When the event happened (YYYY-MM-DD, \"yesterday\", \"3h ago\")")
	flags.BoolVar(&updateMapOfWorryOpts.ClearAt, "clear-at", false, "Forget when the event happened")
	flags.StringVar(&updateMapOfWorryOpts.Thoughts, "thoughts", "", "The thoughts the event produced")
	flags.StringVar(&updateMapOfWorryOpts.Meaning, "meaning", "", "What these thoughts mean")
	flags.StringVar(&updateMapOfWorryOpts.PhysicalSensations, "sensations", "", "Physical sensations felt")
	flags.StringVar(&updateMapOfWorryOpts.Behaviour, "behaviour", "", "What you did, or avoided doing, as a result")

	updateMapOfWorryCmd.MarkFlagsMutuallyExclusive("at", "clear-at")
}

func runUpdateMapOfWorry(cmd *cobra.Command, args []string) error {
	req, err := buildUpdateMapOfWorryRequest(args, updateMapOfWorryOpts, cmd.Flags(), time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	mapOfWorry, err := proto.NewRecordServiceClient(conn).UpdateMapOfWorry(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to update the map of worry: %w", err)
	}

	return writeMapOfWorryLine(cmd.OutOrStdout(), mapOfWorry)
}

// buildUpdateMapOfWorryRequest assembles the wire request from the parsed
// flags. As with a thought record, only flags the user typed are sent so that
// unmentioned columns keep their value.
func buildUpdateMapOfWorryRequest(args []string, opts updateMapOfWorryOptions, flags flagLookup, now time.Time) (*proto.UpdateMapOfWorryRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	req := &proto.UpdateMapOfWorryRequest{Id: id, ClearOccurredAt: opts.ClearAt}

	optional := []struct {
		flag   string
		value  *string
		target **string
	}{
		{"event", &opts.Event, &req.Event},
		{"thoughts", &opts.Thoughts, &req.Thoughts},
		{"meaning", &opts.Meaning, &req.WhatTheseThoughtsMean},
		{"sensations", &opts.PhysicalSensations, &req.PhysicalSensations},
		{"behaviour", &opts.Behaviour, &req.ResultantBehaviour},
	}
	for _, field := range optional {
		if flags.Changed(field.flag) {
			*field.target = field.value
		}
	}

	if flags.Changed("at") {
		occurredAt, err := parseEventTime(opts.At, now)
		if err != nil {
			return nil, err
		}
		if occurredAt != nil {
			req.OccurredAt = timestamppb.New(*occurredAt)
		}
	}

	return req, nil
}
