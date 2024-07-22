import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weight_logger/services/db.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WeightLogger());
}

class WeightLogger extends StatefulWidget {
  const WeightLogger({super.key});

  @override
  State<WeightLogger> createState() => _WeightLoggerState();
}

class _WeightLoggerState extends State<WeightLogger> {
  double _currentDoubleValue = 3.0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Weight Logger"),
          ),
          body: Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                DecimalNumberPicker(
                  minValue: 0,
                  maxValue: 600,
                  decimalPlaces: 1,
                  value: _currentDoubleValue,
                  onChanged: (value) => setState(() {
                    _currentDoubleValue = value;
                  }),
                  haptics: true,
                ),
                const SizedBox(height: 20),
                Text("Current Weight: $_currentDoubleValue kg",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await DatabaseService()
                          .createWeightLog(_currentDoubleValue);
                      setState(() {});
                    } catch (e) {
                      print("Error loggin weight $e");
                    }
                  },
                  child: const Text(
                    "Submit Weight",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Previous Weights",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseService().getWeightLogs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text("Unable to display data");
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No weight data to display");
                    }

                    var weightLogs = snapshot.data!;
                    return DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                              label: Expanded(child: const Text("Date"))),
                          DataColumn(
                            label: Expanded(child: const Text("Weight (Kg)")),
                          )
                        ],
                        rows: weightLogs.map((log) {
                          return DataRow(cells: <DataCell>[
                            DataCell(
                              Text(
                                (log['timestamp'] as Timestamp)
                                    .toDate()
                                    .toString(),
                              ),
                            ),
                            DataCell(Text("${log['weight']} kg")),
                          ]);
                        }).toList());
                  },
                ))
              ],
            ),
          )),
    );
  }
}
