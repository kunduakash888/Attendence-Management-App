import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'Attendence.dart';

class AddStudentScreen extends StatefulWidget {
  final String selectedClass;

  AddStudentScreen({required this.selectedClass});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _subjectId;

  @override
  void initState() {
    super.initState();
    _fetchSubjectId();
  }

  void _fetchSubjectId() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("classes")
          .where("name", isEqualTo: widget.selectedClass)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _subjectId = querySnapshot.docs.first.id;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _addStudent() async {
    String name = _nameController.text.trim();
    String rollNumber = _rollNumberController.text.trim();

    if (name.isNotEmpty && rollNumber.isNotEmpty && _subjectId != null) {
      try {
        await _firestore
            .collection("classes")
            .doc(_subjectId)
            .collection("students")
            .add({
          "name": name,
          "rollNumber": rollNumber,
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student "$name" added successfully!')),
        );

        _nameController.clear();
        _rollNumberController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both name and roll number')),
      );
    }
  }

  void _navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectStudentScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          child: Text("Add Student - ${widget.selectedClass}"),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://static.vecteezy.com/system/resources/previews/002/272/094/non_2x/happy-women-student-gratuated-from-education-background-concept-free-vector.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(24.0),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(25.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 3,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Icon with Shadow
                    FadeIn(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.2),
                          radius: 60,
                          child: Image.network(
                            'https://cdn-icons-png.freepik.com/512/2886/2886011.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Student Name Input Field
                    FadeInLeft(
                      child: _buildInputField(
                        _nameController,
                        "Student Name",
                        Icons.person,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Roll Number Input Field
                    FadeInRight(
                      child: _buildInputField(
                        _rollNumberController,
                        "Roll Number",
                        Icons.numbers,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Add Student Button
                    FadeInUp(
                      child: ElevatedButton(
                        onPressed: _addStudent,
                        style: _buttonStyle(Colors.blueAccent),
                        child: Text("Add Student",style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    SizedBox(height: 16),


                    FadeInUp(
                      delay: Duration(milliseconds: 200),
                      child: OutlinedButton(
                        onPressed: _subjectId != null ? _navigateToAttendance : null,
                        style: _outlinedButtonStyle(Colors.green),
                        child: Text("Manage Attendance"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }


  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      padding: EdgeInsets.symmetric(horizontal: 56, vertical: 18),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      elevation: 5,
    );
  }


  ButtonStyle _outlinedButtonStyle(Color color) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      elevation: 3,
    );
  }
}
