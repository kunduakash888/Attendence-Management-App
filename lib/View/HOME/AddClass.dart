import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'AddStudent.dart';
import 'Attendence.dart';
import 'AttendenceHistoryScreen.dart';
import 'PiechatScreen.dart';

class AddClassScreen extends StatefulWidget {
  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _classes = [];
  String? _selectedClass;

  int absentCount =0;
  int presentCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('classes').get();
      setState(() {
        _classes = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print("Error fetching classes: $e");
    }
  }

  Future<void> _addClass() async {
    String className = _classNameController.text.trim();
    if (className.isNotEmpty) {
      try {
        await _firestore.collection('classes').add({'name': className});
        setState(() {
          _classes.add(className);
          _selectedClass = className;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class "$className" added successfully!')),
        );
        _classNameController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding class: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a class name')),
      );
    }
  }

  void _addStudent() {
    if (_selectedClass != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddStudentScreen(selectedClass: _selectedClass!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a class first')),
      );
    }
  }

  void _giveAttendance() {
    if (_selectedClass != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectStudentScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a class first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
            child: Text("Manage Classes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://www.shrmpro.com/wp-content/uploads/2019/05/Attendance-Management-background.png'), // Replace with a better background
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: FadeInUp(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      Image.network(
                        'https://i1.wp.com/iemgroup.s3.amazonaws.com/uploads/2017/12/IEM_New_Logo.jpg?fit=1458%2C1190&ssl=1', // Replace with your school logo
                        height: 100,
                      ),
                      SizedBox(height: 15),

                      // Title
                      Text(
                        "Add or Select Class",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple[600]),
                      ),
                      SizedBox(height: 15),

                      // Class Name Input
                      TextField(
                        controller: _classNameController,
                        decoration: InputDecoration(
                          labelText: "Class Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.book, color: Colors.deepPurple),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Add Class Button
                      ElevatedButton.icon(
                        onPressed: _addClass,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[400],
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text("Add Class", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 20),

                      // Class Selection Dropdown
                      if (_classes.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: DropdownButton<String>(
                            value: _selectedClass,
                            hint: Text("Select Class"),
                            isExpanded: true,
                            items: _classes.map((String className) {
                              return DropdownMenuItem<String>(
                                value: className,
                                child: Text(className),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedClass = newValue;
                              });
                            },
                          ),
                        ),
                      SizedBox(height: 20),

                      // Add Student Button
                      ElevatedButton.icon(
                        onPressed: _addStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[400],
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        icon: Icon(Icons.person_add, color: Colors.white),
                        label: Text("Add Student", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 10),

                      // Give Attendance Button
                      ElevatedButton.icon(
                        onPressed: _giveAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        label: Text("Give Attendance", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 15),

                      // Attendance History Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AttendanceReportScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        icon: Icon(Icons.history, color: Colors.white),
                        label: Text("Attendance History", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 15,),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AttendancePieChartScreen(),
                            )
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent[400],
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        icon: Icon(Icons.pie_chart, color: Colors.white),
                        label: Text("Show Piechat", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
