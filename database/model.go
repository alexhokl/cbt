package database

import (
	"time"

	"gorm.io/gorm"
)

// User is an authenticated Tailscale user. It is created on first sight by
// the Tailscale authentication interceptor and referenced by TailscaleAddress
// and every per-user record (CognitiveBias, ThoughtRecord, MapOfWorry,
// BehaviouralExperiment, PositiveDataLog, NegativeThought, Feeling and the
// rows hanging off a positive data log).
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

// ThoughtRecord is the thought record: event, negative thought(s), negative
// feeling(s), cognitive bias, "is there any other way I can look at this?",
// "what evidence do you have to support this alternative view?", and "how much
// do you still believe your initial thoughts? how do you feel now?".
//
// The exercise is deliberately split across two sittings. Event, thoughts and
// feelings are captured during distress; AlternativeView, the evidence for it,
// the biases on each thought, and the re-rating of each thought and feeling
// are filled in later, ideally the same evening. ChallengedAt records when the second sitting
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
	// EvidenceForAlternative answers "what evidence do you have to support
	// this alternative view?". It is stored verbatim apart from surrounding
	// whitespace.
	EvidenceForAlternative string `gorm:""`
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
	// Evidence answers "what evidence do you have that supports this
	// thought?". It is optional, may be written with the thought or added
	// later, and is stored verbatim apart from surrounding whitespace.
	Evidence string `gorm:""`
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
	// BeliefAfter is the 0-100 answer to "how much do you still believe this
	// thought?", given during the challenge, or nil until it has been asked.
	// There is deliberately no rating from the first sitting to compare it
	// against.
	BeliefAfter *int
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

// Feeling is a single emotion rated on a 0-100 scale, attached to a
// ThoughtRecord, a MapOfWorry or a BehaviouralExperiment. Exactly one of the
// three foreign keys is set.
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
	// IntensityAfter is the 0-100 re-rating given during the challenge of a
	// ThoughtRecord, or once a BehaviouralExperiment has been carried out. A
	// map of worry has no second sitting, so a map's feelings are rated once.
	//
	// On an experiment a feeling may carry IntensityAfter alone: what was
	// actually felt is not limited to what was predicted.
	IntensityAfter *int
	// ThoughtRecordID, MapOfWorryID and BehaviouralExperimentID are mutually
	// exclusive. The feelings_one_parent triggers enforce that exactly one is
	// set, which GORM cannot express as a struct tag.
	ThoughtRecordID         *uint `gorm:"index"`
	MapOfWorryID            *uint `gorm:"index"`
	BehaviouralExperimentID *uint `gorm:"index"`
	UserID                  uint  `gorm:"not null;index"`
	User                    User  `gorm:"foreignKey:UserID"`
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

// BehaviouralExperiment is the thought record for behavioural experiments:
// "what are you going to try?", "what do you predict will happen and how will
// you feel?", "what actually happened?", "what have you learned from this?",
// and "how can you build on this?".
//
// Like a thought record it is written in two sittings. Plan and Prediction,
// with the feelings predicted, are written before the experiment; Outcome,
// Learned and BuildOn, with what was actually felt, afterwards. CompletedAt
// records when the second sitting happened and is what
// ListBehaviouralExperiments filters on, so the experiments not yet carried
// out form a queue.
//
// Only Plan is required. Every other column is optional so that an experiment
// can be written up a piece at a time.
type BehaviouralExperiment struct {
	gorm.Model
	// Plan answers "what are you going to try?". It is stored verbatim apart
	// from surrounding whitespace.
	Plan string `gorm:"not null"`
	// OccurredAt is when the experiment is, or was, carried out. It is nil
	// when the user did not say; see ThoughtRecord.OccurredAt.
	OccurredAt *time.Time
	// Prediction answers "what do you predict will happen and how will you
	// feel?" in prose. The numeric side of how it will feel lives in
	// Feeling.IntensityBefore.
	Prediction string `gorm:""`
	// Outcome answers "what actually happened?".
	Outcome string `gorm:""`
	// Learned answers "what have you learned from this?".
	Learned string `gorm:""`
	// BuildOn answers "how can you build on this?".
	BuildOn string `gorm:""`
	// CompletedAt is set when the outcome is recorded and nil beforehand.
	CompletedAt *time.Time `gorm:"index"`
	UserID      uint       `gorm:"not null;index"`
	User        User       `gorm:"foreignKey:UserID"`
	// Feelings are the emotions predicted before the experiment and rated
	// again afterwards, together with any felt but not predicted.
	Feelings []Feeling `gorm:"foreignKey:BehaviouralExperimentID"`
}

// PositiveDataLog is the positive data log: a self-critical belief and how
// strongly it is believed, an alternative belief and how strongly that is
// believed, and the evidence, gathered over time, that supports the
// alternative and weakens the old belief.
//
// The log is meant to be returned to. Evidence is added a row at a time as it
// is noticed, and both beliefs are re-rated on each return, so the ratings are
// kept as a dated history rather than overwritten. The application stores what
// the user wrote and rated; it never computes a trend or a score from it.
//
// Only Belief is required.
type PositiveDataLog struct {
	gorm.Model
	// Belief is the self-critical belief being challenged. It is stored
	// verbatim apart from surrounding whitespace.
	Belief string `gorm:"not null"`
	// AlternativeBelief is the belief offered in its place. It is stored
	// verbatim apart from surrounding whitespace.
	AlternativeBelief string `gorm:""`
	UserID            uint   `gorm:"not null;index"`
	User              User   `gorm:"foreignKey:UserID"`
	// Evidence is what supports the alternative belief and weakens the old
	// one, in the order it was written down.
	Evidence []PositiveDataLogEvidence `gorm:"foreignKey:PositiveDataLogID"`
	// Ratings are how strongly each belief was held, oldest first.
	Ratings []BeliefRating `gorm:"foreignKey:PositiveDataLogID"`
}

// PositiveDataLogEvidence is a single row of evidence in a PositiveDataLog.
type PositiveDataLogEvidence struct {
	gorm.Model
	// Body is the evidence as the user phrased it, stored verbatim apart from
	// surrounding whitespace.
	Body string `gorm:"not null"`
	// NotedAt is when the evidence happened, which is frequently not when it
	// was typed. It is nil when the user did not say; see
	// ThoughtRecord.OccurredAt.
	NotedAt           *time.Time
	PositiveDataLogID uint `gorm:"not null;index"`
	UserID            uint `gorm:"not null;index"`
	User              User `gorm:"foreignKey:UserID"`
}

// TableName pins the table name for PositiveDataLogEvidence. GORM's
// pluraliser treats "evidence" as uncountable, which would give the singular
// "positive_data_log_evidence"; the name is written out literally in the
// search subquery, so it is fixed here rather than left to inference.
func (PositiveDataLogEvidence) TableName() string {
	return "positive_data_log_evidences"
}

// BeliefRating is one rating of both beliefs of a PositiveDataLog, on a 0-100
// scale. A log carries one per sitting: the first when the log is opened, and
// another each time the user comes back to it. Either percentage may be left
// out, but not both; the belief_ratings_not_empty triggers enforce that.
type BeliefRating struct {
	gorm.Model
	// RatedAt is when the rating was given.
	RatedAt time.Time `gorm:"not null;index"`
	// BeliefPercent is how strongly the self-critical belief was held, or nil
	// when it was not rated this time.
	BeliefPercent *int
	// AlternativePercent is how strongly the alternative belief was held, or
	// nil when it was not rated this time.
	AlternativePercent *int
	PositiveDataLogID  uint `gorm:"not null;index"`
	UserID             uint `gorm:"not null;index"`
	User               User `gorm:"foreignKey:UserID"`
}
