# cbt

A journal for cognitive behavioural therapy thought records.

It records what you write and shows it back to you. It does not interpret an
entry, score it, or tell you what it means.

## The two exercises

**Thought record** — the six column record:

| Event | Negative thought(s) | Negative feeling(s) | Cognitive bias | Is there any other way I can look at this? | How do I feel now? |
|---|---|---|---|---|---|

It is written in two sittings. The event, the thoughts and the feelings are
captured at the time; the alternative view, the biases and the re-rating come
later, usually the same evening. `cbt challenge` records that second part, and
`cbt list thought-records --unchallenged` is the queue of records still waiting
for it.

**Map of worry** — tracing one event through to the behaviour it produced:

| Event | Thoughts | What these thoughts mean | Physical sensations | Feelings | Resultant behaviour |
|---|---|---|---|---|---|

Writing a second, healthier map of the same event with `--alternative-to` links
the two so they can be read side by side. That contrast is the exercise.

## Using it

```sh
# start a server
cbt serve --database ~/.cbt.db

# write a record in the moment
cbt create thought-record "a meeting was moved without telling me" \
  --at "3h ago" \
  --hot-thought "they do not think my input matters" --bias mind-reading \
  --feeling anxious=80 --feeling annoyed=45

# later, work through it
cbt get thought-record 1
cbt challenge 1 \
  --alternative "the invite may simply have failed to send" \
  --rerate 1=20 --feelings-now "steadier"

# what is still waiting
cbt list thought-records --unchallenged
```

Feelings are rated 0-100 and re-rated during the challenge, because seeing
"anxious 80% → 20%" is what tells you whether the alternative view landed. The
rating is always optional: writing down that you felt ashamed is worth
something even when you are in no state to put a number on it.

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
