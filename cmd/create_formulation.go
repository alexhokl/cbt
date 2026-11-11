package cmd

import (
	"errors"
	"fmt"
	"strings"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

// formulationOptions holds one value per column of a formulation. Create and
// update share it, since the flags are the same.
type formulationOptions struct {
	EarlyExperiences string
	Beliefs          string
	Assumptions      string
	RulesForLiving   string
	Events           string
	Thoughts         string
	Behaviours       string
}

// formulationColumn ties a flag to its column, in the order the exercise is
// written.
type formulationColumn struct {
	flag   string
	usage  string
	label  string
	option func(*formulationOptions) *string
	value  func(*proto.Formulation) string
}

var formulationColumns = []formulationColumn{
	{"early-experiences", "Early life experiences", "early life experiences",
		func(o *formulationOptions) *string { return &o.EarlyExperiences }, (*proto.Formulation).GetEarlyExperiences},
	{"beliefs", "Beliefs", "beliefs",
		func(o *formulationOptions) *string { return &o.Beliefs }, (*proto.Formulation).GetBeliefs},
	{"assumptions", "Assumptions", "assumptions",
		func(o *formulationOptions) *string { return &o.Assumptions }, (*proto.Formulation).GetAssumptions},
	{"rules-for-living", "Rules for living", "rules for living",
		func(o *formulationOptions) *string { return &o.RulesForLiving }, (*proto.Formulation).GetRulesForLiving},
	{"events", "Events", "events",
		func(o *formulationOptions) *string { return &o.Events }, (*proto.Formulation).GetEvents},
	{"thoughts", "Negative thoughts maintaining the problem", "negative thoughts maintaining the problem",
		func(o *formulationOptions) *string { return &o.Thoughts }, (*proto.Formulation).GetThoughts},
	{"behaviours", "Behaviours maintaining the problem", "behaviours maintaining the problem",
		func(o *formulationOptions) *string { return &o.Behaviours }, (*proto.Formulation).GetBehaviours},
}

// addFormulationFlags registers one flag per column on the command.
func addFormulationFlags(cmd *cobra.Command, opts *formulationOptions) {
	flags := cmd.Flags()
	for _, column := range formulationColumns {
		flags.StringVar(column.option(opts), column.flag, "", column.usage)
	}
}

var createFormulationOpts formulationOptions

// createFormulationCmd creates a formulation.
var createFormulationCmd = &cobra.Command{
	Use:     "formulation",
	Aliases: []string{"fm"},
	Short:   "Create a formulation: early life experiences to thoughts and behaviours",
	Long: `Create a formulation tracing how early life experiences lead to thoughts and
behaviours: early life experiences, beliefs, assumptions, rules for living,
the events that trigger them, and the negative thoughts and behaviours
maintaining the problem.

Start from whichever column you can. Working backwards from the thoughts and
behaviours, asking "what does this say about me?", is as valid as starting
from the early experiences. Fill in the rest later with "cbt update
formulation".`,
	Example: `  cbt create formulation \
    --early-experiences "moved school three times as a child" \
    --beliefs "people move on" \
    --assumptions "if I get attached, it will end" \
    --rules-for-living "keep new colleagues at arm's length" \
    --events "invited to a team lunch" \
    --thoughts "there is no point getting to know them" \
    --behaviours "eats at the desk"
  cbt create formulation --thoughts "there is no point getting to know them"`,
	Args:        cobra.NoArgs,
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runCreateFormulation,
}

func init() {
	createCmd.AddCommand(createFormulationCmd)
	addFormulationFlags(createFormulationCmd, &createFormulationOpts)
}

func runCreateFormulation(cmd *cobra.Command, _ []string) error {
	req, err := buildCreateFormulationRequest(createFormulationOpts)
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	formulation, err := proto.NewRecordServiceClient(conn).CreateFormulation(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to create the formulation: %w", err)
	}

	return writeFormulationLine(cmd.OutOrStdout(), formulation)
}

// buildCreateFormulationRequest assembles the wire request from the parsed
// flags. A formulation with every column blank would record nothing, so it is
// refused here rather than sent.
func buildCreateFormulationRequest(opts formulationOptions) (*proto.CreateFormulationRequest, error) {
	empty := true
	for _, column := range formulationColumns {
		if strings.TrimSpace(*column.option(&opts)) != "" {
			empty = false
			break
		}
	}
	if empty {
		return nil, errors.New("nothing to record: give at least one of --early-experiences, --beliefs, --assumptions, --rules-for-living, --events, --thoughts or --behaviours")
	}

	return &proto.CreateFormulationRequest{
		EarlyExperiences: opts.EarlyExperiences,
		Beliefs:          opts.Beliefs,
		Assumptions:      opts.Assumptions,
		RulesForLiving:   opts.RulesForLiving,
		Events:           opts.Events,
		Thoughts:         opts.Thoughts,
		Behaviours:       opts.Behaviours,
	}, nil
}
