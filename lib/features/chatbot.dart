import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final StreamController<List<Map<String, String>>> _streamController =
      StreamController.broadcast();
  final List<Map<String, String>> _messages = [];
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isListening = false;
  bool _isLoading = false;
  bool _isProcessingAudio = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    _checkAudioPermissions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamController.close();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  Future<void> _checkAudioPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print("Microphone permission granted");
    } else {
      print("Microphone permission denied");
    }
  }

  Future<void> _startRecording() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      _audioFilePath = '${tempDir.path}/audio_temp.wav';

      await _audioRecorder.openRecorder();
      await _audioRecorder.startRecorder(
        toFile: _audioFilePath,
        codec: Codec.pcm16WAV,
      );

      setState(() {
        _isListening = true;
      });
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      print('Error starting recorder: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      setState(() {
        _isListening = false;
        _isProcessingAudio = true;
      });

      if (_audioFilePath != null) {
        await _sendTranscription(File(_audioFilePath!));
      }
    } catch (e) {
      print('Error stopping recorder: $e');
    } finally {
      setState(() {
        _isProcessingAudio = false;
      });
    }
  }

  Future<void> _sendTranscription(File audioFile) async {
    final locale = Localizations.localeOf(context);
    final targetLanguage = locale.languageCode;

    final url = Uri.parse('https://multilingual-voice.onrender.com/transcribe');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['target_language'] = targetLanguage
        ..files.add(
          await http.MultipartFile.fromPath(
            'audio_file',
            audioFile.path,
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data['translation'];

        setState(() {
          _messages.add({'sender': 'user', 'text': translatedText});
          _streamController.add(_messages);
        });

        final botResponse = await _getBotResponse(translatedText);

        setState(() {
          _messages.add({'sender': 'bot', 'text': botResponse});
          _streamController.add(_messages);
        });
      } else {
        setState(() {
          _messages
              .add({'sender': 'bot', 'text': 'Error: Failed to transcribe.'});
          _streamController.add(_messages);
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'Error: Could not connect to the server.'
        });
        _streamController.add(_messages);
      });
    }
  }

  Future<String> _getBotResponse(String message) async {
    final url = Uri.parse('https://chatbot-api-cteq.onrender.com/chat');
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': message}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] ?? 'Sorry, I didn\'t understand that.';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      return 'Error: Could not connect to the server.';
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'user', 'text': text});
        _streamController.add(_messages);
        _controller.clear();
      });

      final botResponse = await _getBotResponse(text);
      setState(() {
        _messages.add({'sender': 'bot', 'text': botResponse});
        _streamController.add(_messages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chatwithagribot),
        centerTitle: true,
        backgroundColor: Colors.green[600],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, String>>>(
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.of(context)!.chatBot_screen,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.only(
                    top: height * 0.03,
                    bottom: 16.0,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUserMessage = message['sender'] == 'user';

                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.green[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isLoading || _isProcessingAudio)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Colors.green[400]!,
                          width: 2.0,
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 14.0),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.green[400],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecording(),
                  child: AvatarGlow(
                    glowColor: _isListening ? Colors.red : Colors.green[400]!,
                    animate: _isListening,
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : Colors.green[400],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                    ),
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
