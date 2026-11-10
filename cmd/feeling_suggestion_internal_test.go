package cmd

import (
	"slices"
	"testing"

	"github.com/alexhokl/cbt/database"
	"github.com/spf13/cobra"
)

func TestFeelingSuggestions(t *testing.T) {
	seen := make(map[string]bool)
	for _, suggestion := range feelingSuggestions {
		if seen[suggestion.Name] {
			t.Errorf("duplicate suggestion %q", suggestion.Name)
		}
		seen[suggestion.Name] = true

		if got := database.NormaliseFeelingName(suggestion.Name); got != suggestion.Name {
			t.Errorf("suggestion %q is not normalised, want %q", suggestion.Name, got)
		}
		if suggestion.Category == "" || suggestion.Description == "" {
			t.Errorf("suggestion %q has no category or description", suggestion.Name)
		}
	}

	for _, category := range []string{"happy", "angry", "anxious", "depressed"} {
		if seen[category] {
			t.Errorf("category %q must not be offered as a feeling", category)
		}
	}
}

func TestCompleteFeeling(t *testing.T) {
	tests := []struct {
		name          string
		toComplete    string
		wantCount     int
		wantFirst     string
		wantDirective cobra.ShellCompDirective
	}{
		{
			name:          "empty offers every suggestion",
			toComplete:    "",
			wantCount:     len(feelingSuggestions),
			wantFirst:     "content\thappy: peaceful, satisfied, and comfortable with your current state",
			wantDirective: cobra.ShellCompDirectiveNoSpace | cobra.ShellCompDirectiveNoFileComp,
		},
		{
			name:          "prefix filters by name",
			toComplete:    "fr",
			wantCount:     1,
			wantFirst:     "frustrated\tangry: annoyed or blocked when trying to achieve a goal",
			wantDirective: cobra.ShellCompDirectiveNoSpace | cobra.ShellCompDirectiveNoFileComp,
		},
		{
			name:          "prefix is case insensitive",
			toComplete:    "Wor",
			wantCount:     1,
			wantFirst:     "worried\tanxious: preoccupied with thoughts of potential negative outcomes",
			wantDirective: cobra.ShellCompDirectiveNoSpace | cobra.ShellCompDirectiveNoFileComp,
		},
		{
			name:          "no match",
			toComplete:    "xyz",
			wantCount:     0,
			wantDirective: cobra.ShellCompDirectiveNoSpace | cobra.ShellCompDirectiveNoFileComp,
		},
		{
			name:          "rating is not completed",
			toComplete:    "worried=7",
			wantCount:     0,
			wantDirective: cobra.ShellCompDirectiveNoFileComp,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, directive := completeFeeling(nil, nil, tt.toComplete)
			if len(got) != tt.wantCount {
				t.Fatalf("got %d completions, want %d: %v", len(got), tt.wantCount, got)
			}
			if tt.wantFirst != "" && got[0] != tt.wantFirst {
				t.Errorf("first completion = %q, want %q", got[0], tt.wantFirst)
			}
			if directive != tt.wantDirective {
				t.Errorf("directive = %v, want %v", directive, tt.wantDirective)
			}
		})
	}

	if got, _ := completeFeeling(nil, nil, ""); slices.ContainsFunc(got, func(c string) bool { return c == "" }) {
		t.Error("empty completion returned")
	}
}
