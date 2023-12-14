# Dexter Assignment

**Summary:**
Dexter Assignment is a project that implements an always-listening audio service in Kotlin. The
project involves capturing audio chunks, creating WAV audio files periodically, accessing these
files from Flutter using MethodChannel, uploading them to a server, and displaying the server's
response. Key technologies used include Android Service, AudioRecord, MethodChannel, Flutter Bloc,
and Clean Architecture.

## Setup

1. Clone the project.
2. Ensure Flutter is installed.
3. Run `flutter pub get` to fetch dependencies.

## Completed Tasks

- Implementation of an always-running service.
- Creation of WAV audio files at regular intervals.
- Implementation of MethodChannel to start the service and receive file paths from Kotlin to
  Flutter.
- Implementation of Bloc for state management.
- Upload of received file paths to the server, handling responses, and populating data.
- Handle audio record permission in runtime

## ToDo/Improvements

- Improve service state management (foreground and sleep modes).
- Improve the process of creating and encoding WAV files.
- Enhance MethodChannel implementation to handle inconsistencies when called from the service.
- Write tests for Kotlin methods.

I am actively working on enhancing the project and welcome any feedback!

