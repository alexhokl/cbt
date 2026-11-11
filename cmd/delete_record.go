package cmd

import (
	"fmt"
	"io"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

// deleteThoughtRecordCmd removes a thought record.
var deleteThoughtRecordCmd = &cobra.Command{
	Use:     "thought-record [id]",
	Aliases: []string{"record", "tr"},
	Short:   "Delete a thought record and everything on it",
	Long: `Delete a thought record along with its thoughts and feelings.

There is no undo.`,
	Example:     `  cbt delete thought-record 3`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runDeleteThoughtRecord,
}

// deleteMapOfWorryCmd removes a map of worry.
var deleteMapOfWorryCmd = &cobra.Command{
	Use:     "map-of-worry [id]",
	Aliases: []string{"map"},
	Short:   "Delete a map of worry",
	Long: `Delete a map of worry along with its feelings.

A map that has been reworked cannot be deleted while its alternatives remain:
an alternative only means something read against the map it reworks. Delete the
alternatives first.`,
	Example:     `  cbt delete map-of-worry 1`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runDeleteMapOfWorry,
}

// deleteBehaviouralExperimentCmd removes a behavioural experiment.
var deleteBehaviouralExperimentCmd = &cobra.Command{
	Use:     "experiment [id]",
	Aliases: []string{"behavioural-experiment", "be"},
	Short:   "Delete a behavioural experiment",
	Long: `Delete a behavioural experiment along with its feelings.

There is no undo.`,
	Example:     `  cbt delete experiment 2`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runDeleteBehaviouralExperiment,
}

// deletePositiveDataLogCmd removes a positive data log.
var deletePositiveDataLogCmd = &cobra.Command{
	Use:     "data-log [id]",
	Aliases: []string{"positive-data-log", "pdl"},
	Short:   "Delete a positive data log",
	Long: `Delete a positive data log along with its evidence and ratings.

There is no undo.`,
	Example:     `  cbt delete data-log 4`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runDeletePositiveDataLog,
}

// deleteEvidenceCmd removes a row of evidence from a positive data log.
var deleteEvidenceCmd = &cobra.Command{
	Use:   "evidence [id]",
	Short: "Delete a row of evidence from a positive data log",
	Long: `Delete a row of evidence from a positive data log. Run "cbt get data-log
<id>" first to see the evidence ids.`,
	Example:     `  cbt delete evidence 7`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runDeleteEvidence,
}

// deleteBiasCmd removes a user defined cognitive bias.
var deleteBiasCmd = &cobra.Command{
	Use:   "bias [id]",
	Short: "Delete a cognitive bias you added",
	Long: `Delete a cognitive bias you added.

The nine builtin biases cannot be deleted, and a bias still named in a thought
cannot be deleted either: doing so would change how a past record reads.`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runDeleteBias,
}

func init() {
	deleteCmd.AddCommand(deleteThoughtRecordCmd)
	deleteCmd.AddCommand(deleteMapOfWorryCmd)
	deleteCmd.AddCommand(deleteBehaviouralExperimentCmd)
	deleteCmd.AddCommand(deletePositiveDataLogCmd)
	deleteCmd.AddCommand(deleteEvidenceCmd)
	deleteCmd.AddCommand(deleteBiasCmd)
}

func runDeleteThoughtRecord(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	if _, err := proto.NewRecordServiceClient(conn).DeleteThoughtRecord(cmd.Context(), &proto.DeleteThoughtRecordRequest{Id: id}); err != nil {
		return fmt.Errorf("failed to delete the thought record: %w", err)
	}

	return writeDeleted(cmd.OutOrStdout(), "thought record", id)
}

func runDeleteMapOfWorry(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	if _, err := proto.NewRecordServiceClient(conn).DeleteMapOfWorry(cmd.Context(), &proto.DeleteMapOfWorryRequest{Id: id}); err != nil {
		return fmt.Errorf("failed to delete the map of worry: %w", err)
	}

	return writeDeleted(cmd.OutOrStdout(), "map of worry", id)
}

func runDeleteBehaviouralExperiment(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	if _, err := proto.NewRecordServiceClient(conn).DeleteBehaviouralExperiment(cmd.Context(), &proto.DeleteBehaviouralExperimentRequest{Id: id}); err != nil {
		return fmt.Errorf("failed to delete the behavioural experiment: %w", err)
	}

	return writeDeleted(cmd.OutOrStdout(), "behavioural experiment", id)
}

func runDeletePositiveDataLog(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	if _, err := proto.NewRecordServiceClient(conn).DeletePositiveDataLog(cmd.Context(), &proto.DeletePositiveDataLogRequest{Id: id}); err != nil {
		return fmt.Errorf("failed to delete the positive data log: %w", err)
	}

	return writeDeleted(cmd.OutOrStdout(), "positive data log", id)
}

func runDeleteEvidence(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	if _, err := proto.NewRecordServiceClient(conn).DeleteDataLogEvidence(cmd.Context(), &proto.DeleteDataLogEvidenceRequest{Id: id}); err != nil {
		return fmt.Errorf("failed to delete the evidence: %w", err)
	}

	return writeDeleted(cmd.OutOrStdout(), "evidence", id)
}

func runDeleteBias(cmd *cobra.Command, args []string) error {
	id, err := parseRecordID(args[0])
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	if _, err := proto.NewRecordServiceClient(conn).DeleteBias(cmd.Context(), &proto.DeleteBiasRequest{Id: id}); err != nil {
		return fmt.Errorf("failed to delete the cognitive bias: %w", err)
	}

	return writeDeleted(cmd.OutOrStdout(), "cognitive bias", id)
}

// writeDeleted renders the one line confirmation of a deletion.
func writeDeleted(out io.Writer, subject string, id uint32) error {
	if _, err := fmt.Fprintf(out, "deleted %s %d\n", subject, id); err != nil {
		return fmt.Errorf("failed to write output: %w", err)
	}

	return nil
}
