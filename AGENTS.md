# AGENTS.md

Conventions for `cbt`, a journal for cognitive behavioural therapy thought
records. Read this before changing anything.

## What this application is

`cbt` records four standard cognitive behavioural therapy exercises:

- the **thought record** — event, negative thought(s), negative feeling(s),
  cognitive bias, "is there any other way I can look at this?", "what
  evidence do you have to support this alternative view?", "how much do you
  still believe your initial thoughts? how do you feel now?"
- the **map of worry** — event, thoughts, what these thoughts mean, physical
  sensations, feelings, resultant behaviour
- the **thought record for behavioural experiments** — "what are you going to
  try?", "what do you predict will happen and how will you feel?", "what
  actually happened?", "what have you learned from this?", "how can you build
  on this?"
- the **positive data log** — self-critical belief, how strongly I believe
  this, alternative belief, how strongly I believe this, evidence to support
  the alternative belief and weaken the old belief. The log is returned to:
  evidence is added a row at a time, and each return adds a dated
  `BeliefRating` of both beliefs beside the earlier ones, never in place of
  them

Those four shapes are the domain. When a question arises about what a column
means, what the biases are called, or how an exercise is used, the answer is
whatever keeps the exercise faithful to those columns — not an invented
improvement.

## Four rules that are not negotiable

1. **This is a journal, not a therapist.** Nothing in this application may
   interpret an entry, score it, diagnose anything, or offer advice. The
   challenge questions in `mobile/lib/widgets/challenge_page.dart` are
   quotations from the method, shown as prompts; they are not the application
   forming a view about what the user wrote. Do not add "insights",
   "suggestions", sentiment analysis, or anything that tells the user what
   their record means.

2. **No record content in telemetry.** Spans, metrics and log records carry
   identifiers, counts and outcomes only. Never attach an event, a thought, a
   feeling name, an intensity, a belief rating, a bias name, the evidence for
   a thought, an alternative view, the evidence for it, or an experiment's
   plan, prediction, outcome, learning or how to build on it, or a data log's
   beliefs, belief ratings or evidence to a span attribute,
   a metric label, or a log field. The natural instinct when adding a span is to attach `record.id`
   *and* `record.event`; attach only the first.
   Existing call sites in `internal/` show the pattern.

3. **The builtin bias vocabulary is fixed.** The nine names in
   `database.BuiltinBiasNames` are a standard, published vocabulary and are
   what a past record is read back against. They are seeded per user, and
   `RenameBias`/`DeleteBias` reject them with `ErrBiasBuiltin`. Do not make
   them editable, and do not reword them.

4. **Test fixtures and documentation examples are invented.** Never copy an
   event, thought, feeling, bias attribution, alternative view or evidence out
   of a real record, or out of anyone's personal notes, into a test, an
   `Example:` block or the README. Fixtures must be mundane, non-clinical and about nobody. The
   existing ones — a moved meeting, a cancelled train, a report full of
   comments — are the register to stay in.

## Feeling suggestions

The feeling name field (mobile) and `--feeling` completion (CLI) suggest 24
feeling words, each with its group and a description shown as
`group: description`. They differ from the bias vocabulary on purpose:

- **Suggested, not enforced.** Any other name is accepted, and nothing is
  seeded or stored in `database/`. Do not validate feeling names against the
  list.
- **Only the word is recorded.** The group and description help the user
  choose and are never sent. The group words themselves (happy, angry,
  anxious, depressed) are too generic to record and are not offered.
- **A word list offered before writing, not a reading of the entry.** Do not
  turn it into suggestions derived from what the user wrote (rule 1).
- **Kept in two places**, `cmd/feeling_suggestion.go` and
  `mobile/lib/widgets/feeling_suggestions.dart`, in the same order. Change
  both together; each file's tests check for uniqueness, normalised names and
  the absence of the group words.

## Storage and privacy

The SQLite database is **not encrypted at rest**, deliberately. SQLCipher would
mean a passphrase prompt on every invocation — friction at exactly the moment
the user is least willing to tolerate it — and the deployment model already
restricts reach to a tailnet on a disk the user controls. This is stated in the
README and in the app's settings screen rather than left for the user to
discover. If the threat model changes, change this decision explicitly.

## Layout

```
main.go            # cmd.Execute()
database/          # GORM models and operations; every invariant lives here
internal/          # gRPC server, interceptors, OTel
proto/             # record.proto and generated Go
mobile/            # Flutter client
google/protobuf/   # vendored well-known types, for protoc only
```

Packages are flat, files are `snake_case.go`, and each package has a
`package.go` holding only the package doc comment.

## Database

- **GORM + SQLite.** `AutoMigrate` only; there are **no versioned migrations**.
  Adding a table or a nullable column is safe; anything else requires a fresh
  database. Prefer adding a nullable column now over a rebuild later —
  `NegativeThought.ParentID` exists for exactly this reason.
- **Invariants the ORM cannot express are SQLite triggers**, registered in
  `schemaTriggers()` in `operation.go`. They are a backstop, not the primary
  check: the operations return a named sentinel error first so callers get a
  useful message, and the trigger catches anything that bypasses them.
- **Every query is scoped by `user_id`.** Cross-user access returns
  `ErrXxxNotFound`, never a permission error: an existence leak is still a
  leak.
- **Operations are package-level functions** taking `(db *gorm.DB, userID uint,
  ...)`. There is no repository interface; that signature is the contract.
- Multi-statement work goes in `db.Transaction(...)` so a rejected child cannot
  leave a half-built record behind.
- Names that identify something (bias names, feeling names) are **normalised**
  (trimmed, lower cased). Prose the user wrote (events, thoughts, alternative
  views) is stored verbatim apart from surrounding whitespace.

## gRPC layer

- One `RecordService`. Handlers are thin: resolve the caller, translate,
  delegate to `database`, translate back.
- `userIDFromContext` returns `Unauthenticated` when the interceptor did not
  run, so a misconfigured server rejects rather than leaks.
- All sentinel errors are translated in one place, `mapDatabaseError`. Add new
  sentinels there rather than returning a status from a handler.
- proto3 cannot mark a repeated field optional. Where "not given" must be told
  apart from "given as empty" — `UpdateThoughtRequest.biases` — wrap it in a
  message (`BiasNames`).

## CLI

- Cobra + Viper, verb first: parent stubs in `create.go`, `list.go`, `get.go`,
  `update.go`, `delete.go`; leaves in `<verb>_<noun>.go`.
- Each command is five parts: options struct, package var, command var,
  `init()` wiring, `run<Command>`. Request assembly lives in a pure
  `build<Command>Request` function so it is testable without a server.
- Commands needing the server carry `annotationRequiresService`. `serve` must
  not.
- **Update commands send only the flags the user typed** (`flags.Changed`).
  Sending every flag unconditionally would blank columns the user did not
  mention, which defeats filling a record in a piece at a time.
- Config resolves through `cli.ConfigureViper` to
  `os.UserConfigDir()/cbt/config.yaml`. The database is data, not
  configuration: it defaults to `$HOME/.cbt.db` and is overridden onto the
  volume in Docker.

## Output

- `list` uses a **narrow** `tabwriter` table. The column widths in `output.go`
  are budgeted to fit eighty columns and there is a test that fails if a row
  overflows. Six prose columns cannot be aligned into a readable table; the
  full text belongs in `get`.
- `get` uses a **vertical label and paragraph** layout with wrapping. Empty
  columns are omitted entirely: a record in progress should read as what has
  been written, not as a form with blanks in it.

## Flutter

- Plain `StatefulWidget` + `setState`. No state management package.
- Pages take an optional `RecordService? service` constructor parameter purely
  as a test seam; production builds pass null and the page builds one from the
  stored settings via `BackendConfig.buildService()`.
- **No app-side authentication.** The server authenticates by tailnet identity.
  There is no token to store and nothing to attach to a call. Do not add one.
- English only. The scaffolding for another locale is in place (`l10n.yaml`,
  `flutter: generate: true`); the bias names are established technical terms
  and a half translated set would be worse than none.
- Shared infrastructure comes from the `flutter_helper` package
  (github.com/alexhokl/flutter-helper, pinned by tag in `mobile/pubspec.yaml`):
  the gRPC channel and error mapping behind `RecordService`
  (`GrpcChannelHolder`, `ServiceException`), the `backend_url` setting that
  `BackendConfig` delegates to, `BuildInfo.gitCommit`, `formatDate`,
  `confirmDialog`, the themes and the lint configuration. Fix or extend those
  there rather than copying code into this app. The `mac`, `apk`, signing key
  and `tag` tasks are included from `../flutter-helper/taskfiles/flutter.yml`,
  which needs a sibling checkout of flutter-helper.

## Testing

- Standard library `testing`, table driven, `t.Run` subtests, manual
  `t.Errorf`/`t.Fatalf`. No testify.
- White box: `*_internal_test.go` in the same package, beside the source.
- Database tests use `setupTestDB(t)` on in-memory SQLite. It creates **two**
  users so that every operation can be shown to be scoped, not merely
  functional.
- CLI tests cover the pure `build*Request` helpers and the output writers
  against a `bytes.Buffer`. No test starts a server.
- Flutter tests are widget tests with `mocktail` fakes injected through the
  `service:` parameter.

## Commands

```
task build      task test       task lint       task sec
task proto      task l10n       task serve      task tag
```
