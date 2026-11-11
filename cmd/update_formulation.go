package cmd

import (
	"fmt"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

var updateFormulationOpts formulationOptions

// updateFormulationCmd changes the columns of a formulation.
var updateFormulationCmd = &cobra.Command{
	Use:     "formulation [id]",
	Aliases: []string{"fm"},
	Short:   "Change the columns of a formulation",
	Long: `Change the columns of a formulation.

Only the columns you name are changed, so a formulation can be filled in a
column at a time. Pass an empty value to clear a column; at least one column
must remain.`,
	Example:     `  cbt update formulation 2 --beliefs "people move on" --behaviours "eats at the desk"`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runUpdateFormulation,
}

func init() {
	updateCmd.AddCommand(updateFormulationCmd)
	addFormulationFlags(updateFormulationCmd, &updateFormulationOpts)
}

func runUpdateFormulation(cmd *cobra.Command, args []string) error {
	req, err := buildUpdateFormulationRequest(args, updateFormulationOpts, cmd.Flags())
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	formulation, err := proto.NewRecordServiceClient(conn).UpdateFormulation(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to update the formulation: %w", err)
	}

	return writeFormulationLine(cmd.OutOrStdout(), formulation)
}

// buildUpdateFormulationRequest assembles the wire request from the parsed
// flags. Only flags the user typed are sent, so unmentioned columns keep their
// value.
func buildUpdateFormulationRequest(args []string, opts formulationOptions, flags flagLookup) (*proto.UpdateFormulationRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	req := &proto.UpdateFormulationRequest{Id: id}
	targets := []**string{
		&req.EarlyExperiences,
		&req.Beliefs,
		&req.Assumptions,
		&req.RulesForLiving,
		&req.Events,
		&req.Thoughts,
		&req.Behaviours,
	}
	for index, column := range formulationColumns {
		if flags.Changed(column.flag) {
			*targets[index] = column.option(&opts)
		}
	}

	return req, nil
}
