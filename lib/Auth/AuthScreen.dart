import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../View/HOME/AddClass.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLogin = true;

  Future<void> _authenticate() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential;
        String email = emailController.text.trim();
        String password = passwordController.text.trim();

        if (isLogin) {
          userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (userCredential.user != null) {
            if (userCredential.user!.emailVerified) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login Successful! Welcome ${userCredential.user!.email}')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddClassScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please verify your email before logging in!')),
              );
            }
          }
        } else {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          await userCredential.user?.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful! Please verify your email.')),
          );
          print("User Created: ${userCredential.user?.email}");
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Authentication failed";
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'email-already-in-use':
            errorMessage = 'Email is already registered.';
            break;
          case 'weak-password':
            errorMessage = 'Password should be at least 6 characters.';
            break;
          default:
            errorMessage = e.message ?? "Authentication failed";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.pexels.com/photos/1590549/pexels-photo-1590549.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeIn(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeInLeft(
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(Icons.email), // Added email icon
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        FadeInRight(
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              prefixIcon: Icon(Icons.lock), // Added lock icon
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),
                        FadeInUp(
                          child: ElevatedButton(
                            onPressed: _authenticate,
                            child: Row( // Added Row for icon and text
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isLogin ? Icons.login : Icons.person_add,color: Colors.white,), // Added login/register icon
                                SizedBox(width: 8),
                                Text(isLogin ? 'Login' : 'Register',style: TextStyle(color: Colors.white),),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.grey,
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        FadeInDown(
                          child: TextButton(
                            onPressed: () => setState(() => isLogin = !isLogin),
                            child: Row( // Added Row for icon and text
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isLogin ? Icons.person_add_alt_1 : Icons.login), // Added register/login icon
                                SizedBox(width: 8),
                                Text(isLogin ? 'Don\'t have an account? Register' : 'Already registered? Login'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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