import 'package:flutter/material.dart';
import 'package:lab33_rachad/pallete.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';


import 'dalle_page.dart';
import 'ferret_page.dart';
import 'gpt_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gemini Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GeminiPage(),
    );
  }
}

class GeminiPage extends StatefulWidget {
  @override
  _GeminiPageState createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  TextEditingController textController = TextEditingController();
  String result = "";
  static const String apiUrl = "http://127.0.0.1:8000/generate_content";

  Future<void> generateContent() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": textController.text}),
      );

      if (response.statusCode == 200) {
        setState(() {
          result = response.body;
        });
      } else {
        setState(() {
          result = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Widget _buildDrawerHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/i.jpg'),
        ),
        const SizedBox(height: 10),
        Text(
          'rachad@gmail.com',
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
    required String iconImage,
    required VoidCallback onTap,
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
      onTap: onTap,
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        hintText: 'Type your message...',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenerateContentButton() {
    return ElevatedButton(
      onPressed: generateContent,
      child: Text("Generate Content"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('Gemini Chatbot'),
        ),
        centerTitle: true,
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
                iconImage: 'assets/images/gpt.png',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GptPage()),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'DallE',
                iconImage: 'assets/images/dalle_icon.png',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DallePage()),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'Gemini',
                iconImage: 'assets/images/gemini_icon.png',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GeminiPage()),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.chat_bubble_outline,
                title: 'Ferret',
                iconImage: 'assets/images/ferret_icon.png',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FerretPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ZoomIn(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      height: 123,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/i.jpg',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FadeInRight(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      result.isEmpty
                          ? 'Type a message to generate content.'
                          : 'Generated Content: $result',
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTextField(),
              ),
              SizedBox(height: 16),
              ZoomIn(
                child: FloatingActionButton(
                  backgroundColor: Pallete.firstSuggestionBoxColor,
                  onPressed: generateContent,
                  child: Icon(Icons.refresh),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
