import 'dart:async';
import 'dart:io';

import 'package:dexter_assignment/features/home/data/transcript_request.dart';
import 'package:dexter_assignment/features/home/data/transcript_response.dart';
import 'package:dexter_assignment/features/home/repo/home.dart';
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
    if (transcripts.length >= 3) {
      transcripts.removeAt(0);
    }
    return HomeState(
      apiCallCount: apiCallCount + 1,
      transcripts: [...transcripts, transcript],
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  void init() {
    Timer.periodic(
      const Duration(seconds: 3),
      (Timer timer) async {
        final File? file = await _getFileToUpload();
        if (file != null) {
          _uploadAudioFile(file);
        }
      },
    );
  }

  Future<File?> _getFileToUpload() async {
    try {
      Directory appDocDir = await getApplicationSupportDirectory();
      final List<File> entities = appDocDir
          .listSync()
          .whereType<File>()
          .where((element) => element.path.contains("final_"))
          .toList();
      print("${entities.length} files to upload.");
      return entities.firstOrNull;
    } catch (e) {
      print("Error _getFileToUpload : $e");
    }
    return null;
  }

  Future<void> _uploadAudioFile(File file) async {
    try {
      final TranscriptResponse response =
          await HomeRepo.uploadAudioFile(TranscriptRequest(file.path));
      emit(state.updateState(response.transcript));
      if (file.existsSync()) file.deleteSync();
    } catch (e) {
      print("Error _uploadAudioFile : $e");
    }
  }
}
