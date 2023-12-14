import 'package:dexter_assignment/features/home/data/transcript_request.dart';
import 'package:dexter_assignment/features/home/data/transcript_response.dart';
import 'package:dexter_assignment/features/home/repo/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    print("Updating state");
    return HomeState(
      apiCallCount: apiCallCount + 1,
      transcripts: [...transcripts, transcript],
    );
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  Future<void> uploadAudioFile(String filePath) async {
    final TranscriptResponse response =
        await HomeRepo.uploadAudioFile(TranscriptRequest(filePath));
    emit(state
        .updateState(DateTime.timestamp().millisecondsSinceEpoch.toString()));
  }
}
