import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class CodeLlamaChatPage extends StatefulWidget {
  @override
  _CodeLlamaChatPageState createState() => _CodeLlamaChatPageState();
}

class _CodeLlamaChatPageState extends State<CodeLlamaChatPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = 'AI message will be written here';
  List<String> _displayedText = [];
  int _currentLetterIndex = 0;
  bool _isPlaying = true;
  Timer? _timer;

  Future<void> sendTextToCodeLlama(String inputText) async {
    final url = Uri.parse('https://api.aimlapi.com/chat/completions');
    final apiKey = '6e70309ac6444f93b0ba1c7a09f82945'; // Replace with your actual API key

    final body = jsonEncode({
      "model": "codellama/CodeLlama-34b-Instruct-hf",
      "messages": [
        {
          "role": "user",
          "content": inputText
        }
      ],
      "max_tokens": 50,
      "stream": false
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final outputText = responseData['choices'][0]['message']['content'];

        setState(() {
          _response = outputText;
          _displayedText = _filterAndConvertText(outputText);
          _currentLetterIndex = 0;
          _isPlaying = true;
          _startDisplayTimer();
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Request failed: $e';
      });
    }
  }

  List<String> _filterAndConvertText(String text) {
    return text
        .toUpperCase()
        .split('')
        .where((char) => RegExp(r'[A-Z]').hasMatch(char))
        .toList();
  }

  void _startDisplayTimer() {
    _timer?.cancel(); // Cancel any existing timer
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'AI Chat with CodeLlama',
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 200,
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
                  child: SingleChildScrollView(
                    child: Text(
                      _response,
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
                Container(
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
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'IBMPlexMono',
                      color: Color(0xFF3B4F7D),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      hintStyle: TextStyle(color: Color(0xFFBBC3CE)),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    sendTextToCodeLlama(_controller.text);
                  },
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
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexMono',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 160,
                  alignment: Alignment.center,
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
                  child: _currentLetterIndex < _displayedText.length
                      ? Image.asset(
                          'assets/hand_signs/${_displayedText[_currentLetterIndex]}.jpg',
                          fit: BoxFit.contain,
                        )
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
                        'Stop',
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
