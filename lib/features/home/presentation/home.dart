import 'package:dexter_assignment/features/home/bloc/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Row(
        children: [
          Padding(
            padding: EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Eren",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        _buildPopupMenuButton(),
      ],
    );
  }

  PopupMenuButton _buildPopupMenuButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {},
      itemBuilder: (BuildContext context) {
        return ["Logout", "Settings"].map(
          (String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          },
        ).toList();
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          _buildTranscriptsSection(context),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Always Listening",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("This app is always listening to you."),
        Text("Every 10 seconds, we send that audio to our STT API."),
        Text("The last 3 transcripts will be shown on the screen."),
        Text(
            "Additionally, we show a timer that indicates since when the app is listening."),
      ],
    );
  }

  Widget _buildTranscriptsSection(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: context.read<HomeCubit>()..init(),
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApiCallCounterSection(state.apiCallCount),
            _buildLastTranscriptsSection(state.transcripts),
          ],
        );
      },
    );
  }

  Widget _buildApiCallCounterSection(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Text(
              "API call counter",
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLastTranscriptsSection(List<String> transcripts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Last STT transcripts",
          style: TextStyle(color: Colors.black54),
        ),
        ...transcripts.map((e) => _buildTranscriptItem(e)).toList(),
      ],
    );
  }

  Widget _buildTranscriptItem(String transcript) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.black54),
        ),
        color: Colors.white,
      ),
      child: Text(transcript),
    );
  }
}
