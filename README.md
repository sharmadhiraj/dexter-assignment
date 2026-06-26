# Dexter

An always-listening Android app that continuously transcribes ambient audio using the Groq Whisper
API.

---

## How it works

Two independent systems run in parallel:

**Android (native service)**
`AlwaysListeningService` is a foreground service that records audio in fixed-duration chunks using
`AudioRecord`, converts each chunk to a WAV file, and writes it to the app's internal files
directory (`filesDir`).

**Flutter (BLoC + polling)**
`TranscriptionCubit` polls the same directory every 3 seconds. When it finds a WAV file, it uploads
it to the Groq Whisper STT API, displays the transcript, persists state to `SharedPreferences`, and
deletes the file.

The two systems share only the filesystem — there is no direct callback or channel between them
after the service is started.

---

## Setup

**1. Get a Groq API key**
Sign up at https://console.groq.com (free, no credit card). The free tier allows 2,000 requests/day.

**2. Set the key**
Open `lib/config/constants.dart` and replace the placeholder:

```dart

static const String apiToken = "your_groq_api_key_here";
```

**3. Run**

```bash
flutter pub get
flutter run
```

The app requests microphone permission at launch. The recording service starts automatically 1.5
seconds after the app opens.

---

## Configuration

All recording parameters live at the top of `AlwaysListeningService.kt`:

```kotlin
private val sampleRate = 16000   // Hz — matches Whisper's native rate
private val channelCount = 1       // mono is sufficient for speech
private val chunkDurationMs = 10000L  // 10s per clip
```

The Flutter poll interval is in `TranscriptionCubit` (`lib/features/home/bloc/home.dart`):

```
const Duration(
  seconds: 3
) // how often to check for new WAV files
```

---

## Service state management

The Android recording service is a foreground service (`startForeground`) declared with
`android:foregroundServiceType="microphone"`. Understanding how it behaves in each state is
important for reliability.

### Foreground (app visible)

Normal operation. Service records continuously, Flutter polls and uploads without interruption.

### App backgrounded (app not visible, screen on)

Service continues recording unaffected — foreground services are not subject to background execution
limits. Flutter's polling timer also continues as long as the Flutter engine is alive.

### Screen off / Doze mode

Android's Doze mode restricts background work, but foreground services are explicitly exempt.
However, some OEM battery optimisation layers (Xiaomi MIUI, Samsung One UI, Huawei EMUI) may still
terminate the service regardless. To ensure reliable continuous operation, users should exempt the
app from battery optimisation in device settings.

### Service killed and restarted

`onStartCommand` returns `START_STICKY`, so Android restarts the service automatically after it is
killed. On restart, `onStartCommand` is called with a null intent and recording resumes immediately.
Any WAV file that was partially written before the kill is left on disk and picked up by the Flutter
poller on the next tick.

### App killed by user

Killing the app terminates the Flutter engine (stopping the poller) but does not immediately stop a
foreground service on most Android versions. The service continues recording briefly before Android
eventually cleans it up. On next launch, `TranscriptionCubit.init()` restores persisted transcripts
and API count from `SharedPreferences` before polling resumes.

### Retry and failure handling

- If an upload fails, the WAV file is kept on disk and retried on the next poll tick.
- After 3 consecutive failures on the same file, it is deleted to prevent it from blocking newer
  chunks.
- Only one upload runs at a time — concurrent poll ticks are ignored while an upload is in progress.

---

## Project structure

```
lib/
  config/
    constants.dart             # API key, Groq endpoint, MethodChannel name
    app_theme.dart             # colours and theme
  core/network/
    api_service.dart           # Groq Whisper HTTP client
  features/home/
    bloc/home.dart             # TranscriptionCubit, TranscriptionState
    data/
      transcript_entry.dart    # TranscriptEntry model (text + timestamp)
      transcript_response.dart # Groq API response parser
    repo/home.dart             # TranscriptionRepository
    presentation/
      home.dart                # HomeScreen and card widgets
      widgets/
        listening_banner.dart  # animated banner with live session timer
        transcript_card.dart   # tap-to-copy transcript card

android/.../
  service/AlwaysListeningService.kt  # foreground mic recording service
  MainActivity.kt                    # MethodChannel + permission handling
```

---

## Known limits

| Limit                           | Value                                         |
|---------------------------------|-----------------------------------------------|
| Groq free tier                  | 2,000 requests/day (~5.5 hours at 10s chunks) |
| Transcripts shown and persisted | Last 5                                        |
| Minimum Android version         | API 26 (Android 8.0)                          |
