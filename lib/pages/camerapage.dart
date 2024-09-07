import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _result = 'No result';
  String _formedWord = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller == null) return;

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.17:8000/predict'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        setState(() {
          _result = responseData.body;
        });
      } else {
        print('Failed to get prediction');
        setState(() {
          _result = 'Failed to get prediction';
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
      setState(() {
        _result = 'Error capturing image';
      });
    }
  }

  void _addToWord() {
    setState(() {
      _formedWord += _result.isNotEmpty ? _result[0] : '';
    });
  }

  void _addSpace() {
    setState(() {
      _formedWord += " ";
    });
  }

  void _clearWord() {
    setState(() {
      _formedWord = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sign Language Detection',
          style: TextStyle(
            color: Color(0xFF3B4F7D),
            fontWeight: FontWeight.bold,
            fontFamily: 'IBMPlexMono',
          ),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview
          Center(
            child: _controller == null
                ? CircularProgressIndicator()
                : FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
          ),
          // Result overlay
          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Prediction Result',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexMono',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _result,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'IBMPlexMono',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Formed Word: $_formedWord',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexMono',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Capture button
          Positioned(
            bottom: 50,
            left: 0,
            right: 60,
            child: Center(
              child: ElevatedButton(
                onPressed: _captureImage,
                child: Icon(Icons.camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent.shade100,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          // Add to word button
          Positioned(
            bottom: 50,
            left: 0,
            right: 180,
            child: Center(
              child: ElevatedButton(
                onPressed: _addToWord,
                child: Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent.shade100,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          // Clear word button
          Positioned(
            bottom: 50,
            left: 120,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _clearWord,
                child: Icon(Icons.clear),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent.shade100,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          // Add space button
          Positioned(
            bottom: 50,
            left: 240,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _addSpace,
                child: Icon(Icons.space_bar),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent.shade100,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
