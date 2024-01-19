import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lab33_rachad/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dalle_page.dart';
import 'ferret_page.dart';
import 'gemini_page.dart';
import 'feature_box.dart';
import 'openai_service.dart';

class GptPage extends StatefulWidget {
  const GptPage({Key? key}) : super(key: key);

  @override
  State<GptPage> createState() => _GptPageState();
}

class _GptPageState extends State<GptPage> {
  final TextEditingController _textInputController = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  String selectedModel = 'gpt-3.5-turbo';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> sendMessageToChatGPT(String message) async {
    if (message.isNotEmpty) {
      String response = await openAIService.isArtPromptAPI(message, selectedModel);

      if (response.contains('https')) {
        generatedImageUrl = response;
        generatedContent = null;
      } else {
        generatedImageUrl = null;
        generatedContent = response;
        await systemSpeak(response);
      }

      setState(() {});
    }
  }

  Future<void> initTextToSpeech() async {
    try {
      await initSpeechToText();
      await flutterTts.setSharedInstance(true);
      print('TextToSpeech initialized successfully');
    } catch (e) {
      print('TextToSpeech initialization failed: $e');
    }
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    bool initialized = await speechToText.initialize();
    if (initialized) {
      print('SpeechToText initialized successfully');
    } else {
      print('SpeechToText initialization failed');
    }
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
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
      if (!identical(page.runtimeType, ModalRoute.of(context)!.settings.name.runtimeType)) {
        // Check if the new page is different from the current one
        Navigator.pop(context); // Pop drawer
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      }
    },
  );
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

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('Gpt Chatbot'),
        ),
        leading: const Icon(Icons.menu),
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
      body: SingleChildScrollView(
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
              child: Visibility(
                visible: generatedImageUrl == null,
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
                      generatedContent == null
                          ? 'Good Morning, what task can I do for you?'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textInputController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission && speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords, selectedModel);
              print('Selected Model: $selectedModel');
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
            } else {
              await sendMessageToChatGPT(_textInputController.text);
              _textInputController.clear();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}
