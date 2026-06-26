import 'dart:async';
import 'dart:io';

import 'package:dexter_assignment/features/home/data/transcript_request.dart';
import 'package:dexter_assignment/features/home/data/transcript_response.dart';
import 'package:dexter_assignment/features/home/repo/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class HomeState {
  final int apiCallCount;
  final List<String> transcripts;

  HomeState({
    this.apiCallCount = 0,
    this.transcripts = const [],
  });

  HomeState updateState(String transcript) {
    final updated = List<String>.from(transcripts);
    if (updated.length >= 3) updated.removeAt(0);
    return HomeState(
      apiCallCount: apiCallCount + 1,
      transcripts: [...updated, transcript],
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  Timer? _timer;

  void init() {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (Timer timer) async {
        final File? file = await _getFileToUpload();
        if (file != null) {
          await _uploadAudioFile(file);
        }
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<File?> _getFileToUpload() async {
    try {
      Directory appDocDir = await getApplicationSupportDirectory();
      final List<File> entities = appDocDir
          .listSync()
          .whereType<File>()
          .where((element) => element.path.contains("final_"))
          .toList();
      debugPrint("${entities.length} files to upload.");
      return entities.firstOrNull;
    } catch (e) {
      debugPrint("Error _getFileToUpload : $e");
    }
    return null;
  }

  Future<void> _uploadAudioFile(File file) async {
    try {
      final TranscriptResponse response =
          await HomeRepo.uploadAudioFile(TranscriptRequest(file.path));
      if (!isClosed) emit(state.updateState(response.transcript));
      if (file.existsSync()) file.deleteSync();
    } catch (e) {
      debugPrint("Error _uploadAudioFile : $e");
    }
  }
}
