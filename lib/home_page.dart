import 'package:animate_do/animate_do.dart';
import 'package:chatgpt/feature_box.dart';
import 'package:chatgpt/openAI_services.dart';
import 'package:chatgpt/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fluttertts = FlutterTts();
  final speechToText = SpeechToText();
  final OpenAIService openAPIServices = OpenAIService();
  String? generatedContent;
  String? generatedImgUrl;
  bool on = false;
  String lastwords = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> initTextToSpeech() async {
    await speechToText.initialize();
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
      lastwords = result.recognizedWords;
    });
  }

  void dispose() {
    super.dispose();
    speechToText.stop();
    fluttertts.stop();
  }

  Future<void> systemSpeak(String content) async {
    await fluttertts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: Text('AI Assistant')),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                ZoomIn(
                  child: Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/virtual-assistants.png"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FadeInRight(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
                decoration: BoxDecoration(
                    border: Border.all(color: Pallete.borderColor),
                    borderRadius:
                        BorderRadius.circular(20).copyWith(topLeft: Radius.zero)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    generatedContent == null
                        ? 'Good Morning Give Me a Tasks'
                        : generatedContent!,
                    style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                        fontFamily: 'Cera Pro'),
                  ),
                ),
              ),
            ),
            if(generatedImgUrl!=null)
            Image.network(generatedImgUrl!),
            Visibility(
              visible: generatedContent==null&&generatedImgUrl==null,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(top: 10, left: 22),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Commands given',
                      style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: Pallete.mainFontColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SlideInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: const  FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      HeaderText: 'ChatGpt',
                      Description: 'Ask Anything',
                    ),
                  ),
                  SlideInRight(
                    delay: const Duration(milliseconds: 400),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      HeaderText: 'Dall_E',
                      Description: 'Ask Anything',
                    ),
                  ),
                  SlideInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      HeaderText: 'Smart Voice Asssistant',
                      Description: 'Ask Anything',
                    ),
                  )
                ],
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        child: FloatingActionButton(
          onPressed: () async {
            if (await speechToText.hasPermission && speechToText.isNotListening) {
              await startListening();
              setState(() {
                on = true;
              });
            } else if (speechToText.isListening) {
              print(lastwords);
              setState(() {
                on = false;
              });
              setState(() {

              });
              final speech = await openAPIServices.isArtPromptAPI(lastwords);

              if (speech.contains('https')) {
                generatedImgUrl = speech;
                generatedContent = null;
              } else {
                generatedImgUrl = null;
                generatedContent = speech;
                setState(() {});
                systemSpeak(speech);
                setState(() {});

                await stopListening();
              }
            } else {
              initSpeechToText();
            }
          },
          child: Icon( speechToText.isListening?Icons.stop:
            Icons.mic,
          ),
        ),
      ),
    );
  }
}
