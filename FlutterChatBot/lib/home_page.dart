import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab33_rachad/dalle_page.dart';
import 'package:lab33_rachad/ferret_page.dart';
import 'package:lab33_rachad/gemini_page.dart';
import 'package:lab33_rachad/gpt_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _inputController = TextEditingController();
  late String _response = '';
  late final String userEmail = 'Rachad@gmail.com';
  final String apiUrl = 'http://localhost:8000/chatbot/'; // Replace with your API endpoint

  Future<void> _sendMessage(String message) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_input': message}),
    );

    print('API Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody != null &&
          responseBody['chatbot_response'] != null &&
          responseBody['chat_history'] != null) {
        setState(() {
          _response = responseBody['chatbot_response'];
        });
      } else {
        setState(() {
          _response = 'Error: Invalid response format';
        });
        print('Invalid response format: $responseBody');
      }
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
      });
      print('Error: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending message: $error');
    setState(() {
      _response = 'Error: $error';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Emsi chatBot',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 2.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _sendMessage(_inputController.text);
              },
              child: Text('Send'),
            ),
            SizedBox(height: 16),
            Text('Chatbot Response: $_response'),
            SizedBox(height: 16),
            Center(
              child: const Text(
                'Welcome to Emsi chatBot',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: _buildDrawerHeader(),
              ),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'Chat GPT',
                page: GptPage(),
                iconImage: 'assets/images/gpt.png',
              ),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'DallE',
                page: DallePage(),
                iconImage: 'assets/images/dalle_icon.png',
              ),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'Gemini',
                page: GeminiPage(),
                iconImage: 'assets/images/gemini_icon.png',
              ),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'Ferret',
                page: FerretPage(),
                iconImage: 'assets/images/ferret_icon.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: const AssetImage(
            'assets/images/i.jpg',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          userEmail,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Widget page,
    required String iconImage,
  }) {
    return ListTile(
      leading: Image.asset(
        iconImage,
        width: 24,
        height: 24,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
