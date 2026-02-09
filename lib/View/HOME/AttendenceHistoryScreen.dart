import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';

class AttendanceReportScreen extends StatefulWidget {
  @override
  _AttendanceReportScreenState createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = false;
  final TextEditingController _dateController = TextEditingController();

  int presentCount = 0;
  int absentCount = 0;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
      _fetchAttendance();
    }
  }

  Future<void> _fetchAttendance() async {
    if (_selectedSubjectId == null) return;

    setState(() {
      _isLoading = true;
      _attendanceData = [];
      presentCount = 0;
      absentCount = 0;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      QuerySnapshot attendanceSnapshot = await _firestore
          .collection("classes")
          .doc(_selectedSubjectId)
          .collection("attendance")
          .doc(formattedDate)
          .collection("studentAttendance")
          .get();

      List<Map<String, dynamic>> fetchedData = [];

      for (var doc in attendanceSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var studentId = data["studentId"];

        DocumentSnapshot studentSnapshot = await _firestore
            .collection("classes")
            .doc(_selectedSubjectId)
            .collection("students")
            .doc(studentId)
            .get();

        if (studentSnapshot.exists) {
          var studentData = studentSnapshot.data() as Map<String, dynamic>;
          data["studentName"] = studentData["name"] ?? "Unknown";
          data["rollNumber"] = studentData["rollNumber"] ?? "N/A";
        } else {
          data["studentName"] = "Unknown";
          data["rollNumber"] = "N/A";
        }

        fetchedData.add(data);
      }

      int present = fetchedData.where((data) => data["isPresent"] == true).length;
      int absent = fetchedData.where((data) => data["isPresent"] == false).length;

      setState(() {
        _attendanceData = fetchedData;
        presentCount = present;
        absentCount = absent;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching attendance: $e");
      setState(() {
        _attendanceData = [];
        presentCount = 0;
        absentCount = 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(child: Text("Attendance Report")),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://expologic.com/wp-content/uploads/2024/05/EL-BLG2404-How-Group-Registration-Benefits-Event-Organizers-and-Participants.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    child: FutureBuilder<QuerySnapshot>(
                      future: _firestore.collection("classes").get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("No subjects available");
                        }

                        var subjects = snapshot.data!.docs;

                        return DropdownButton<String>(
                          hint: Text("Select Subject"),
                          value: _selectedSubjectId,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSubjectId = newValue;
                              _selectedSubjectName = subjects
                                  .firstWhere((doc) => doc.id == newValue)["name"];
                            });
                            _fetchAttendance();
                          },
                          items: subjects.map<DropdownMenuItem<String>>((doc) {
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
                  ),
                  SizedBox(height: 20),
                  FadeInRight(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Display Present and Absent Count
                  FadeInDown(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Chip(
                          label: Text("Present: $presentCount",
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.green,
                        ),
                        Chip(
                          label: Text("Absent: $absentCount",
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (_selectedSubjectId != null)
                    _attendanceData.length==0?Text("No Students are available in the class",style: TextStyle(color: Colors.black),):
                    Expanded(
                      child: FadeInUp(
                        child: ListView.separated(
                          itemCount: _attendanceData.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            var studentAttendance = _attendanceData[index];
                            return ListTile(
                              title: Text(studentAttendance["studentName"]),
                              subtitle:
                              Text("Roll No: ${studentAttendance["rollNumber"]}"),
                              leading: Icon(
                                studentAttendance["isPresent"]
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: studentAttendance["isPresent"]
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              trailing: Text(studentAttendance["isPresent"]
                                  ? "Present"
                                  : "Absent"),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
