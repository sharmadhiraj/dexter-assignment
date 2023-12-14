import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
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

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(),
          _buildApiCallCounterSection(),
          _buildLastTranscriptsSection(),
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

  Widget _buildApiCallCounterSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Text(
              "API call counter",
              style: TextStyle(color: Colors.black54),
            ),
            Text(
              "03",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLastTranscriptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Last STT transcripts",
          style: TextStyle(color: Colors.black54),
        ),
        _buildTranscriptItem(
          "Hello Hello, are you still listening? This is the test",
        ),
        _buildTranscriptItem(
          "Hello Hello, are you still listening? This is the test",
        ),
        _buildTranscriptItem(
          "Hello Hello, are you still listening? This is the test",
          withDivider: false,
        ),
      ],
    );
  }

  Widget _buildTranscriptItem(String transcript, {bool withDivider = true}) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: withDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: Colors.black54),
              ),
              color: Colors.white,
            )
          : null,
      child: Text(transcript),
    );
  }
}
