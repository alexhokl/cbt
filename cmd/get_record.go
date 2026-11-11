package cmd

import (
	"fmt"
	"strconv"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

// getThoughtRecordCmd shows a single thought record in full.
var getThoughtRecordCmd = &cobra.Command{
	Use:         "thought-record [id]",
	Aliases:     []string{"record", "tr"},
	Short:       "Show a thought record in full",
	Example:     `  cbt get thought-record 3`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runGetThoughtRecord,
}

// getMapOfWorryCmd shows a single map of worry alongside the maps it should be
// read against.
var getMapOfWorryCmd = &cobra.Command{
	Use:     "map-of-worry [id]",
	Aliases: []string{"map"},
	Short:   "Show a map of worry in full, with any alternative readings",
	Long: `Show a map of worry in full.

If the map reworks another, or has been reworked, those maps are shown with it:
the contrast between two readings of the same event is the point of the
exercise.`,
	Example:     `  cbt get map-of-worry 1`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runGetMapOfWorry,
}

// getBehaviouralExperimentCmd shows a single behavioural experiment in full.
var getBehaviouralExperimentCmd = &cobra.Command{
	Use:         "experiment [id]",
	Aliases:     []string{"behavioural-experiment", "be"},
	Short:       "Show a behavioural experiment in full",
	Example:     `  cbt get experiment 2`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runGetBehaviouralExperiment,
}

// getPositiveDataLogCmd shows a single positive data log in full.
var getPositiveDataLogCmd = &cobra.Command{
	Use:         "data-log [id]",
	Aliases:     []string{"positive-data-log", "pdl"},
	Short:       "Show a positive data log in full, with every rating and all evidence",
	Example:     `  cbt get data-log 4`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runGetPositiveDataLog,
}

func init() {
	getCmd.AddCommand(getThoughtRecordCmd)
	getCmd.AddCommand(getMapOfWorryCmd)
	getCmd.AddCommand(getBehaviouralExperimentCmd)
	getCmd.AddCommand(getPositiveDataLogCmd)
}

func runGetThoughtRecord(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	record, err := proto.NewRecordServiceClient(conn).GetThoughtRecord(cmd.Context(), &proto.GetThoughtRecordRequest{Id: id})
	if err != nil {
		return fmt.Errorf("failed to get the thought record: %w", err)
	}

	return writeThoughtRecordDetail(cmd.OutOrStdout(), record)
}

func runGetMapOfWorry(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	response, err := proto.NewRecordServiceClient(conn).GetMapOfWorry(cmd.Context(), &proto.GetMapOfWorryRequest{Id: id})
	if err != nil {
		return fmt.Errorf("failed to get the map of worry: %w", err)
	}

	return writeMapContrast(cmd.OutOrStdout(), response)
}

func runGetBehaviouralExperiment(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	experiment, err := proto.NewRecordServiceClient(conn).GetBehaviouralExperiment(cmd.Context(), &proto.GetBehaviouralExperimentRequest{Id: id})
	if err != nil {
		return fmt.Errorf("failed to get the behavioural experiment: %w", err)
	}

	return writeBehaviouralExperimentDetail(cmd.OutOrStdout(), experiment)
}

func runGetPositiveDataLog(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	log, err := proto.NewRecordServiceClient(conn).GetPositiveDataLog(cmd.Context(), &proto.GetPositiveDataLogRequest{Id: id})
	if err != nil {
		return fmt.Errorf("failed to get the positive data log: %w", err)
	}

	return writePositiveDataLogDetail(cmd.OutOrStdout(), log)
}

// parseRecordID converts a positional identifier argument. Identifiers are
// always positive, so a negative or malformed value is reported here rather
// than wrapping around into a plausible looking one on the wire.
func parseRecordID(value string) (uint32, error) {
	id, err := strconv.ParseUint(value, 10, 32)
	if err != nil {
		return 0, fmt.Errorf("invalid id %q: expected a positive whole number", value)
	}
	if id == 0 {
		return 0, fmt.Errorf("invalid id %q: expected a positive whole number", value)
	}

	return uint32(id), nil
}
