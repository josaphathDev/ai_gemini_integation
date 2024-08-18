import 'package:ai_gemini_integation/messages_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final GenerativeModel _models;
  late final ChatSession _chatSession;
  final FocusNode _textFiledFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _models = GenerativeModel(
      model: 'gemini-pro',
      apiKey: const String.fromEnvironment('api_key'),
    );
    _chatSession = _models.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biuild gemini'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _chatSession.history.length,
                    itemBuilder: ((context, index) {
                      final Content content =
                          _chatSession.history.toList()[index];
                      final text = content.parts
                          .whereType<TextPart>()
                          .map((e) => e.text)
                          .join('');
                      return Messages(
                        text: text,
                        isFromUser: content.role == 'user',
                      );
                    }))),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFiledFocus,
                      decoration: textFiledDecoration(),
                      controller: _textController,
                      onSubmitted: _sendChatMessage,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration textFiledDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      final reponse = await _chatSession.sendMessage(
        Content.text(message),
      );
      final text = reponse.text;
      if (text == null) {
        _showError('No reponse from API');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFiledFocus.requestFocus();
    }
  }

/* 
  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
    {_} =>  _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(
       
        milliseconds:750,
      ),
      ),);
  } */
  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showError(String messages) {
    showDialog<void>(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text('something went wrong'),
            content: SingleChildScrollView(
              child: SelectableText(messages),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('ok'),
              ),
            ],
          );
        }));
  }
}
