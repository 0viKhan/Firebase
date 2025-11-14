import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LiveScoreApp());
}

class LiveScoreApp extends StatelessWidget {
  const LiveScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LiveScore> _listOfScore = [];
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLiveScoreData();
  }

  Future<void> _getLiveScoreData() async {
    try {
      print("Fetching live scores...");
      final snapshots = await db.collection("Football").get();

      print("Documents fetched: ${snapshots.docs.length}");

      _listOfScore.clear();

      for (var doc in snapshots.docs) {
        final data = doc.data();
        print("Document data: $data");

        String team1Name = data['team1_name'] ?? data['team_1name'] ?? 'Unknown';
        String team2Name = data['team2_name'] ?? data['team_2name'] ?? 'Unknown';

        int team1Score = data['team1_score'] ??
            data['team_1score'] ??
            0;
        int team2Score = data['team2_score'] ??
            data['team_2score'] ??
            0;

        bool isRunning = data['is_running'] ?? false;
        String winnerTeam = data['winner_team'] ?? data['winnerteam'] ?? '';

        _listOfScore.add(
          LiveScore(
            id: doc.id,
            team1Name: team1Name,
            team2Name: team2Name,
            team1Score: team1Score,
            team2Score: team2Score,
            isRunning: isRunning,
            winnerTeam: winnerTeam,
          ),
        );
      }

    } catch (e) {
      print("Error fetching live scores: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scores'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listOfScore.isEmpty
          ? const Center(child: Text("No scores available"))
          : ListView.builder(
        itemCount: _listOfScore.length,
        itemBuilder: (context, index) {
          LiveScore liveScore = _listOfScore[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                liveScore.isRunning ? Colors.green : Colors.red,
                child: liveScore.isRunning
                    ? const Icon(Icons.sports_soccer, color: Colors.white)
                    : const Icon(Icons.done, color: Colors.white),
              ),
              title: Text(
                "${liveScore.team1Name} vs ${liveScore.team2Name}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Running: ${liveScore.isRunning ? 'Yes' : 'No'}"),
                  Text(
                      "Winner: ${liveScore.winnerTeam.isEmpty ? 'N/A' : liveScore.winnerTeam}"),
                ],
              ),
              trailing: Text(
                "${liveScore.team1Score} : ${liveScore.team2Score}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LiveScore {
  final String id;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final bool isRunning;
  final String winnerTeam;

  LiveScore({
    required this.id,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.isRunning,
    required this.winnerTeam,
  });
}
