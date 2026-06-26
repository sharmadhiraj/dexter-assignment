import 'package:dexter_assignment/config/app_theme.dart';
import 'package:dexter_assignment/features/home/bloc/home.dart';
import 'package:dexter_assignment/features/home/presentation/widgets/listening_banner.dart';
import 'package:dexter_assignment/features/home/presentation/widgets/transcript_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<TranscriptionCubit, TranscriptionState>(
        builder: (_, state) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const ListeningBanner(),
            const SizedBox(height: 12),
            _ApiCallCard(count: state.uploadCount),
            const SizedBox(height: 28),
            _TranscriptsSection(transcripts: state.transcripts),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 20,
      title: const Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.tealLight,
            child: Text(
              "D",
              style: TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 10),
          _UserInfo(),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Dhiraj",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        Text(
          "Active session",
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ApiCallCard extends StatelessWidget {
  final int count;

  const _ApiCallCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.swap_vert_rounded,
                color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 14),
          const Text(
            "API calls",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            "$count",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TranscriptsSection extends StatelessWidget {
  final List<String> transcripts;

  const _TranscriptsSection({required this.transcripts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RECENT TRANSCRIPTS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        if (transcripts.isEmpty)
          const _EmptyTranscripts()
        else
          ...transcripts.reversed.toList().asMap().entries.map(
                (e) => TranscriptCard(text: e.value, isLatest: e.key == 0),
              ),
      ],
    );
  }
}

class _EmptyTranscripts extends StatelessWidget {
  const _EmptyTranscripts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.graphic_eq_rounded,
              color: AppColors.iconDisabled, size: 32),
          SizedBox(height: 10),
          Text(
            "Waiting for transcripts",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
