/// A feeling name offered while naming a feeling. Only [name] is recorded;
/// the category and description are shown to help pick the word that fits.
class FeelingSuggestion {
  const FeelingSuggestion(this.name, this.category, this.description);

  final String name;
  final String category;
  final String description;

  /// What is shown under the name: the category, then the description.
  String get label => '$category: $description';
}

/// Feeling names offered, not enforced: any other name is accepted. The
/// category words themselves are left out as too generic to record. English
/// only, like the bias names. The CLI keeps the same list in
/// cmd/feeling_suggestion.go.
const List<FeelingSuggestion> feelingSuggestions = <FeelingSuggestion>[
  FeelingSuggestion(
    'content',
    'happy',
    'peaceful, satisfied, and comfortable with your current state',
  ),
  FeelingSuggestion(
    'optimistic',
    'happy',
    'hopeful and confident about the future',
  ),
  FeelingSuggestion(
    'grateful',
    'happy',
    'warmly appreciative of kindness or good fortune',
  ),
  FeelingSuggestion(
    'joyful',
    'happy',
    'a deep, glowing sense of gladness and delight',
  ),
  FeelingSuggestion(
    'elated',
    'happy',
    'overjoyed, thrilled, and extremely high-spirited',
  ),
  FeelingSuggestion(
    'ecstatic',
    'happy',
    'experiencing overwhelming rapture or intense delight',
  ),
  FeelingSuggestion(
    'irritated',
    'angry',
    'easily annoyed by minor nuisances or setbacks',
  ),
  FeelingSuggestion(
    'frustrated',
    'angry',
    'annoyed or blocked when trying to achieve a goal',
  ),
  FeelingSuggestion(
    'indignant',
    'angry',
    'feeling anger provoked by perceived unfairness or injustice',
  ),
  FeelingSuggestion(
    'resentful',
    'angry',
    'feeling bitter or indignant about unfair treatment',
  ),
  FeelingSuggestion(
    'hostile',
    'angry',
    'unfriendly, antagonistic, and aggressive',
  ),
  FeelingSuggestion('furious', 'angry', 'extremely, intensely angry (enraged)'),
  FeelingSuggestion(
    'apprehensive',
    'anxious',
    'fearful or uneasy that something bad might happen',
  ),
  FeelingSuggestion(
    'tense',
    'anxious',
    'stiff and unable to relax due to mental pressure',
  ),
  FeelingSuggestion(
    'jittery',
    'anxious',
    'nervous, restless, and on edge physically',
  ),
  FeelingSuggestion(
    'worried',
    'anxious',
    'preoccupied with thoughts of potential negative outcomes',
  ),
  FeelingSuggestion(
    'overwhelmed',
    'anxious',
    'feeling like demands exceed your capacity to cope',
  ),
  FeelingSuggestion(
    'panicked',
    'anxious',
    'overwhelmed by sudden, intense fear and helplessness',
  ),
  FeelingSuggestion(
    'melancholy',
    'depressed',
    'experiencing a deep, quiet, and often reflective sadness',
  ),
  FeelingSuggestion(
    'dejected',
    'depressed',
    'low-spirited and disheartened by disappointment',
  ),
  FeelingSuggestion(
    'apathetic',
    'depressed',
    'feeling a lack of interest, enthusiasm, or concern (numb)',
  ),
  FeelingSuggestion(
    'despondent',
    'depressed',
    'lacking hope, deeply discouraged, and dejected',
  ),
  FeelingSuggestion(
    'grieving',
    'depressed',
    'sorrowful due to a specific loss or bereavement',
  ),
  FeelingSuggestion(
    'hopeless',
    'depressed',
    'feeling entirely devoid of optimism or a way forward',
  ),
];

/// The suggestions matching what has been typed: every one when nothing has,
/// otherwise names starting with the text, then names containing it.
List<FeelingSuggestion> matchFeelingSuggestions(String text) {
  final query = text.trim().toLowerCase();
  if (query.isEmpty) {
    return feelingSuggestions;
  }
  return <FeelingSuggestion>[
    ...feelingSuggestions.where((s) => s.name.startsWith(query)),
    ...feelingSuggestions.where(
      (s) => !s.name.startsWith(query) && s.name.contains(query),
    ),
  ];
}
