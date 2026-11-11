# cbt

A journal for cognitive behavioural therapy thought records.

It records what you write and shows it back to you. It does not interpret an
entry, score it, or tell you what it means.

## The four exercises

**Thought record**:

| Event | Negative thought(s) | Negative feeling(s) | Cognitive bias | Is there any other way I can look at this? | What evidence do you have to support this alternative view? | How much do you still believe your initial thoughts? How do you feel now? |
|---|---|---|---|---|---|---|

It is written in two sittings. The event, the thoughts and the feelings are
captured at the time; the alternative view and the evidence for it, the biases,
and the re-rating of each thought and feeling come later, usually the same evening. `cbt challenge` records that second part, and
`cbt list thought-records --unchallenged` is the queue of records still waiting
for it.

**Map of worry** — tracing one event through to the behaviour it produced:

| Event | Thoughts | What these thoughts mean | Physical sensations | Feelings | Resultant behaviour |
|---|---|---|---|---|---|

Writing a second, healthier map of the same event with `--alternative-to` links
the two so they can be read side by side. That contrast is the exercise.

**Thought record for behavioural experiments**:

| What are you going to try? | What do you predict will happen and how will you feel? | What actually happened? | What have you learned from this? | How can you build on this? |
|---|---|---|---|---|

Like a thought record, it is written in two sittings. The plan and the
prediction come before the experiment, with each feeling you predict rated
0-100. What actually happened, what you learned and how you can build on it
come after, together with how strongly each feeling was actually felt.
`cbt complete` records that second part, and
`cbt list experiments --not-completed` is the queue of experiments still to be
carried out.

**Positive data log** — challenging a self-critical belief over time:

| Self-critical belief | How strongly I believe this | Alternative belief | How strongly I believe this | Evidence to support the alternative belief and weaken the old belief |
|---|---|---|---|---|

A log is meant to be returned to. Evidence is added a row at a time as you
notice it, with `cbt create evidence`, and both beliefs are rated again
whenever you come back to it, with `cbt rerate`. Earlier ratings are kept with
their dates rather than overwritten, so `cbt get data-log` shows each one.

## Using it

```sh
# start a server
cbt serve --database ~/.cbt.db

# write a record in the moment
cbt create thought-record "a meeting was moved without telling me" \
  --at "3h ago" \
  --hot-thought "they do not think my input matters" --bias mind-reading \
  --hot-thought-evidence "nobody asked me about the new time" \
  --feeling anxious=80 --feeling annoyed=45

# evidence for a thought can be added or changed at any time, without
# marking the record as worked through
cbt update thought 1 --evidence "the last two invites came from the same calendar"

# later, work through it
cbt get thought-record 1
cbt challenge 1 \
  --alternative "the invite may simply have failed to send" \
  --evidence "the calendar shows the invite as unsent" \
  --believe 1=30 --rerate 1=20 --feelings-now "steadier"

# what is still waiting
cbt list thought-records --unchallenged

# plan a behavioural experiment
cbt create experiment "ask a question at the end of the team meeting" \
  --prediction "someone will think it is obvious" \
  --feeling embarrassed=70

# afterwards, write up how it went
cbt get experiment 1
cbt complete 1 \
  --outcome "two people said they had the same question" \
  --learned "the question was worth asking" \
  --build-on "ask the next one during the meeting" \
  --rerate 1=20 --feeling relieved=50

cbt list experiments --not-completed

# open a positive data log
cbt create data-log "I am always late" \
  --alternative "I am on time for most things" \
  --believe 70 --believe-alternative 30 \
  --evidence "arrived early for the dentist"

# add evidence as you notice it, and rate both beliefs again later
cbt create evidence 1 "caught the first train on Monday" --at yesterday
cbt rerate 1 --believe 55 --believe-alternative 45
cbt get data-log 1
cbt list data-logs
```

Feelings are rated 0-100 and re-rated during the challenge, because seeing
"anxious 80% → 20%" is what tells you whether the alternative view landed.
`--believe` records how much you still believe each thought, also 0-100. Every
rating is optional: writing down that you felt ashamed is worth
something even when you are in no state to put a number on it.

Naming a feeling precisely is hard in the moment, so a list of feeling words
is suggested as you type: in the app's feeling field, and as shell completion
for `--feeling`. Each word is shown with its group (happy, angry, anxious or
depressed) and a short description, but only the word is recorded. The list is
a suggestion, not a vocabulary: any other name is accepted as typed.

The nine standard cognitive biases are seeded for you and cannot be renamed
or deleted, so a record written a year ago still reads the same way.
`cbt create bias` adds your own alongside them.

## Configuration

`--service` (the server address), `--config`, `--insecure` and `--verbose` are
persistent flags. Values also come from `CBT_`-prefixed environment variables
and from a config file at `os.UserConfigDir()/cbt/config.yaml`
(`~/Library/Application Support/cbt/config.yaml` on macOS,
`~/.config/cbt/config.yaml` on Linux).

The database is data rather than configuration and defaults to `$HOME/.cbt.db`.

## The mobile client

`mobile/` is a Flutter app for Android and macOS. Its reason to exist is the
challenge screen: working through a record is something you do at night, away
from a terminal. Set the server address in Settings; there is nothing to log
in to.

## Android Device Setup

### Enable Developer Options

1. On the Android device, go to `Settings` → `About phone`
2. Tap **Build number** 7 times until you see "You are now a developer!"
3. Go back to `Settings` → **Developer options**
4. Enable **USB debugging**

### Pair an Android device using Android Studio

1. On the Android device, go to `Settings` → `Developer options` → enable **Wireless debugging**
2. Tap **Pair device with pairing code** — note the IP address, port, and pairing code shown
3. In Android Studio, open the device dropdown in the toolbar and select **Pair Devices Using Wi-Fi**
4. Click **Pair using pairing code** and enter the IP address, port, and pairing code from the device
5. Once paired, the device will appear in the device list and can be selected for running/debugging

### Uninstall the app from a connected Android device using adb

To remove the existing installation (required when the signing key has changed):

```sh
adb uninstall com.alexhokl.cbt
```

### Install the app on a connected Android device using adb

Build the APK with `task apk`, then ensure the device is connected via USB with
USB debugging enabled and appears in:

```sh
adb devices
```

Then install the APK:

```sh
adb install mobile/build/app/outputs/flutter-apk/app-release.apk
```

If upgrading an existing installation signed with the same key, use the `-r` flag:

```sh
adb install -r mobile/build/app/outputs/flutter-apk/app-release.apk
```

## Privacy

Records live only on the server you run. There is no account and no third
party.

Authentication is by Tailscale identity. Run `cbt serve --hostname <name>
--ts-auth-key <key>` and the server joins your tailnet, resolves each caller to
a user and keeps their records separate. Without `--hostname` it listens
locally and everything belongs to one local user.

Telemetry, when enabled, carries identifiers, counts and outcomes only. No part
of a record is ever exported.

## Building

```
task build    task test    task lint    task sec
task proto    task serve   task apk     task mac
```
