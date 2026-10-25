import 'package:flutter/material.dart';
import '../../core/services/clinical_ai_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'text': 'Welcome to the Clinical AI Assistant. I can operate offline using clinical rule-based intelligence or online via Gemini API.'
    }
  ];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
      _promptController.clear();
    });

    try {
      const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_API_KEY_HERE');
      if (apiKey != 'YOUR_API_KEY_HERE') {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(
              'You are an expert neuro-ophthalmologist and orthoptist. Answer questions related to strabismus, amblyopia, cranial nerve palsies, and binocular vision accurately and concisely.'),
        );

        final response = await model.generateContent([Content.text(text)]);
        setState(() {
          _messages.add({'role': 'ai', 'text': response.text ?? 'No response generated.'});
        });
      } else {
        // Fallback to high-speed offline clinical intelligence
        await Future.delayed(const Duration(milliseconds: 300));
        final offlineResp = OfflineClinicalAiService.queryOfflineKb(text);
        setState(() {
          _messages.add({'role': 'ai', 'text': offlineResp});
        });
      }
    } catch (e) {
      final offlineResp = OfflineClinicalAiService.queryOfflineKb(text);
      setState(() {
        _messages.add({'role': 'ai', 'text': offlineResp});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, color: Colors.cyan),
            SizedBox(width: 8),
            Text('Clinical AI Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUser
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about CN palsies, INO, Horner, surgery...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
