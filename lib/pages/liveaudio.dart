import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class SpeechToSign extends StatefulWidget {
  const SpeechToSign({super.key});

  @override
  State<SpeechToSign> createState() => _SpeechToSignState();
}

class _SpeechToSignState extends State<SpeechToSign> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  List<String> _displayedText = [];
  int _currentLetterIndex = 0;
  bool _isPlaying = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      _stopDisplayTimer();
    } else {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              _displayedText = _filterAndConvertText(_text);
              _currentLetterIndex = 0;
              _isPlaying = true;
              _startDisplayTimer();
            });
          },
        );
      }
    }
    setState(() {
      _isListening = !_isListening;
    });
  }

  List<String> _filterAndConvertText(String text) {
    return text
        .toUpperCase()
        .split('')
        .where((char) => RegExp(r'[A-Z]').hasMatch(char))
        .toList();
  }

  void _startDisplayTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentLetterIndex < _displayedText.length && _isPlaying) {
        setState(() {
          _currentLetterIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startDisplayTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetDisplay() {
    setState(() {
      _currentLetterIndex = 0;
      _isPlaying = false;
      _timer?.cancel();
    });
  }

  void _stopDisplayTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    super.dispose();
  }

  Widget _getSignImage(String character) {
    if (character.isEmpty) {
      return Container(); // Display an empty container for non-alphabet characters
    }
    return Image.asset(
      'assets/hand_signs/${character}.jpg', // Assuming your sign images are named A.jpg, B.jpg, etc.
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Speech to Sign',
          style: TextStyle(
            color: Color(0xFF3B4F7D),
            fontWeight: FontWeight.bold,
            fontFamily: 'IBMPlexMono',
          ),
        ),
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFDCE4F8),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(1.0),
                  offset: Offset(-2, -2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(2, 2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.menu, color: Color(0xFF3B4F7D), size: 24),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF9CB2E4).withOpacity(0.6),
                  Color(0xFF9CB2E4).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150, // Fixed height for the text display area
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(-3, -3),
                      ),
                      BoxShadow(
                        color: Color(0xFFBBC3CE).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Text(
                      _text,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontFamily: 'IBMPlexMono',
                        color: Color(0xFF3B4F7D),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _toggleListening,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF9574CD),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    elevation: 0,
                  ),
                  child: Text(
                    _isListening ? 'Stop Listening' : 'Start Listening',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexMono',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 150, // Fixed height for the sign image display area
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(-3, -3),
                      ),
                      BoxShadow(
                        color: Color(0xFFBBC3CE).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _currentLetterIndex < _displayedText.length
                      ? _getSignImage(_displayedText[_currentLetterIndex])
                      : Container(), // Show nothing when the text is done
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _togglePlayPause,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF9574CD),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        elevation: 0,
                      ),
                      child: Text(
                        _isPlaying ? 'Pause' : 'Play',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexMono',
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _resetDisplay,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF9574CD),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        elevation: 0,
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexMono',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
