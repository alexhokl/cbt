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
