import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dexter_assignment/features/home/data/transcript_entry.dart';
import 'package:dexter_assignment/features/home/repo/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Sentinel {
  const _Sentinel();
}

class TranscriptionState {
  static const _sentinel = _Sentinel();

  final int uploadCount;
  final List<TranscriptEntry> transcripts;
  final bool isUploading;
  final String? lastError;

  const TranscriptionState({
    this.uploadCount = 0,
    this.transcripts = const <TranscriptEntry>[],
    this.isUploading = false,
    this.lastError,
  });

  // Pass null to clear lastError; omit to keep existing value.
  TranscriptionState copyWith({
    bool? isUploading,
    Object? lastError = _sentinel,
  }) =>
      TranscriptionState(
        uploadCount: uploadCount,
        transcripts: transcripts,
        isUploading: isUploading ?? this.isUploading,
        lastError: identical(lastError, _sentinel)
            ? this.lastError
            : lastError as String?,
      );

  TranscriptionState withNewTranscript(String text) {
    final kept = transcripts.length >= 5
        ? transcripts.sublist(1)
        : List<TranscriptEntry>.from(transcripts);
    return TranscriptionState(
      uploadCount: uploadCount + 1,
      transcripts: [
        ...kept,
        TranscriptEntry(text: text, capturedAt: DateTime.now()),
      ],
      isUploading: false,
      lastError: null,
    );
  }
}

class TranscriptionCubit extends Cubit<TranscriptionState> {
  TranscriptionCubit() : super(const TranscriptionState());

  Timer? _pollTimer;
  bool _isProcessing = false;
  final Map<String, int> _failCounts = {};

  Future<void> init() async {
    debugPrint("TranscriptionCubit: init");
    await _loadPersistedState();
    _startPolling();
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  void _startPolling() {
    debugPrint("TranscriptionCubit: polling started (every 3s)");
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _processNextFile(),
    );
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt("uploadCount") ?? 0;
      final stored = prefs.getStringList("transcripts") ?? [];
      final transcripts = stored
          .map(
            (s) => TranscriptEntry.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            ),
          )
          .toList();
      debugPrint(
          "TranscriptionCubit: loaded persisted state — $count uploads, ${transcripts.length} transcripts");
      if (!isClosed) {
        emit(TranscriptionState(uploadCount: count, transcripts: transcripts));
      }
    } catch (e) {
      debugPrint("TranscriptionCubit: failed to load persisted state: $e");
    }
  }

  Future<void> _persist(TranscriptionState s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("uploadCount", s.uploadCount);
      await prefs.setStringList(
        "transcripts",
        s.transcripts.map((e) => jsonEncode(e.toJson())).toList(),
      );
    } catch (e) {
      debugPrint("TranscriptionCubit: failed to persist state: $e");
    }
  }

  Future<void> _processNextFile() async {
    if (_isProcessing) return;
    final file = await _nextPendingFile();
    if (file != null) {
      debugPrint(
          "TranscriptionCubit: file found — ${file.uri.pathSegments.last}");
      await _transcribeAndEmit(file);
    }
  }

  Future<File?> _nextPendingFile() async {
    try {
      final dir = await getApplicationSupportDirectory();
      return dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains("final_"))
          .firstOrNull;
    } catch (e) {
      debugPrint("TranscriptionCubit: failed to scan directory: $e");
      return null;
    }
  }

  Future<void> _transcribeAndEmit(File file) async {
    _isProcessing = true;
    debugPrint("TranscriptionCubit: uploading ${file.uri.pathSegments.last}");
    if (!isClosed) emit(state.copyWith(isUploading: true));
    try {
      final transcript = await TranscriptionRepository.upload(file.path);
      final text = transcript.text.trim();
      if (text.isEmpty) {
        debugPrint("TranscriptionCubit: silent chunk — skipping");
        if (file.existsSync()) file.deleteSync();
        if (!isClosed) emit(state.copyWith(isUploading: false));
        return;
      }
      debugPrint(
          "TranscriptionCubit: transcript received — \"${text.length > 80 ? "${text.substring(0, 80)}..." : text}\"");
      final next = state.withNewTranscript(text);
      if (!isClosed) emit(next);
      await _persist(next);
      if (file.existsSync()) file.deleteSync();
    } catch (e) {
      final fails = (_failCounts[file.path] ?? 0) + 1;
      _failCounts[file.path] = fails;
      if (fails >= 3) {
        debugPrint(
            "TranscriptionCubit: giving up on ${file.uri.pathSegments.last} after $fails failures — deleting");
        if (file.existsSync()) file.deleteSync();
        _failCounts.remove(file.path);
        if (!isClosed)
          emit(state.copyWith(isUploading: false, lastError: null));
      } else {
        debugPrint(
            "TranscriptionCubit: upload failed ($fails/3) — will retry: $e");
        if (!isClosed) {
          emit(
            state.copyWith(
              isUploading: false,
              lastError: "Upload failed — will retry",
            ),
          );
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
}
