package cmd

import (
	"testing"
)

// stubFlags reports which flags were typed, standing in for a pflag.FlagSet so
// the request builders can be tested without constructing a command.
type stubFlags struct {
	changed map[string]bool
}

func (s stubFlags) Changed(name string) bool {
	return s.changed[name]
}

func TestBuildCreateThoughtRecordRequestSendsOnlyTheEventByDefault(t *testing.T) {
	req, err := buildCreateThoughtRecordRequest([]string{"a meeting was moved"}, createThoughtRecordOptions{}, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetEvent() != "a meeting was moved" {
		t.Errorf("unexpected event %q", req.GetEvent())
	}
	if req.OccurredAt != nil {
		t.Error("expected no event time when --at was not given")
	}
	if len(req.GetThoughts()) != 0 || len(req.GetFeelings()) != 0 {
		t.Error("expected no thoughts or feelings")
	}
}

func TestBuildCreateThoughtRecordRequestPutsTheHotThoughtFirst(t *testing.T) {
	opts := createThoughtRecordOptions{
		HotThought: "they do not think my input matters",
		Thoughts:   []string{"I will be left out of the next one", "I should have spoken up sooner"},
		Biases:     []string{"mind-reading"},
	}

	req, err := buildCreateThoughtRecordRequest([]string{"a meeting was moved without telling me"}, opts, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if len(req.GetThoughts()) != 3 {
		t.Fatalf("expected 3 thoughts but got %d", len(req.GetThoughts()))
	}
	if !req.GetThoughts()[0].GetIsHot() {
		t.Error("expected the strongest thought to come first")
	}
	// A bias belongs to a thought, not to the record: two thoughts about the
	// same event routinely carry different distortions.
	if len(req.GetThoughts()[0].GetBiases()) != 1 {
		t.Errorf("expected the bias on the strongest thought but got %d", len(req.GetThoughts()[0].GetBiases()))
	}
	for _, thought := range req.GetThoughts()[1:] {
		if thought.GetIsHot() {
			t.Error("expected only one thought to be marked as the strongest")
		}
		if len(thought.GetBiases()) != 0 {
			t.Error("expected biases only on the strongest thought")
		}
	}
}

func TestBuildCreateThoughtRecordRequestRejectsBiasesWithoutAHotThought(t *testing.T) {
	// Naming a bias with nothing to attach it to would otherwise be silently
	// dropped, losing work the user thought they had recorded.
	opts := createThoughtRecordOptions{Biases: []string{"blaming"}}

	if _, err := buildCreateThoughtRecordRequest([]string{"an event"}, opts, referenceNow); err == nil {
		t.Error("expected --bias without --hot-thought to be rejected")
	}
}

func TestBuildCreateThoughtRecordRequestPutsTheEvidenceOnTheHotThought(t *testing.T) {
	opts := createThoughtRecordOptions{
		HotThought:  "I will be late for everything today",
		HotEvidence: "the next train is full",
		Thoughts:    []string{"the meeting will start without me"},
	}

	req, err := buildCreateThoughtRecordRequest([]string{"the last train was cancelled"}, opts, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetThoughts()[0].GetEvidence() != "the next train is full" {
		t.Errorf("expected the evidence on the strongest thought but got %q", req.GetThoughts()[0].GetEvidence())
	}
	if req.GetThoughts()[1].GetEvidence() != "" {
		t.Errorf("expected no evidence on the other thought but got %q", req.GetThoughts()[1].GetEvidence())
	}
}

func TestBuildCreateThoughtRecordRequestRejectsEvidenceWithoutAHotThought(t *testing.T) {
	opts := createThoughtRecordOptions{HotEvidence: "the next train is full"}

	if _, err := buildCreateThoughtRecordRequest([]string{"an event"}, opts, referenceNow); err == nil {
		t.Error("expected --hot-thought-evidence without --hot-thought to be rejected")
	}
}

func TestBuildUpdateThoughtRequest(t *testing.T) {
	tests := []struct {
		name     string
		opts     updateThoughtOptions
		changed  map[string]bool
		wantErr  bool
		evidence string
	}{
		// A bare command would otherwise blank the evidence by accident.
		{"no flag is rejected", updateThoughtOptions{}, map[string]bool{}, true, ""},
		{"evidence is sent", updateThoughtOptions{Evidence: "two of the last five trains ran late"}, map[string]bool{"evidence": true}, false, "two of the last five trains ran late"},
		{"an explicit blank is sent", updateThoughtOptions{Evidence: ""}, map[string]bool{"evidence": true}, false, ""},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			req, err := buildUpdateThoughtRequest([]string{"7"}, test.opts, stubFlags{changed: test.changed})
			if test.wantErr {
				if err == nil {
					t.Error("expected an error")
				}
				return
			}
			if err != nil {
				t.Fatalf("failed to build the request: %v", err)
			}
			if req.GetId() != 7 || req.GetEvidence() != test.evidence {
				t.Errorf("unexpected request %v", req)
			}
		})
	}
}

func TestParseFeelingsAcceptsRatedAndUnratedFeelings(t *testing.T) {
	feelings, err := parseFeelings([]string{"anxious=80", "ashamed", "angry=40%"})
	if err != nil {
		t.Fatalf("failed to parse the feelings: %v", err)
	}

	if len(feelings) != 3 {
		t.Fatalf("expected 3 feelings but got %d", len(feelings))
	}
	if feelings[0].GetIntensity() != 80 {
		t.Errorf("expected 80 but got %d", feelings[0].GetIntensity())
	}
	// Writing down that you felt ashamed is worth something even when you are
	// in no state to put a number on it, so the rating stays optional.
	if feelings[1].Intensity != nil {
		t.Error("expected an unrated feeling to carry no rating")
	}
	if feelings[2].GetIntensity() != 40 {
		t.Errorf("expected a trailing percent sign to be tolerated but got %d", feelings[2].GetIntensity())
	}
}

func TestParseFeelingsRejectsBadInput(t *testing.T) {
	tests := []struct {
		name  string
		input string
	}{
		{"no name", "=80"},
		{"a non numeric rating", "anxious=high"},
		{"a rating above one hundred", "anxious=120"},
		{"a negative rating", "anxious=-5"},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := parseFeelings([]string{test.input}); err == nil {
				t.Errorf("expected %q to be rejected", test.input)
			}
		})
	}
}

func TestBuildListThoughtRecordsRequestSelectsTheWorkQueue(t *testing.T) {
	tests := []struct {
		name     string
		opts     listThoughtRecordsOptions
		expected *bool
	}{
		{"unfiltered", listThoughtRecordsOptions{}, nil},
		{"unchallenged", listThoughtRecordsOptions{Unchallenged: true}, boolPtr(false)},
		{"challenged", listThoughtRecordsOptions{Challenged: true}, boolPtr(true)},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			req, err := buildListThoughtRecordsRequest(test.opts, referenceNow)
			if err != nil {
				t.Fatalf("failed to build the request: %v", err)
			}

			switch {
			case test.expected == nil && req.Challenged != nil:
				t.Errorf("expected no filter but got %v", req.GetChallenged())
			case test.expected != nil && req.Challenged == nil:
				t.Error("expected a filter but got none")
			case test.expected != nil && req.GetChallenged() != *test.expected:
				t.Errorf("expected %v but got %v", *test.expected, req.GetChallenged())
			}
		})
	}
}

func TestBuildUpdateThoughtRecordRequestSendsOnlyTypedFlags(t *testing.T) {
	opts := updateThoughtRecordOptions{
		Event:           "a clearer description",
		AlternativeView: "",
		FeelingsNow:     "",
	}
	flags := stubFlags{changed: map[string]bool{"event": true}}

	req, err := buildUpdateThoughtRecordRequest([]string{"3"}, opts, flags, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.Event == nil || req.GetEvent() != "a clearer description" {
		t.Errorf("expected the event to be sent but got %v", req.Event)
	}
	// Sending every flag unconditionally would blank the columns the user did
	// not mention, which is the opposite of filling a record in a piece at a
	// time.
	if req.AlternativeView != nil {
		t.Error("expected an untyped alternative view to be left absent")
	}
	if req.FeelingsNow != nil {
		t.Error("expected an untyped feelings-now to be left absent")
	}
	if req.EvidenceForAlternative != nil {
		t.Error("expected untyped evidence to be left absent")
	}
}

func TestBuildUpdateThoughtRecordRequestSendsTypedEvidence(t *testing.T) {
	opts := updateThoughtRecordOptions{Evidence: "the timetable lists a signal fault"}
	flags := stubFlags{changed: map[string]bool{"evidence": true}}

	req, err := buildUpdateThoughtRecordRequest([]string{"3"}, opts, flags, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.EvidenceForAlternative == nil || req.GetEvidenceForAlternative() != "the timetable lists a signal fault" {
		t.Errorf("expected the evidence to be sent but got %v", req.EvidenceForAlternative)
	}
}

func TestBuildUpdateThoughtRecordRequestSendsAnExplicitBlank(t *testing.T) {
	// Typing --alternative "" is an instruction to blank the column, which is
	// why presence rather than emptiness is what decides.
	opts := updateThoughtRecordOptions{AlternativeView: ""}
	flags := stubFlags{changed: map[string]bool{"alternative": true}}

	req, err := buildUpdateThoughtRecordRequest([]string{"3"}, opts, flags, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.AlternativeView == nil {
		t.Fatal("expected an explicitly blanked column to be sent")
	}
	if req.GetAlternativeView() != "" {
		t.Errorf("expected a blank value but got %q", req.GetAlternativeView())
	}
}

func TestBuildUpdateMapOfWorryRequestSendsOnlyTypedFlags(t *testing.T) {
	opts := updateMapOfWorryOptions{
		Behaviour: "went for the walk anyway",
		Thoughts:  "unmentioned",
	}
	flags := stubFlags{changed: map[string]bool{"behaviour": true}}

	req, err := buildUpdateMapOfWorryRequest([]string{"1"}, opts, flags, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.ResultantBehaviour == nil || req.GetResultantBehaviour() != "went for the walk anyway" {
		t.Errorf("expected the behaviour to be sent but got %v", req.ResultantBehaviour)
	}
	if req.Thoughts != nil {
		t.Error("expected an untyped thoughts column to be left absent")
	}
}

func TestBuildCreateMapOfWorryRequestLinksTheAlternativeOnlyWhenAsked(t *testing.T) {
	opts := createMapOfWorryOptions{AlternativeTo: 0}

	t.Run("not given", func(t *testing.T) {
		req, err := buildCreateMapOfWorryRequest([]string{"an event"}, opts, false, referenceNow)
		if err != nil {
			t.Fatalf("failed to build the request: %v", err)
		}
		if req.DerivedFromId != nil {
			t.Error("expected no link when --alternative-to was not given")
		}
	})

	t.Run("given as zero", func(t *testing.T) {
		// An explicit zero is a mistake worth reporting from the server, not
		// one to silently swallow into "no link".
		req, err := buildCreateMapOfWorryRequest([]string{"an event"}, opts, true, referenceNow)
		if err != nil {
			t.Fatalf("failed to build the request: %v", err)
		}
		if req.DerivedFromId == nil {
			t.Error("expected an explicit zero to be sent")
		}
	})
}

func TestBuildChallengeRequestParsesReratingsAndBiases(t *testing.T) {
	opts := challengeOptions{
		AlternativeView: "he is forgetful rather than uninterested",
		FeelingsNow:     "calmer",
		Reratings:       []string{"4=20", "5=0"},
		ThoughtBiases:   []string{"7=catastrophising,mind-reading"},
	}

	req, err := buildChallengeRequest([]string{"3"}, opts)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetId() != 3 {
		t.Errorf("expected record 3 but got %d", req.GetId())
	}
	if len(req.GetFeelingReratings()) != 2 {
		t.Fatalf("expected 2 re-ratings but got %d", len(req.GetFeelingReratings()))
	}
	if req.GetFeelingReratings()[0].GetFeelingId() != 4 || req.GetFeelingReratings()[0].GetIntensityAfter() != 20 {
		t.Errorf("unexpected re-rating %v", req.GetFeelingReratings()[0])
	}
	// A re-rating of zero is the most meaningful outcome the exercise has, so
	// it must survive parsing rather than being read as absent.
	if req.GetFeelingReratings()[1].GetIntensityAfter() != 0 {
		t.Error("expected a re-rating of zero to be kept")
	}
	if len(req.GetThoughts()) != 1 || len(req.GetThoughts()[0].GetBiases().GetNames()) != 2 {
		t.Errorf("expected two biases on one thought but got %v", req.GetThoughts())
	}
}

func TestBuildChallengeRequestRejectsMalformedPairs(t *testing.T) {
	tests := []struct {
		name string
		opts challengeOptions
	}{
		{"a re-rating without an equals", challengeOptions{Reratings: []string{"4"}}},
		{"a re-rating out of range", challengeOptions{Reratings: []string{"4=120"}}},
		{"a re-rating with a bad id", challengeOptions{Reratings: []string{"x=20"}}},
		{"a bias without an equals", challengeOptions{ThoughtBiases: []string{"catastrophising"}}},
		{"a bias with a bad id", challengeOptions{ThoughtBiases: []string{"x=blaming"}}},
		{"a factual id that is not a number", challengeOptions{Factual: []string{"seven"}}},
		{"a not-factual id that is not a number", challengeOptions{NotFactual: []string{"seven"}}},
		{"a thought given to both factual and not-factual", challengeOptions{Factual: []string{"7"}, NotFactual: []string{"7"}}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := buildChallengeRequest([]string{"3"}, test.opts); err == nil {
				t.Error("expected the malformed input to be rejected")
			}
		})
	}
}

func TestParseRecordIDRejectsUnusableValues(t *testing.T) {
	tests := []string{"0", "-1", "abc", "", "1.5"}

	for _, input := range tests {
		t.Run(input, func(t *testing.T) {
			if _, err := parseRecordID(input); err == nil {
				t.Errorf("expected %q to be rejected", input)
			}
		})
	}
}

func TestRequiresServiceOnlyAppliesToClientCommands(t *testing.T) {
	// serve is the server; forcing it to supply a client-only flag would make
	// it impossible to start.
	if requiresService(serveCmd) {
		t.Error("expected serve not to require a service URI")
	}
	if !requiresService(createThoughtRecordCmd) {
		t.Error("expected create thought-record to require a service URI")
	}
	if requiresService(nil) {
		t.Error("expected a nil command not to require a service URI")
	}
}

func TestRequireSecureConnectionTreatsLoopbackAsLocal(t *testing.T) {
	tests := []struct {
		uri      string
		expected bool
	}{
		{"localhost:8080", false},
		{"127.0.0.1:8080", false},
		{"[::1]:8080", false},
		{"", false},
		{"cbt.tail1234.ts.net:8080", true},
	}

	for _, test := range tests {
		t.Run(test.uri, func(t *testing.T) {
			if got := requireSecureConnection(test.uri); got != test.expected {
				t.Errorf("expected %v but got %v", test.expected, got)
			}
		})
	}
}

// boolPtr returns a pointer to the given value, for the optional filter field.
func boolPtr(value bool) *bool {
	return &value
}

func TestBuildChallengeRequestClearsBiasesWithAnEmptyList(t *testing.T) {
	// "7=" detaches every bias from thought 7. That is how a thought carrying
	// no distortion is recorded, and how a bias attached by mistake is taken
	// off again, so it must be accepted rather than read as a malformed flag.
	req, err := buildChallengeRequest([]string{"3"}, challengeOptions{ThoughtBiases: []string{"7="}})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if len(req.GetThoughts()) != 1 {
		t.Fatalf("expected 1 judgement but got %d", len(req.GetThoughts()))
	}
	judgement := req.GetThoughts()[0]
	if judgement.GetThoughtId() != 7 {
		t.Errorf("expected thought 7 but got %d", judgement.GetThoughtId())
	}
	// The wrapper must be present but empty: absent would mean "leave the
	// biases alone", which is the opposite instruction.
	if judgement.Biases == nil {
		t.Fatal("expected the biases wrapper to be sent")
	}
	if len(judgement.GetBiases().GetNames()) != 0 {
		t.Errorf("expected no bias names but got %d", len(judgement.GetBiases().GetNames()))
	}
}

func TestBuildChallengeRequestMarksThoughtsFactual(t *testing.T) {
	req, err := buildChallengeRequest([]string{"3"}, challengeOptions{
		Factual:    []string{"7"},
		NotFactual: []string{"8"},
	})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if len(req.GetThoughts()) != 2 {
		t.Fatalf("expected 2 judgements but got %d", len(req.GetThoughts()))
	}

	byID := map[uint32]bool{}
	for _, judgement := range req.GetThoughts() {
		byID[judgement.GetThoughtId()] = judgement.GetIsFactual()
		// Neither flag says anything about biases, so the wrapper stays absent
		// and whatever the thought carries is left alone.
		if judgement.Biases != nil {
			t.Errorf("expected no bias instruction for thought %d", judgement.GetThoughtId())
		}
	}
	if !byID[7] {
		t.Error("expected thought 7 to be marked factual")
	}
	if byID[8] {
		t.Error("expected thought 8 not to be marked factual")
	}
	for _, judgement := range req.GetThoughts() {
		if judgement.IsFactual == nil {
			t.Errorf("expected thought %d to carry an explicit factual judgement", judgement.GetThoughtId())
		}
	}
}

func TestBuildChallengeRequestRatesBeliefWithoutTouchingFactual(t *testing.T) {
	req, err := buildChallengeRequest([]string{"3"}, challengeOptions{
		Evidence:      "the calendar shows the invite as unsent",
		ThoughtBiases: []string{"7=mind-reading"},
		Beliefs:       []string{"7=30%", "8=0"},
	})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetEvidenceForAlternative() != "the calendar shows the invite as unsent" {
		t.Errorf("unexpected evidence %q", req.GetEvidenceForAlternative())
	}
	if len(req.GetThoughts()) != 2 {
		t.Fatalf("expected 2 judgements but got %d", len(req.GetThoughts()))
	}

	beliefs := map[uint32]int32{}
	for _, judgement := range req.GetThoughts() {
		if judgement.BeliefAfter == nil {
			t.Fatalf("expected thought %d to carry a belief", judgement.GetThoughtId())
		}
		beliefs[judgement.GetThoughtId()] = judgement.GetBeliefAfter()
		// Saying how much a thought is still believed says nothing about
		// whether it was accurate, so an earlier factual judgement is kept.
		if judgement.IsFactual != nil {
			t.Errorf("expected no factual instruction for thought %d", judgement.GetThoughtId())
		}
	}
	if beliefs[7] != 30 || beliefs[8] != 0 {
		t.Errorf("unexpected beliefs %v", beliefs)
	}
}

func TestParseBeliefRejectsMalformedValues(t *testing.T) {
	tests := []string{"7", "7=", "7=abc", "7=101", "7=-1", "x=30", "0=30"}

	for _, value := range tests {
		t.Run(value, func(t *testing.T) {
			if _, _, err := parseBelief(value); err == nil {
				t.Errorf("expected %q to be rejected", value)
			}
		})
	}
}

func TestBuildChallengeRequestFoldsFlagsIntoOneJudgement(t *testing.T) {
	// --bias and --factual naming the same thought must produce one judgement,
	// not two that could contradict each other on the wire.
	req, err := buildChallengeRequest([]string{"3"}, challengeOptions{
		ThoughtBiases: []string{"7="},
		Factual:       []string{"7"},
	})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if len(req.GetThoughts()) != 1 {
		t.Fatalf("expected 1 judgement but got %d", len(req.GetThoughts()))
	}
	judgement := req.GetThoughts()[0]
	if !judgement.GetIsFactual() {
		t.Error("expected the thought to be marked factual")
	}
	if judgement.Biases == nil || len(judgement.GetBiases().GetNames()) != 0 {
		t.Error("expected the biases to be cleared in the same judgement")
	}
}

func TestBuildCreateBehaviouralExperimentRequestCarriesThePrediction(t *testing.T) {
	req, err := buildCreateBehaviouralExperimentRequest(
		[]string{"ask a question at the end of the team meeting"},
		createBehaviouralExperimentOptions{
			At:         "yesterday",
			Prediction: "someone will think it is obvious",
			Feelings:   []string{"embarrassed=70"},
		},
		referenceNow,
	)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetPlan() != "ask a question at the end of the team meeting" {
		t.Errorf("unexpected plan %q", req.GetPlan())
	}
	if req.GetPrediction() != "someone will think it is obvious" {
		t.Errorf("unexpected prediction %q", req.GetPrediction())
	}
	if req.OccurredAt == nil {
		t.Error("expected an experiment time from --at")
	}
	if len(req.GetFeelings()) != 1 || req.GetFeelings()[0].GetIntensity() != 70 {
		t.Errorf("expected one feeling predicted at 70 but got %v", req.GetFeelings())
	}
}

func TestBuildUpdateBehaviouralExperimentRequestSendsOnlyTypedFlags(t *testing.T) {
	opts := updateBehaviouralExperimentOptions{
		Plan:    "not typed",
		Outcome: "there were empty seats",
	}
	req, err := buildUpdateBehaviouralExperimentRequest([]string{"2"}, opts, stubFlags{changed: map[string]bool{"outcome": true}}, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetId() != 2 {
		t.Errorf("unexpected id %d", req.GetId())
	}
	if req.Outcome == nil || req.GetOutcome() != "there were empty seats" {
		t.Errorf("expected the typed outcome to be sent but got %v", req.Outcome)
	}
	for name, value := range map[string]*string{
		"plan":       req.Plan,
		"prediction": req.Prediction,
		"learned":    req.Learned,
		"build-on":   req.BuildOn,
	} {
		if value != nil {
			t.Errorf("expected --%s to be left out but got %q", name, *value)
		}
	}
	if req.OccurredAt != nil {
		t.Error("expected no experiment time when --at was not typed")
	}
}

func TestBuildCompleteRequestParsesReratingsAndNewFeelings(t *testing.T) {
	req, err := buildCompleteRequest([]string{"2"}, completeOptions{
		Outcome:   "two people said they had the same question",
		Learned:   "the question was worth asking",
		BuildOn:   "ask the next one during the meeting",
		Reratings: []string{"5=20"},
		Feelings:  []string{"relieved=50"},
	})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetOutcome() != "two people said they had the same question" ||
		req.GetLearned() != "the question was worth asking" ||
		req.GetBuildOn() != "ask the next one during the meeting" {
		t.Errorf("unexpected prose %q / %q / %q", req.GetOutcome(), req.GetLearned(), req.GetBuildOn())
	}
	if len(req.GetFeelingReratings()) != 1 ||
		req.GetFeelingReratings()[0].GetFeelingId() != 5 ||
		req.GetFeelingReratings()[0].GetIntensityAfter() != 20 {
		t.Errorf("unexpected re-ratings %v", req.GetFeelingReratings())
	}
	if len(req.GetNewFeelings()) != 1 ||
		req.GetNewFeelings()[0].GetName() != "relieved" ||
		req.GetNewFeelings()[0].GetIntensity() != 50 {
		t.Errorf("unexpected new feelings %v", req.GetNewFeelings())
	}
}

func TestBuildCompleteRequestRejectsMalformedInput(t *testing.T) {
	tests := []struct {
		name string
		opts completeOptions
	}{
		{"re-rating without a rating", completeOptions{Reratings: []string{"5"}}},
		{"re-rating out of range", completeOptions{Reratings: []string{"5=150"}}},
		{"feeling without a name", completeOptions{Feelings: []string{"=50"}}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := buildCompleteRequest([]string{"2"}, test.opts); err == nil {
				t.Error("expected the input to be rejected")
			}
		})
	}
}

func TestBuildListBehaviouralExperimentsRequestSelectsTheQueue(t *testing.T) {
	tests := []struct {
		name     string
		opts     listBehaviouralExperimentsOptions
		expected *bool
	}{
		{"everything", listBehaviouralExperimentsOptions{}, nil},
		{"not completed", listBehaviouralExperimentsOptions{NotCompleted: true}, boolPtr(false)},
		{"completed", listBehaviouralExperimentsOptions{Completed: true}, boolPtr(true)},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			req, err := buildListBehaviouralExperimentsRequest(test.opts, referenceNow)
			if err != nil {
				t.Fatalf("failed to build the request: %v", err)
			}
			switch {
			case test.expected == nil && req.Completed != nil:
				t.Errorf("expected no completion filter but got %v", req.GetCompleted())
			case test.expected != nil && (req.Completed == nil || req.GetCompleted() != *test.expected):
				t.Errorf("expected completed=%v but got %v", *test.expected, req.Completed)
			}
		})
	}
}

func TestBuildCreatePositiveDataLogRequest(t *testing.T) {
	req, err := buildCreatePositiveDataLogRequest([]string{"I am always late"}, createPositiveDataLogOptions{
		Alternative:        "I am on time for most things",
		Believe:            "70%",
		BelieveAlternative: "0",
		Evidence:           []string{"arrived early for the dentist", "caught the first train on Monday"},
	})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}

	if req.GetBelief() != "I am always late" || req.GetAlternativeBelief() != "I am on time for most things" {
		t.Errorf("unexpected beliefs %q and %q", req.GetBelief(), req.GetAlternativeBelief())
	}
	if req.BeliefPercent == nil || req.GetBeliefPercent() != 70 {
		t.Errorf("expected the belief rated 70 but got %v", req.BeliefPercent)
	}
	// Zero is a rating, not the absence of one.
	if req.AlternativePercent == nil || req.GetAlternativePercent() != 0 {
		t.Errorf("expected the alternative rated 0 but got %v", req.AlternativePercent)
	}
	if len(req.GetEvidence()) != 2 {
		t.Errorf("expected two rows of evidence but got %d", len(req.GetEvidence()))
	}
}

func TestBuildCreatePositiveDataLogRequestLeavesRatingsOut(t *testing.T) {
	req, err := buildCreatePositiveDataLogRequest([]string{"I am always late"}, createPositiveDataLogOptions{})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}
	if req.BeliefPercent != nil || req.AlternativePercent != nil {
		t.Error("expected no rating when none was given")
	}
}

func TestBuildCreatePositiveDataLogRequestRejectsBadInput(t *testing.T) {
	tests := []struct {
		name string
		opts createPositiveDataLogOptions
	}{
		{"belief out of range", createPositiveDataLogOptions{Believe: "101"}},
		{"alternative not a number", createPositiveDataLogOptions{BelieveAlternative: "most"}},
		{"blank evidence", createPositiveDataLogOptions{Evidence: []string{" "}}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := buildCreatePositiveDataLogRequest([]string{"I am always late"}, test.opts); err == nil {
				t.Error("expected the input to be rejected")
			}
		})
	}
}

func TestBuildCreateEvidenceRequest(t *testing.T) {
	req, err := buildCreateEvidenceRequest([]string{"4", "arrived early for the dentist"}, createEvidenceOptions{At: "yesterday"}, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}
	if req.GetLogId() != 4 {
		t.Errorf("expected log 4 but got %d", req.GetLogId())
	}
	if req.GetEvidence().GetBody() != "arrived early for the dentist" {
		t.Errorf("unexpected evidence %q", req.GetEvidence().GetBody())
	}
	if req.GetEvidence().NotedAt == nil {
		t.Error("expected the evidence to be dated")
	}

	undated, err := buildCreateEvidenceRequest([]string{"4", "caught the first train on Monday"}, createEvidenceOptions{}, referenceNow)
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}
	if undated.GetEvidence().NotedAt != nil {
		t.Error("expected no date when --at was not given")
	}

	for _, args := range [][]string{{"0", "arrived early"}, {"4", "  "}} {
		if _, err := buildCreateEvidenceRequest(args, createEvidenceOptions{}, referenceNow); err == nil {
			t.Errorf("expected %q to be rejected", args)
		}
	}
}

func TestBuildRerateRequest(t *testing.T) {
	req, err := buildRerateRequest([]string{"4"}, rerateOptions{BelieveAlternative: "45"})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}
	if req.GetLogId() != 4 {
		t.Errorf("expected log 4 but got %d", req.GetLogId())
	}
	if req.BeliefPercent != nil {
		t.Errorf("expected the belief unrated but got %d", req.GetBeliefPercent())
	}
	if req.GetAlternativePercent() != 45 {
		t.Errorf("expected the alternative rated 45 but got %d", req.GetAlternativePercent())
	}

	tests := []struct {
		name string
		opts rerateOptions
	}{
		{"nothing rated", rerateOptions{}},
		{"out of range", rerateOptions{Believe: "-5"}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := buildRerateRequest([]string{"4"}, test.opts); err == nil {
				t.Error("expected the input to be rejected")
			}
		})
	}
}

func TestBuildUpdatePositiveDataLogRequestSendsOnlyChangedFlags(t *testing.T) {
	opts := updatePositiveDataLogOptions{Belief: "", Alternative: "I am on time for nearly everything"}
	req, err := buildUpdatePositiveDataLogRequest([]string{"4"}, opts, stubFlags{changed: map[string]bool{"alternative": true}})
	if err != nil {
		t.Fatalf("failed to build the request: %v", err)
	}
	if req.Belief != nil {
		t.Errorf("expected the belief not to be sent but got %q", req.GetBelief())
	}
	if req.AlternativeBelief == nil || req.GetAlternativeBelief() != "I am on time for nearly everything" {
		t.Errorf("unexpected alternative %v", req.AlternativeBelief)
	}
}
