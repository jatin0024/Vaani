import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vani/login_page.dart'; // For scheduling the navigation

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the next screen after 1.5 seconds
    Future.delayed(Duration(seconds: 1, milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your next screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/google-logo.png', // Replace with your image path
          width: 150, // Adjust the size as needed
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// Example of the next screen
class NextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Next Screen')),
      body: Center(
        child: Text('Welcome to the Next Screen!'),
      ),
    );
  }
}
