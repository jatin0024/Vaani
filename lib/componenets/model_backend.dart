import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class AudioPicker {
  final String _assemblyAiApiKey = 'cc1aa7df8c914b2b9b7ea89e47c4aae4'; 

  Future<String> pickAndTranscribeFile() async {
    // Pick the audio file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Upload file and get transcription
      String transcription = await _transcribeAudio(file);
      return transcription;
    }
    return "Error: No audio file selected.";
  }

  Future<String> _transcribeAudio(File file) async {
    // Upload the audio file to AssemblyAI
    final uploadUrlResponse = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/upload'),
      headers: {
        'authorization': _assemblyAiApiKey,
        'content-type': 'application/octet-stream',
      },
      body: file.readAsBytesSync(),
    );

    if (uploadUrlResponse.statusCode == 200) {
      final uploadUrl = json.decode(uploadUrlResponse.body)['upload_url'];

      // Request transcription
      final transcriptionResponse = await http.post(
        Uri.parse('https://api.assemblyai.com/v2/transcript'),
        headers: {
          'authorization': _assemblyAiApiKey,
          'content-type': 'application/json',
        },
        body: json.encode({'audio_url': uploadUrl}),
      );

      if (transcriptionResponse.statusCode == 200) {
        final transcriptId = json.decode(transcriptionResponse.body)['id'];

        // Poll for transcription result
        String transcriptText = await _pollTranscription(transcriptId);
        return transcriptText;
      } else {
        return "Error: ${transcriptionResponse.statusCode}";
      }
    } else {
      return "Error: ${uploadUrlResponse.statusCode}";
    }
  }

  Future<String> _pollTranscription(String transcriptId) async {
    String transcriptText = "Transcription in progress...";
    while (true) {
      await Future.delayed(Duration(seconds: 5));
      final response = await http.get(
        Uri.parse('https://api.assemblyai.com/v2/transcript/$transcriptId'),
        headers: {
          'authorization': _assemblyAiApiKey,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'completed') {
          transcriptText = result['text'];
          break;
        } else if (result['status'] == 'failed') {
          transcriptText = "Transcription failed";
          break;
        }
      }
    }
    return transcriptText;
  }
}
