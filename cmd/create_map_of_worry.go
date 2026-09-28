package cmd

import (
	"fmt"
	"time"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type createMapOfWorryOptions struct {
	At                 string
	Thoughts           string
	Meaning            string
	PhysicalSensations string
	Behaviour          string
	Feelings           []string
	AlternativeTo      uint32
}

var createMapOfWorryOpts createMapOfWorryOptions

// createMapOfWorryCmd creates a map of worry.
var createMapOfWorryCmd = &cobra.Command{
	Use:     "map-of-worry [event]",
	Aliases: []string{"map"},
	Short:   "Create a map of worry",
	Long: `Create a map of worry, tracing an event through to the behaviour it produced.

Use --alternative-to to rework an existing map: a second, healthier reading of
the same event. The two are then shown side by side, which is the point of the
exercise.`,
	Example: `  cbt create map-of-worry "a report came back covered in comments" \
    --thoughts "my work is not good enough" \
    --meaning "sooner or later they will work out I cannot do this" \
    --sensations "tight chest" \
    --feeling anxious=65 \
    --behaviour "put off opening the review until the next morning"

  cbt create map-of-worry "a report came back covered in comments" --alternative-to 1 \
    --thoughts "the comments are detailed because someone read it properly" \
    --behaviour "worked through the comments one at a time"`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runCreateMapOfWorry,
}

func init() {
	createCmd.AddCommand(createMapOfWorryCmd)

	flags := createMapOfWorryCmd.Flags()
	flags.StringVar(&createMapOfWorryOpts.At, "at", "", "When the event happened (YYYY-MM-DD, \"yesterday\", \"3h ago\")")
	flags.StringVar(&createMapOfWorryOpts.Thoughts, "thoughts", "", "The thoughts the event produced")
	flags.StringVar(&createMapOfWorryOpts.Meaning, "meaning", "", "What these thoughts mean")
	flags.StringVar(&createMapOfWorryOpts.PhysicalSensations, "sensations", "", "Physical sensations felt")
	flags.StringVar(&createMapOfWorryOpts.Behaviour, "behaviour", "", "What you did, or avoided doing, as a result")
	flags.StringArrayVar(&createMapOfWorryOpts.Feelings, "feeling", nil, "A feeling and its 0-100 rating, as name=rating (repeatable)")
	flags.Uint32Var(&createMapOfWorryOpts.AlternativeTo, "alternative-to", 0, "ID of the map this one reworks")
}

func runCreateMapOfWorry(cmd *cobra.Command, args []string) error {
	req, err := buildCreateMapOfWorryRequest(args, createMapOfWorryOpts, cmd.Flags().Changed("alternative-to"), time.Now())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	mapOfWorry, err := proto.NewRecordServiceClient(conn).CreateMapOfWorry(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to create the map of worry: %w", err)
	}

	return writeMapOfWorryLine(cmd.OutOrStdout(), mapOfWorry)
}

// buildCreateMapOfWorryRequest assembles the wire request from the parsed
// flags. A zero origin identifier is left absent unless the flag was
// explicitly set, so "--alternative-to 0" is reported by the server rather
// than quietly treated as no link at all.
func buildCreateMapOfWorryRequest(args []string, opts createMapOfWorryOptions, alternativeChanged bool, now time.Time) (*proto.CreateMapOfWorryRequest, error) {
	occurredAt, err := parseEventTime(opts.At, now)
	if err != nil {
		return nil, err
	}

	feelings, err := parseFeelings(opts.Feelings)
	if err != nil {
		return nil, err
	}

	req := &proto.CreateMapOfWorryRequest{
		Event:                 args[0],
		Thoughts:              opts.Thoughts,
		WhatTheseThoughtsMean: opts.Meaning,
		PhysicalSensations:    opts.PhysicalSensations,
		ResultantBehaviour:    opts.Behaviour,
		Feelings:              feelings,
	}
	if occurredAt != nil {
		req.OccurredAt = timestamppb.New(*occurredAt)
	}
	if alternativeChanged {
		req.DerivedFromId = &opts.AlternativeTo
	}

	return req, nil
}
