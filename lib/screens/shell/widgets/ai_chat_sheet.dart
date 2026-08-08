import 'package:digital_art_school/models/student.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../services/groq_service.dart';
import '../../../state/app_state.dart';

class _ChatMessage {
  final String text;
  final bool fromBot;
  final bool isError;
  _ChatMessage(this.text, this.fromBot, {this.isError = false});
}

/// Opens the AI Learning Assistant as a draggable bottom sheet. Call
/// this from anywhere (the floating AI bar, the dashboard, etc.) —
/// it's the single shared entry point so there's only one chat
/// implementation to maintain.
void showAiAssistantSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const AiChatSheet(),
  );
}

class AiChatSheet extends StatefulWidget {
  const AiChatSheet({super.key});

  @override
  State<AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<AiChatSheet> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _waitingForReply = false;

  late final List<_ChatMessage> _messages = [
    _ChatMessage(
      "Hello! I'm your AI learning assistant, powered by Groq. Ask me "
      "anything about your courses, practice schedule, or upcoming "
      "sessions.",
      true,
    ),
  ];

  String _buildSystemPrompt(BuildContext context) {
    final student = context.read<AppState>().student;
    final buffer = StringBuffer(
      'You are the friendly, encouraging AI Learning Assistant inside the '
      'Digital Art School student app. Keep answers short (2-4 sentences), '
      'warm, and specific to the arts (classical dance, vocal music, '
      'visual arts, etc). If you don\'t have enough context about the '
      'student\'s actual data, say so plainly rather than inventing details.',
    );
    if (student != null) {
      buffer.write(
        '\n\nStudent context: name=${student.fullName}, '
        'artCategory=${student.artCategory ?? "not set"}, '
        'artDiscipline=${student.artDiscipline ?? "not set"}, '
        'skillLevel=${student.skillLevel?.label ?? "not set"}, '
        'hasTeacher=${student.hasTeacher}'
        '${student.hasTeacher ? ", teacherName=${student.teacherName}" : ""}.',
      );
    }
    return buffer.toString();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _waitingForReply) return;

    setState(() {
      _messages.add(_ChatMessage(text, false));
      _inputCtrl.clear();
      _waitingForReply = true;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => !m.isError)
          .map((m) => {'role': m.fromBot ? 'assistant' : 'user', 'content': m.text})
          .toList();

      final reply = await GroqService.sendMessage(
        systemPrompt: _buildSystemPrompt(context),
        history: history,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          reply.isEmpty ? "Hmm, I didn't get a response — try asking again?" : reply,
          true,
        ));
      });
    } on GroqException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(e.message, true, isError: true));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage('Something went wrong: $e', true, isError: true));
      });
    } finally {
      if (mounted) setState(() => _waitingForReply = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.78,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: AppColors.deepGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.sparkles, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('AI Learning Assistant',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                    if (!GroqService.isConfigured)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('No API key',
                            style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700)),
                      ),
                    IconButton(
                      icon: const Icon(AppIcons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_waitingForReply ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final m = _messages[i];
                    return Align(
                      alignment: m.fromBot ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: m.isError
                              ? AppColors.danger.withOpacity(0.1)
                              : (m.fromBot ? AppColors.coconut : AppColors.blue),
                          borderRadius: BorderRadius.circular(16),
                          border: m.isError
                              ? Border.all(color: AppColors.danger.withOpacity(0.3))
                              : null,
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: m.isError
                                ? AppColors.danger
                                : (m.fromBot ? AppColors.deep : Colors.white),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        enabled: !_waitingForReply,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(hintText: 'Ask me anything…'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.mainGradient,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(AppIcons.send, color: Colors.white, size: 18),
                        onPressed: _waitingForReply ? null : _send,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
