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
  List<LiveScore>_listOfScore=[];
  final FirebaseFirestore db=FirebaseFirestore.instance;



  Future<void>_getLiveScoreData()async
  {
_listOfScore.clear();

    final QuerySnapshot<Map<String, dynamic>>snapshots = await db.collection(
        "football").get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshots.docs) {
      LiveScore liveScore = LiveScore(
          id: doc.id,
          team1Name: doc.get('team1Name'),
          team2Name: doc.get("team2Name"),
          team1Score: doc.get("team1Score"),
          team2Score: doc.get("team2Score"),
          isRunning: doc.get('isRunning'),
        winnerTeam: doc.get('isWinner'),

      );
      _listOfScore.add(liveScore);
    }
    setState(() {

    });
  }

  @override
  void initState() {
   _getLiveScoreData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('sd')),
      body: ListView.builder(


          itemCount: _listOfScore.length,
          itemBuilder: (context,index){
            LiveScore liveScore=_listOfScore[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: liveScore.isRunning?Colors.green:Colors.red,
          ),
        title: Text(liveScore.id),
        subtitle:Column(
          children: [
            Row(
              spacing: 14,
              children: [
                Text(liveScore.team1Name),

                Text(liveScore.team2Name),
              ],
            ),
            Text('IS Running:${liveScore.isRunning}'),
            Text('IS Running:${liveScore.winnerTeam}'),
          ],
        ),
trailing:  Text('${liveScore.team1Score}:${liveScore.team2Score}'),

        );

      }),
    );
  }
}
class LiveScore {
  final String id;
  final String team1Name;
  final String team2Name;
  final String team1Score;
  final String team2Score;
  final bool isRunning;
  final bool winnerTeam;

  LiveScore({required this.id,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.isRunning,
    required this.winnerTeam,



  });


}

