package cmd

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/alexhokl/cbt/proto"
	"github.com/spf13/cobra"
)

type challengeOptions struct {
	AlternativeView string
	FeelingsNow     string
	Reratings       []string
	ThoughtBiases   []string
	Factual         []string
	NotFactual      []string
}

var challengeOpts challengeOptions

// challengeCmd records the second sitting of a thought record.
var challengeCmd = &cobra.Command{
	Use:   "challenge [id]",
	Short: "Work through a thought record: alternative view, biases, re-rating",
	Long: `Record the second sitting of a thought record.

A thought record is written in two parts. The event, the thoughts and the
feelings are captured in the moment; the alternative view, the cognitive biases
and the re-rating of each feeling come later, usually the same evening. This
command records that second part and takes the record out of the queue that
"cbt list thought-records --unchallenged" shows.

Run "cbt get thought-record <id>" first to see the thought and feeling ids.`,
	Example: `  cbt challenge 3 --alternative "the invite may simply have failed to send"
  cbt challenge 3 --bias 7=catastrophising --rerate 4=20 --feelings-now "calmer"
  cbt challenge 3 --bias 7= --factual 7`,
	Args:        cobra.ExactArgs(1),
	Annotations: map[string]string{annotationRequiresService: "true"},
	RunE:        runChallenge,
}

func init() {
	rootCmd.AddCommand(challengeCmd)

	flags := challengeCmd.Flags()
	flags.StringVar(&challengeOpts.AlternativeView, "alternative", "", "Is there any other way you can look at this?")
	flags.StringVar(&challengeOpts.FeelingsNow, "feelings-now", "", "How do you feel now?")
	flags.StringArrayVar(&challengeOpts.Reratings, "rerate", nil, "Re-rate a feeling, as feeling-id=rating (repeatable)")
	flags.StringArrayVar(&challengeOpts.ThoughtBiases, "bias", nil, "Name the biases in a thought, as thought-id=name[,name] (repeatable); thought-id= on its own detaches them")
	flags.StringArrayVar(&challengeOpts.Factual, "factual", nil, "Record that a thought was an accurate reading, by thought id (repeatable)")
	flags.StringArrayVar(&challengeOpts.NotFactual, "not-factual", nil, "Undo --factual on a thought, by thought id (repeatable)")
}

func runChallenge(cmd *cobra.Command, args []string) error {
	req, err := buildChallengeRequest(args, challengeOpts)
	if err != nil {
		return err
	}

	conn, err := dial()
	if err != nil {
		return err
	}
	defer func() { _ = conn.Close() }()

	record, err := proto.NewRecordServiceClient(conn).ChallengeThoughtRecord(cmd.Context(), req)
	if err != nil {
		return fmt.Errorf("failed to challenge the thought record: %w", err)
	}

	return writeThoughtRecordDetail(cmd.OutOrStdout(), record)
}

// buildChallengeRequest assembles the wire request from the parsed flags.
func buildChallengeRequest(args []string, opts challengeOptions) (*proto.ChallengeThoughtRecordRequest, error) {
	id, err := parseRecordID(args[0])
	if err != nil {
		return nil, err
	}

	req := &proto.ChallengeThoughtRecordRequest{
		Id:              id,
		AlternativeView: opts.AlternativeView,
		FeelingsNow:     opts.FeelingsNow,
	}

	for _, value := range opts.Reratings {
		rerating, err := parseRerating(value)
		if err != nil {
			return nil, err
		}
		req.FeelingReratings = append(req.FeelingReratings, rerating)
	}

	judgements, err := buildThoughtJudgements(opts)
	if err != nil {
		return nil, err
	}
	req.Thoughts = judgements

	return req, nil
}

// buildThoughtJudgements folds the --bias, --factual and --not-factual flags
// into one judgement per thought, so the request cannot carry two statements
// about the same thought that disagree.
func buildThoughtJudgements(opts challengeOptions) ([]*proto.ThoughtJudgement, error) {
	order := make([]uint32, 0, len(opts.ThoughtBiases))
	judgements := make(map[uint32]*proto.ThoughtJudgement, len(opts.ThoughtBiases))

	get := func(id uint32) *proto.ThoughtJudgement {
		if existing, ok := judgements[id]; ok {
			return existing
		}
		judgement := &proto.ThoughtJudgement{ThoughtId: id}
		judgements[id] = judgement
		order = append(order, id)
		return judgement
	}

	for _, value := range opts.ThoughtBiases {
		id, names, err := parseThoughtBias(value)
		if err != nil {
			return nil, err
		}
		get(id).Biases = &proto.BiasNames{Names: names}
	}

	factual := make(map[uint32]struct{}, len(opts.Factual))
	for _, value := range opts.Factual {
		id, err := parseRecordID(strings.TrimSpace(value))
		if err != nil {
			return nil, fmt.Errorf("invalid --factual %q: %w", value, err)
		}
		factual[id] = struct{}{}
		get(id).IsFactual = true
	}

	for _, value := range opts.NotFactual {
		id, err := parseRecordID(strings.TrimSpace(value))
		if err != nil {
			return nil, fmt.Errorf("invalid --not-factual %q: %w", value, err)
		}
		// Saying both about one thought is a contradiction in the command
		// itself, and reporting it here is clearer than letting whichever flag
		// happened to be applied last silently win.
		if _, ok := factual[id]; ok {
			return nil, fmt.Errorf("thought %d is given to both --factual and --not-factual", id)
		}
		get(id).IsFactual = false
	}

	result := make([]*proto.ThoughtJudgement, 0, len(order))
	for _, id := range order {
		result = append(result, judgements[id])
	}

	return result, nil
}

// parseRerating turns "feeling-id=rating" into a wire re-rating.
func parseRerating(value string) (*proto.FeelingRerating, error) {
	rawID, rawRating, ok := strings.Cut(value, "=")
	if !ok {
		return nil, fmt.Errorf("invalid re-rating %q: expected feeling-id=rating, such as 4=20", value)
	}

	feelingID, err := parseRecordID(strings.TrimSpace(rawID))
	if err != nil {
		return nil, fmt.Errorf("invalid re-rating %q: %w", value, err)
	}

	intensity, err := strconv.Atoi(strings.TrimSpace(strings.TrimSuffix(rawRating, "%")))
	if err != nil || intensity < 0 || intensity > 100 {
		return nil, fmt.Errorf("invalid re-rating %q: expected a rating between 0 and 100", value)
	}

	// Range checked immediately above, so the conversion is safe.
	return &proto.FeelingRerating{
		FeelingId:      feelingID,
		IntensityAfter: int32(intensity), // #nosec G109
	}, nil
}

// parseThoughtBias turns "thought-id=name[,name]" into a thought identifier and
// the names to attach. The named biases replace whatever the thought carried,
// so re-running a challenge with a corrected list leaves the corrected list
// rather than the union.
//
// An empty name list is accepted and meaningful: "7=" detaches every bias from
// thought 7, which is how a thought carrying no distortion is recorded, and
// how a bias attached by mistake is taken off again. Only a value with no "="
// at all is rejected, since that is a malformed flag rather than an intent.
func parseThoughtBias(value string) (uint32, []string, error) {
	rawID, rawNames, ok := strings.Cut(value, "=")
	if !ok {
		return 0, nil, fmt.Errorf("invalid bias %q: expected thought-id=name, such as 7=catastrophising", value)
	}

	thoughtID, err := parseRecordID(strings.TrimSpace(rawID))
	if err != nil {
		return 0, nil, fmt.Errorf("invalid bias %q: %w", value, err)
	}

	names := make([]string, 0, 1)
	for _, name := range strings.Split(rawNames, ",") {
		trimmed := strings.TrimSpace(name)
		if trimmed == "" {
			continue
		}
		names = append(names, trimmed)
	}

	return thoughtID, names, nil
}
