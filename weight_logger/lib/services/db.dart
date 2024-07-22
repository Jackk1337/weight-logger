import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference weightsRef =
      FirebaseFirestore.instance.collection("weight_logs");

  Future<void> createWeightLog(double currentWeight) async {
    try {
      await weightsRef
          .doc("8xR7b5MZA2jtxrt3N8c0")
          .collection("dailyWeight")
          .add({
        'weight': currentWeight,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error loggin weight: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getWeightLogs() async {
    try {
      QuerySnapshot querySnapshot = await weightsRef
          .doc("8xR7b5MZA2jtxrt3N8c0")
          .collection("dailyWeight")
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        return {
          'weight': doc['weight'],
          'timestamp': doc['timestamp'],
        };
      }).toList();
    } catch (e) {
      print("Error getting weight logs from DB: $e");
      return [];
    }
  }
}
