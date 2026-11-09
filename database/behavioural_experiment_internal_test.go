package database

import (
	"errors"
	"testing"
	"time"
)

func boolPtr(value bool) *bool {
	return &value
}

func stringPtr(value string) *string {
	return &value
}

func TestCreateBehaviouralExperimentRequiresAPlan(t *testing.T) {
	db := setupTestDB(t)

	tests := []struct {
		name string
		plan string
	}{
		{"empty", ""},
		{"whitespace", "  \n"},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{Plan: test.plan})
			if !errors.Is(err, ErrPlanEmpty) {
				t.Errorf("expected ErrPlanEmpty but got %v", err)
			}
		})
	}
}

func TestCreateBehaviouralExperimentStoresThePrediction(t *testing.T) {
	db := setupTestDB(t)

	experiment, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:       "  ask a question at the end of the team meeting ",
		Prediction: "someone will think it is obvious",
		Feelings:   []FeelingInput{{Name: "Embarrassed", Intensity: intPtr(70)}},
	})
	if err != nil {
		t.Fatalf("failed to create the experiment: %v", err)
	}

	if experiment.Plan != "ask a question at the end of the team meeting" {
		t.Errorf("expected the plan to be trimmed but got %q", experiment.Plan)
	}
	if experiment.Prediction != "someone will think it is obvious" {
		t.Errorf("unexpected prediction %q", experiment.Prediction)
	}
	if experiment.CompletedAt != nil {
		t.Error("expected a new experiment not to be completed")
	}
	if len(experiment.Feelings) != 1 {
		t.Fatalf("expected one feeling but got %d", len(experiment.Feelings))
	}
	feeling := experiment.Feelings[0]
	if feeling.Name != "embarrassed" {
		t.Errorf("expected a normalised feeling name but got %q", feeling.Name)
	}
	if feeling.IntensityBefore == nil || *feeling.IntensityBefore != 70 {
		t.Errorf("expected the predicted rating 70 but got %v", feeling.IntensityBefore)
	}
	if feeling.IntensityAfter != nil {
		t.Errorf("expected no rating after but got %v", *feeling.IntensityAfter)
	}
}

func TestCompleteBehaviouralExperimentStampsAndFills(t *testing.T) {
	db := setupTestDB(t)

	experiment, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:     "ask a question at the end of the team meeting",
		Feelings: []FeelingInput{{Name: "embarrassed", Intensity: intPtr(70)}},
	})
	if err != nil {
		t.Fatalf("failed to create the experiment: %v", err)
	}
	predicted := experiment.Feelings[0].ID

	completed, err := CompleteBehaviouralExperiment(db, testUserID, experiment.ID, CompleteBehaviouralExperimentInput{
		Outcome:                 "two people said they had the same question",
		Learned:                 "the question was worth asking",
		BuildOn:                 "ask the next one during the meeting",
		FeelingIntensitiesAfter: map[uint]int{predicted: 20},
		NewFeelings:             []FeelingInput{{Name: "relieved", Intensity: intPtr(50)}},
	})
	if err != nil {
		t.Fatalf("failed to complete the experiment: %v", err)
	}

	if completed.CompletedAt == nil {
		t.Error("expected the experiment to be stamped as completed")
	}
	if completed.Outcome != "two people said they had the same question" ||
		completed.Learned != "the question was worth asking" ||
		completed.BuildOn != "ask the next one during the meeting" {
		t.Errorf("unexpected second sitting %q / %q / %q", completed.Outcome, completed.Learned, completed.BuildOn)
	}
	if len(completed.Feelings) != 2 {
		t.Fatalf("expected two feelings but got %d", len(completed.Feelings))
	}

	for _, feeling := range completed.Feelings {
		switch feeling.Name {
		case "embarrassed":
			if feeling.IntensityBefore == nil || *feeling.IntensityBefore != 70 {
				t.Errorf("expected the prediction to be kept but got %v", feeling.IntensityBefore)
			}
			if feeling.IntensityAfter == nil || *feeling.IntensityAfter != 20 {
				t.Errorf("expected the re-rating 20 but got %v", feeling.IntensityAfter)
			}
		case "relieved":
			// A feeling that was not predicted has nothing to compare with,
			// so its rating is what was actually felt.
			if feeling.IntensityBefore != nil {
				t.Errorf("expected no prediction but got %v", *feeling.IntensityBefore)
			}
			if feeling.IntensityAfter == nil || *feeling.IntensityAfter != 50 {
				t.Errorf("expected the rating 50 after but got %v", feeling.IntensityAfter)
			}
		default:
			t.Errorf("unexpected feeling %q", feeling.Name)
		}
	}
}

func TestCompleteBehaviouralExperimentKeepsColumnsLeftBlank(t *testing.T) {
	db := setupTestDB(t)

	experiment, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{Plan: "take the earlier train"})
	if err != nil {
		t.Fatalf("failed to create the experiment: %v", err)
	}
	if _, err := CompleteBehaviouralExperiment(db, testUserID, experiment.ID, CompleteBehaviouralExperimentInput{
		Outcome: "the train was quiet",
	}); err != nil {
		t.Fatalf("failed to complete the experiment: %v", err)
	}

	// Coming back to an experiment is allowed and re-stamps it; a blank
	// column in the second visit does not erase the first.
	again, err := CompleteBehaviouralExperiment(db, testUserID, experiment.ID, CompleteBehaviouralExperimentInput{
		Learned: "leaving early costs less than expected",
	})
	if err != nil {
		t.Fatalf("failed to complete the experiment again: %v", err)
	}
	if again.Outcome != "the train was quiet" {
		t.Errorf("expected the outcome to be kept but got %q", again.Outcome)
	}
	if again.Learned != "leaving early costs less than expected" {
		t.Errorf("unexpected learning %q", again.Learned)
	}
}

func TestCompleteBehaviouralExperimentRejectsAnotherExperimentsFeeling(t *testing.T) {
	db := setupTestDB(t)

	first, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:     "take the earlier train",
		Feelings: []FeelingInput{{Name: "anxious", Intensity: intPtr(40)}},
	})
	if err != nil {
		t.Fatalf("failed to create the first experiment: %v", err)
	}
	second, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{Plan: "ask a question"})
	if err != nil {
		t.Fatalf("failed to create the second experiment: %v", err)
	}
	record, err := CreateThoughtRecord(db, testUserID, CreateThoughtRecordInput{
		Event:    "a meeting was moved",
		Feelings: []FeelingInput{{Name: "annoyed", Intensity: intPtr(30)}},
	})
	if err != nil {
		t.Fatalf("failed to create the record: %v", err)
	}

	tests := []struct {
		name      string
		feelingID uint
	}{
		{"another experiment", first.Feelings[0].ID},
		{"a thought record", record.Feelings[0].ID},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := CompleteBehaviouralExperiment(db, testUserID, second.ID, CompleteBehaviouralExperimentInput{
				FeelingIntensitiesAfter: map[uint]int{test.feelingID: 10},
			})
			if !errors.Is(err, ErrFeelingNotFound) {
				t.Errorf("expected ErrFeelingNotFound but got %v", err)
			}
		})
	}

	// The rejected completion must not have stamped the experiment.
	reloaded, err := GetBehaviouralExperiment(db, testUserID, second.ID)
	if err != nil {
		t.Fatalf("failed to reload the experiment: %v", err)
	}
	if reloaded.CompletedAt != nil {
		t.Error("expected a rejected completion to leave the experiment unstamped")
	}
}

func TestUpdateBehaviouralExperimentLeavesUnsetColumnsAlone(t *testing.T) {
	db := setupTestDB(t)

	experiment, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:       "take the earlier train",
		Prediction: "it will be packed",
	})
	if err != nil {
		t.Fatalf("failed to create the experiment: %v", err)
	}

	updated, err := UpdateBehaviouralExperiment(db, testUserID, experiment.ID, UpdateBehaviouralExperimentInput{
		Outcome: stringPtr("there were empty seats"),
	})
	if err != nil {
		t.Fatalf("failed to update the experiment: %v", err)
	}

	if updated.Prediction != "it will be packed" {
		t.Errorf("expected the prediction to be kept but got %q", updated.Prediction)
	}
	if updated.Outcome != "there were empty seats" {
		t.Errorf("unexpected outcome %q", updated.Outcome)
	}
	// Correcting a column is not the second sitting.
	if updated.CompletedAt != nil {
		t.Error("expected an update not to stamp the experiment as completed")
	}

	if _, err := UpdateBehaviouralExperiment(db, testUserID, experiment.ID, UpdateBehaviouralExperimentInput{
		Plan: stringPtr(" "),
	}); !errors.Is(err, ErrPlanEmpty) {
		t.Errorf("expected ErrPlanEmpty but got %v", err)
	}
}

func TestListBehaviouralExperimentsFilters(t *testing.T) {
	db := setupTestDB(t)

	lastMonth := time.Now().AddDate(0, -1, 0)
	planned, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:       "take the earlier train",
		Prediction: "it will be packed",
	})
	if err != nil {
		t.Fatalf("failed to create the planned experiment: %v", err)
	}
	done, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:       "ask a question at the end of the team meeting",
		OccurredAt: &lastMonth,
	})
	if err != nil {
		t.Fatalf("failed to create the completed experiment: %v", err)
	}
	if _, err := CompleteBehaviouralExperiment(db, testUserID, done.ID, CompleteBehaviouralExperimentInput{
		Outcome: "two people had the same question",
	}); err != nil {
		t.Fatalf("failed to complete the experiment: %v", err)
	}

	lastWeek := time.Now().AddDate(0, 0, -7)
	tests := []struct {
		name     string
		filter   BehaviouralExperimentFilter
		expected []uint
	}{
		{"everything, most recent first", BehaviouralExperimentFilter{}, []uint{planned.ID, done.ID}},
		{"not completed", BehaviouralExperimentFilter{Completed: boolPtr(false)}, []uint{planned.ID}},
		{"completed", BehaviouralExperimentFilter{Completed: boolPtr(true)}, []uint{done.ID}},
		{"since", BehaviouralExperimentFilter{Since: &lastWeek}, []uint{planned.ID}},
		{"search the prediction", BehaviouralExperimentFilter{Search: "PACKED"}, []uint{planned.ID}},
		{"search the outcome", BehaviouralExperimentFilter{Search: "same question"}, []uint{done.ID}},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			experiments, err := ListBehaviouralExperiments(db, testUserID, test.filter)
			if err != nil {
				t.Fatalf("failed to list the experiments: %v", err)
			}
			if len(experiments) != len(test.expected) {
				t.Fatalf("expected %d experiments but got %d", len(test.expected), len(experiments))
			}
			for index, id := range test.expected {
				if experiments[index].ID != id {
					t.Errorf("expected experiment %d at position %d but got %d", id, index, experiments[index].ID)
				}
			}
		})
	}
}

func TestDeleteBehaviouralExperimentRemovesItsFeelings(t *testing.T) {
	db := setupTestDB(t)

	experiment, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:     "take the earlier train",
		Feelings: []FeelingInput{{Name: "anxious", Intensity: intPtr(40)}},
	})
	if err != nil {
		t.Fatalf("failed to create the experiment: %v", err)
	}

	if err := DeleteBehaviouralExperiment(db, testUserID, experiment.ID); err != nil {
		t.Fatalf("failed to delete the experiment: %v", err)
	}

	var count int64
	if err := db.Model(&Feeling{}).Where("behavioural_experiment_id = ?", experiment.ID).Count(&count).Error; err != nil {
		t.Fatalf("failed to count the feelings: %v", err)
	}
	if count != 0 {
		t.Errorf("expected the feelings to be deleted but %d remain", count)
	}
	if _, err := GetBehaviouralExperiment(db, testUserID, experiment.ID); !errors.Is(err, ErrBehaviouralExperimentNotFound) {
		t.Errorf("expected ErrBehaviouralExperimentNotFound but got %v", err)
	}
}

func TestAddExperimentFeelingAttachesAPrediction(t *testing.T) {
	db := setupTestDB(t)

	experiment, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{Plan: "take the earlier train"})
	if err != nil {
		t.Fatalf("failed to create the experiment: %v", err)
	}

	updated, err := AddExperimentFeeling(db, testUserID, experiment.ID, FeelingInput{Name: "anxious", Intensity: intPtr(40)})
	if err != nil {
		t.Fatalf("failed to add the feeling: %v", err)
	}
	if len(updated.Feelings) != 1 || updated.Feelings[0].IntensityBefore == nil || *updated.Feelings[0].IntensityBefore != 40 {
		t.Errorf("expected one feeling predicted at 40 but got %v", updated.Feelings)
	}
}

func TestBehaviouralExperimentOperationsAreScopedToTheUser(t *testing.T) {
	db := setupTestDB(t)

	experiment, err := CreateBehaviouralExperiment(db, testUserID, CreateBehaviouralExperimentInput{
		Plan:     "take the earlier train",
		Feelings: []FeelingInput{{Name: "anxious", Intensity: intPtr(40)}},
	})
	if err != nil {
		t.Fatalf("failed to create the experiment: %v", err)
	}

	operations := []struct {
		name string
		run  func() error
	}{
		{"get", func() error {
			_, err := GetBehaviouralExperiment(db, otherUserID, experiment.ID)
			return err
		}},
		{"update", func() error {
			_, err := UpdateBehaviouralExperiment(db, otherUserID, experiment.ID, UpdateBehaviouralExperimentInput{Plan: stringPtr("something else")})
			return err
		}},
		{"complete", func() error {
			_, err := CompleteBehaviouralExperiment(db, otherUserID, experiment.ID, CompleteBehaviouralExperimentInput{})
			return err
		}},
		{"add feeling", func() error {
			_, err := AddExperimentFeeling(db, otherUserID, experiment.ID, FeelingInput{Name: "calm"})
			return err
		}},
		{"delete", func() error {
			return DeleteBehaviouralExperiment(db, otherUserID, experiment.ID)
		}},
	}

	for _, operation := range operations {
		t.Run(operation.name, func(t *testing.T) {
			if err := operation.run(); !errors.Is(err, ErrBehaviouralExperimentNotFound) {
				t.Errorf("expected ErrBehaviouralExperimentNotFound but got %v", err)
			}
		})
	}

	experiments, err := ListBehaviouralExperiments(db, otherUserID, BehaviouralExperimentFilter{})
	if err != nil {
		t.Fatalf("failed to list the experiments: %v", err)
	}
	if len(experiments) != 0 {
		t.Errorf("expected another user to see no experiments but got %d", len(experiments))
	}
}
