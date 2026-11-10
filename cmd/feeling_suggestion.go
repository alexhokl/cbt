package cmd

import (
	"strings"

	"github.com/spf13/cobra"
)

// feelingSuggestion is a feeling name offered when completing --feeling. Only
// the name is recorded; the category and description are shown to help the
// user pick the word that fits, and are never sent.
type feelingSuggestion struct {
	Name        string
	Category    string
	Description string
}

// feelingSuggestions are offered, not enforced: any other name is accepted.
// The category words themselves are left out as too generic to record. The
// mobile app keeps the same list in mobile/lib/widgets/feeling_suggestions.dart.
var feelingSuggestions = []feelingSuggestion{
	{"content", "happy", "peaceful, satisfied, and comfortable with your current state"},
	{"optimistic", "happy", "hopeful and confident about the future"},
	{"grateful", "happy", "warmly appreciative of kindness or good fortune"},
	{"joyful", "happy", "a deep, glowing sense of gladness and delight"},
	{"elated", "happy", "overjoyed, thrilled, and extremely high-spirited"},
	{"ecstatic", "happy", "experiencing overwhelming rapture or intense delight"},
	{"irritated", "angry", "easily annoyed by minor nuisances or setbacks"},
	{"frustrated", "angry", "annoyed or blocked when trying to achieve a goal"},
	{"indignant", "angry", "feeling anger provoked by perceived unfairness or injustice"},
	{"resentful", "angry", "feeling bitter or indignant about unfair treatment"},
	{"hostile", "angry", "unfriendly, antagonistic, and aggressive"},
	{"furious", "angry", "extremely, intensely angry (enraged)"},
	{"apprehensive", "anxious", "fearful or uneasy that something bad might happen"},
	{"tense", "anxious", "stiff and unable to relax due to mental pressure"},
	{"jittery", "anxious", "nervous, restless, and on edge physically"},
	{"worried", "anxious", "preoccupied with thoughts of potential negative outcomes"},
	{"overwhelmed", "anxious", "feeling like demands exceed your capacity to cope"},
	{"panicked", "anxious", "overwhelmed by sudden, intense fear and helplessness"},
	{"melancholy", "depressed", "experiencing a deep, quiet, and often reflective sadness"},
	{"dejected", "depressed", "low-spirited and disheartened by disappointment"},
	{"apathetic", "depressed", "feeling a lack of interest, enthusiasm, or concern (numb)"},
	{"despondent", "depressed", "lacking hope, deeply discouraged, and dejected"},
	{"grieving", "depressed", "sorrowful due to a specific loss or bereavement"},
	{"hopeless", "depressed", "feeling entirely devoid of optimism or a way forward"},
}

// completeFeeling completes the name part of a --feeling name=rating value.
// No space is added after a name, as the rating usually follows.
func completeFeeling(_ *cobra.Command, _ []string, toComplete string) ([]string, cobra.ShellCompDirective) {
	if strings.Contains(toComplete, "=") {
		return nil, cobra.ShellCompDirectiveNoFileComp
	}

	prefix := strings.ToLower(strings.TrimSpace(toComplete))
	completions := make([]string, 0, len(feelingSuggestions))
	for _, suggestion := range feelingSuggestions {
		if strings.HasPrefix(suggestion.Name, prefix) {
			completions = append(completions, suggestion.Name+"\t"+suggestion.Category+": "+suggestion.Description)
		}
	}
	return completions, cobra.ShellCompDirectiveNoSpace | cobra.ShellCompDirectiveNoFileComp
}
