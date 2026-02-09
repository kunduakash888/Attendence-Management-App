import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SubjectStudentScreen extends StatefulWidget {
  @override
  _SubjectStudentScreenState createState() => _SubjectStudentScreenState();
}

class _SubjectStudentScreenState extends State<SubjectStudentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  List<QueryDocumentSnapshot>? _students;
  Map<String, bool> _attendance = {};

  int get presentCount => _attendance.values.where((e) => e == true).length;
  int get absentCount => _students != null ? _students!.length - presentCount : 0;

  void _submitAttendance() async {
    if (_selectedSubjectId == null || _students == null || _students!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No students available for attendance")),
      );
      return;
    }

    DateTime now = DateTime.now();
    String formattedDateOnly = DateFormat('yyyy-MM-dd').format(now);
    String formattedMonth = DateFormat('yyyy-MM').format(now); // Store month

    WriteBatch batch = _firestore.batch();

    for (var student in _students!) {
      String studentId = student.id;
      bool isPresent = _attendance[studentId] ?? false;

      DocumentReference docRef = _firestore
          .collection("classes")
          .doc(_selectedSubjectId)
          .collection("attendance")
          .doc(formattedDateOnly)
          .collection("studentAttendance")
          .doc(studentId);

      batch.set(docRef, {
        "studentId": studentId,
        "isPresent": isPresent,
        "timestamp": now,
        "month": formattedMonth, // Store month
      });
    }

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Attendance Submitted!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(child: Text("Take Attendance")),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://thumbs.dreamstime.com/z/business-illustration-showing-concept-attendance-manageme-management-110229234.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Dropdown
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

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.white.withOpacity(0.9),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButton<String>(
                          hint: Text("Select Subject"),
                          value: _selectedSubjectId,
                          onChanged: (String? newValue) async {
                            setState(() {
                              _selectedSubjectId = newValue;
                              _selectedSubjectName = subjects.firstWhere((doc) => doc.id == newValue)["name"];
                            });

                            if (newValue != null) {
                              QuerySnapshot studentSnapshot = await _firestore
                                  .collection("classes")
                                  .doc(newValue)
                                  .collection("students")
                                  .get();

                              setState(() {
                                _students = studentSnapshot.docs;
                                _attendance.clear();
                              });
                            }
                          },
                          items: subjects.map<DropdownMenuItem<String>>((doc) {
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(doc["name"]),
                            );
                          }).toList(),
                          underline: SizedBox(),
                          isExpanded: true,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),

                // Student List
                _students == null
                    ? FadeInUp(child: Text("Select a subject to view students"))
                    : Expanded(
                  child: FadeInUp(
                    child: ListView.builder(
                      itemCount: _students!.length,
                      itemBuilder: (context, index) {
                        var student = _students![index];
                        String studentId = student.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Slidable(
                            key: ValueKey(studentId),
                            startActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    setState(() {
                                      _attendance[studentId] = true;
                                    });
                                  },
                                  backgroundColor: Colors.green,
                                  icon: Icons.check,
                                  label: 'Present',
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    setState(() {
                                      _attendance[studentId] = false;
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  icon: Icons.close,
                                  label: 'Absent',
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(student["name"]),
                                subtitle: Text("Roll No: ${student["rollNumber"]}"),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Submit Attendance Button
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedSubjectId == null || _students == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a subject first")),
                        );
                        return;
                      }

                      DateTime now = DateTime.now();
                      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Today's Attendance"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Subject: $_selectedSubjectName"),
                              Text("Present: $presentCount"),
                              Text("Absent: $absentCount"),
                              Text("Time: $formattedDate"),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel", style: TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _submitAttendance();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text("Submit"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text("Submit Attendance", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}