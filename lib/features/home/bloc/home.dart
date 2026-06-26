import 'dart:async';
import 'dart:io';

import 'package:dexter_assignment/features/home/repo/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class TranscriptionState {
  final int uploadCount;
  final List<String> transcripts;

  const TranscriptionState({
    this.uploadCount = 0,
    this.transcripts = const [],
  });

  TranscriptionState withNewTranscript(String text) {
    final trimmed = transcripts.length >= 3
        ? transcripts.sublist(1)
        : List<String>.from(transcripts);
    return TranscriptionState(
      uploadCount: uploadCount + 1,
      transcripts: [...trimmed, text],
    );
  }
}

class TranscriptionCubit extends Cubit<TranscriptionState> {
  TranscriptionCubit() : super(const TranscriptionState());

  Timer? _pollTimer;

  void startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _processNextFile(),
    );
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  Future<void> _processNextFile() async {
    final file = await _nextPendingFile();
    if (file != null) await _transcribeAndEmit(file);
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
    try {
      final transcript = await TranscriptionRepository.upload(file.path);
      if (!isClosed) emit(state.withNewTranscript(transcript.text));
      if (file.existsSync()) file.deleteSync();
    } catch (e) {
      debugPrint("TranscriptionCubit: upload failed: $e");
    }
  }
}
