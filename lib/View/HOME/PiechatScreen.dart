import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';

class AttendancePieChartScreen extends StatefulWidget {
  @override
  _AttendancePieChartScreenState createState() =>
      _AttendancePieChartScreenState();
}

class _AttendancePieChartScreenState extends State<AttendancePieChartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedClassId;
  String _selectedType = "Day-wise";
  DateTime _selectedDate = DateTime.now();
  int presentCount = 0;
  int absentCount = 0;
  bool _isLoading = false;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_selectedType == "Day-wise") {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2010),
        lastDate: DateTime(2030),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
          _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
        });
        _fetchAttendance();
      }
    } else {
      // Custom Month Picker using Year Selection
      DateTime? pickedMonth = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2010),
        lastDate: DateTime(2030),
        initialDatePickerMode: DatePickerMode.year, // Opens year selection first
      );

      if (pickedMonth != null) {
        setState(() {
          _selectedDate = DateTime(pickedMonth.year, pickedMonth.month, 1);
          _dateController.text = DateFormat('yyyy-MM').format(_selectedDate);
        });
        _fetchAttendance();
      }
    }
  }

  Future<void> _fetchAttendance() async {
    if (_selectedClassId == null) return;

    setState(() {
      _isLoading = true;
      presentCount = 0;
      absentCount = 0;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String formattedMonth = DateFormat('yyyy-MM').format(_selectedDate);

    try {
      if (_selectedType == "Day-wise") {
        QuerySnapshot snapshot = await _firestore
            .collection("classes")
            .doc(_selectedClassId)
            .collection("attendance")
            .doc(formattedDate)
            .collection("studentAttendance")
            .get();

        int dayPresent = snapshot.docs
            .where((doc) => (doc.data() as Map<String, dynamic>)["isPresent"] == true)
            .length;
        int dayAbsent = snapshot.docs.length - dayPresent;

        setState(() {
          presentCount = dayPresent;
          absentCount = dayAbsent;
        });
      } else {
        QuerySnapshot monthSnapshot = await _firestore
            .collection("classes")
            .doc(_selectedClassId)
            .collection("attendance")
            .get();

        int monthPresent = 0;
        int monthAbsent = 0;

        for (var doc in monthSnapshot.docs) {
          if (doc.id.startsWith(formattedMonth)) {
            QuerySnapshot studentAttendance = await _firestore
                .collection("classes")
                .doc(_selectedClassId)
                .collection("attendance")
                .doc(doc.id)
                .collection("studentAttendance")
                .get();

            int dailyPresent = studentAttendance.docs
                .where((doc) => (doc.data() as Map<String, dynamic>)["isPresent"] == true)
                .length;
            int dailyAbsent = studentAttendance.docs.length - dailyPresent;

            monthPresent += dailyPresent;
            monthAbsent += dailyAbsent;
          }
        }

        setState(() {
          presentCount = monthPresent;
          absentCount = monthAbsent;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching attendance: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPieChart() {
    if (presentCount + absentCount == 0) {
      return Center(child: Text("No Data Available"));
    }
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: presentCount.toDouble(),
            title: "Present",
            color: Colors.green,
            radius: 100,
          ),
          PieChartSectionData(
            value: absentCount.toDouble(),
            title: "Absent",
            color: Colors.red,
            radius: 100,
          ),
        ],
        sectionsSpace: 4,
        centerSpaceRadius: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(child: Text("Attendance Pie Chart")),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://static.vecteezy.com/system/resources/thumbnails/056/726/812/small_2x/vibrant-glowing-pie-chart-in-dimly-lit-room-for-business-and-design-concepts-photo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.70),
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                FutureBuilder<QuerySnapshot>(
                  future: _firestore.collection("classes").get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    var classes = snapshot.data!.docs;

                    return DropdownButton<String>(
                      hint: Text("Select Class"),
                      value: _selectedClassId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedClassId = newValue;
                          _fetchAttendance();
                        });
                      },
                      items: classes.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(doc["name"]),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: SizedBox(),
                    );
                  },
                ),
                SizedBox(height: 20),
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                      _dateController.text = _selectedType == "Day-wise"
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate)
                          : DateFormat('yyyy-MM').format(_selectedDate);
                    });
                  },
                  items: ["Day-wise", "Month-wise"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Select Date/Month',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : Expanded(child: _buildPieChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}