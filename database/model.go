package database

import (
	"time"

	"gorm.io/gorm"
)

// User is an authenticated Tailscale user. It is created on first sight by
// the Tailscale authentication interceptor and referenced by TailscaleAddress
// and every per-user record (CognitiveBias, ThoughtRecord, MapOfWorry,
// NegativeThought, Feeling).
//
// User creation also seeds the builtin cognitive biases for that user; see
// SeedBuiltinBiases.
type User struct {
	gorm.Model
	Username string `gorm:"not null;unique"`
}

// TailscaleAddress caches the mapping from a Tailscale peer IP address to a
// User, so the authentication interceptor can resolve subsequent requests from
// the same address without calling WhoIs again.
type TailscaleAddress struct {
	Address string `gorm:"primaryKey;not null;unique"`
	UserID  uint   `gorm:"not null"`
	User    User   `gorm:"foreignKey:UserID"`
}

// CognitiveBias is a named thinking error attached to a negative thought. The
// nine biases of the standard vocabulary are seeded per user on first sight
// and marked IsBuiltin; the user may add their own alongside them.
//
// Builtin biases are deliberately immutable. Renaming "catastrophising" would
// break the mapping back to the source material the records are keyed against,
// so RenameBias and DeleteBias reject them with ErrBiasBuiltin.
type CognitiveBias struct {
	gorm.Model
	// Name is stored in its normalised form: trimmed and lower cased, so that
	// "Blaming", " blaming " and "BLAMING" all resolve to the same bias. Use
	// NormaliseBiasName before comparing against this column.
	Name string `gorm:"not null;uniqueIndex:idx_bias_user,priority:1"`
	// IsBuiltin marks one of the nine seeded biases. Builtins cannot be
	// renamed or deleted, so the vocabulary stays fixed.
	IsBuiltin bool `gorm:"not null;default:false"`
	UserID    uint `gorm:"not null;uniqueIndex:idx_bias_user,priority:2;index"`
	User      User `gorm:"foreignKey:UserID"`
}

// TableName pins the table name for CognitiveBias. GORM's pluraliser leaves
// "bias" unchanged, which would give the singular "cognitive_bias" and break
// the convention every other table follows. The name is also written out
// literally in the trigger statements and in DeleteBias's join table query, so
// it is fixed here rather than left to inference.
func (CognitiveBias) TableName() string {
	return "cognitive_biases"
}

// ThoughtRecord is the six column thought record: event, negative thought(s),
// negative feeling(s), cognitive bias, "is there any other way I can look at
// this?", and "how do I feel now?".
//
// The exercise is deliberately split across two sittings. Event, thoughts and
// feelings are captured during distress; AlternativeView, the biases on each
// thought, and the re-rating of each feeling are filled in later, ideally the
// same evening. ChallengedAt records when the second sitting
// happened and is what ListThoughtRecords filters on, so the unchallenged
// records form the day's work queue.
//
// Only Event is required. Every other column is optional so that a record can
// be opened in the moment and completed incrementally.
type ThoughtRecord struct {
	gorm.Model
	// Event is the situation that triggered the thoughts. It is stored
	// verbatim apart from surrounding whitespace.
	Event string `gorm:"not null"`
	// OccurredAt is when the event happened, which is frequently not when the
	// record was typed. It is nil when the user did not say. Pattern spotting
	// across time of day needs the event's clock, not the keyboard's, so this
	// is kept separate from CreatedAt rather than conflated with it.
	OccurredAt *time.Time
	// AlternativeView answers "is there any other way I can look at this?".
	// The point of the exercise is an alternative thought, not a positive one.
	AlternativeView string `gorm:""`
	// FeelingsNow answers "how do I feel now?" in prose. The numeric side of
	// the same question lives in Feeling.IntensityAfter.
	FeelingsNow string `gorm:""`
	// ChallengedAt is set when the record is challenged and nil beforehand.
	ChallengedAt *time.Time `gorm:"index"`
	UserID       uint       `gorm:"not null;index"`
	User         User       `gorm:"foreignKey:UserID"`
	// Thoughts are the negative automatic thoughts recorded against the event,
	// in creation order.
	Thoughts []NegativeThought `gorm:"foreignKey:ThoughtRecordID"`
	// Feelings are the emotions recorded against the event, each rated before
	// and (once challenged) after.
	Feelings []Feeling `gorm:"foreignKey:ThoughtRecordID"`
}

// NegativeThought is a single negative automatic thought recorded against a
// ThoughtRecord. A record can carry several; the strongest is flagged IsHot,
// the one conventionally circled on paper.
type NegativeThought struct {
	gorm.Model
	// Body is the thought as the user phrased it, stored verbatim apart from
	// surrounding whitespace. Duplicates are allowed.
	Body string `gorm:"not null"`
	// IsHot marks the strongest thought of the record, the one worth
	// challenging first. At most one thought per record carries it; SetHotThought
	// clears the flag on its siblings in the same transaction.
	IsHot bool `gorm:"not null;default:false"`
	// IsFactual records that the thought was examined and judged an accurate
	// reading of the situation rather than a distorted one. Accepting that a
	// thought was accurate is a real outcome of the exercise — it leads to an
	// action plan rather than a reframe — so it is stored rather than inferred.
	//
	// It cannot be inferred, because carrying no biases is the state every
	// thought starts in: an absence would make every unexamined thought claim
	// to be factual. The three meaningful states are therefore:
	//
	//	no biases, IsFactual false  nothing has been asserted yet
	//	no biases, IsFactual true   examined, judged accurate
	//	biases,    IsFactual false  examined, a distortion was named
	//
	// The fourth combination contradicts itself and is rejected with
	// ErrThoughtFactualWithBias.
	IsFactual bool `gorm:"not null;default:false"`
	// ParentID links a thought to the thought whose meaning it is, forming the
	// chain produced by the downward arrow technique (keep asking "and what
	// would that mean?" until the core fear surfaces). The column
	// exists so the chain can be recorded without a schema rebuild; no command
	// populates it yet, since there are no versioned migrations and a fresh
	// database is otherwise required.
	ParentID        *uint            `gorm:"index"`
	Parent          *NegativeThought `gorm:"foreignKey:ParentID"`
	ThoughtRecordID uint             `gorm:"not null;index"`
	UserID          uint             `gorm:"not null;index"`
	User            User             `gorm:"foreignKey:UserID"`
	// Biases are the thinking errors identified in this thought. The bias
	// belongs to the thought rather than the record because each thought
	// carries its own distortion.
	Biases []CognitiveBias `gorm:"many2many:thought_biases;"`
}

// Feeling is a single emotion rated on a 0-100 scale, attached to either a
// ThoughtRecord or a MapOfWorry. Exactly one of the two foreign keys is set.
//
// Rating is what makes the record useful: "anxious 20% and angry 80%" says
// something that the bare words do not, and re-rating after the challenge is
// how the user sees whether the alternative view landed.
type Feeling struct {
	gorm.Model
	// Name is stored in its normalised form: trimmed and lower cased, so that
	// "Anxious" and " anxious " are the same feeling.
	Name string `gorm:"not null"`
	// IntensityBefore is the 0-100 rating given when the feeling was recorded,
	// or nil when the user did not rate it.
	IntensityBefore *int
	// IntensityAfter is the 0-100 re-rating given during the challenge. It is
	// only ever set on feelings belonging to a ThoughtRecord: a map of worry
	// has no challenge step, so a map's feelings are rated once.
	IntensityAfter *int
	// ThoughtRecordID and MapOfWorryID are mutually exclusive. The
	// feelings_single_parent triggers enforce that exactly one is set, which
	// GORM cannot express as a struct tag.
	ThoughtRecordID *uint `gorm:"index"`
	MapOfWorryID    *uint `gorm:"index"`
	UserID          uint  `gorm:"not null;index"`
	User            User  `gorm:"foreignKey:UserID"`
}

// MapOfWorry is the six column map which traces a single event all the way
// through to the behaviour it produced: event, thoughts, what those thoughts
// mean, physical sensations, feelings, resultant behaviour.
//
// Unlike a thought record it has no challenge step. The equivalent work is
// done by writing a second, healthier map of the same event and setting
// DerivedFromID to the first, so the two can be read side by side.
type MapOfWorry struct {
	gorm.Model
	// Event is the situation being mapped. Only this column is required.
	Event string `gorm:"not null"`
	// OccurredAt is when the event happened; see ThoughtRecord.OccurredAt.
	OccurredAt *time.Time
	// Thoughts are the thoughts the event produced, as prose. They are not
	// child rows here (unlike on a ThoughtRecord) because a map is a single
	// narrative chain rather than a set of thoughts to be challenged
	// individually.
	Thoughts string `gorm:""`
	// WhatTheseThoughtsMean is the meaning step, one manual application of the
	// downward arrow technique.
	WhatTheseThoughtsMean string `gorm:""`
	// PhysicalSensations records the bodily component (lethargy, sickness,
	// tension), which is often noticed before the thought behind it.
	PhysicalSensations string `gorm:""`
	// ResultantBehaviour is what the user did, or avoided doing, as a result.
	ResultantBehaviour string `gorm:""`
	// DerivedFromID points at the map this one reworks. An alternative map
	// takes the same event and follows a different thought through to a
	// different behaviour; the contrast between the two is the therapeutic
	// payload, so the link is modelled rather than left implicit.
	DerivedFromID *uint       `gorm:"index"`
	DerivedFrom   *MapOfWorry `gorm:"foreignKey:DerivedFromID"`
	UserID        uint        `gorm:"not null;index"`
	User          User        `gorm:"foreignKey:UserID"`
	// Feelings are the emotions recorded against the event, rated once.
	Feelings []Feeling `gorm:"foreignKey:MapOfWorryID"`
}
