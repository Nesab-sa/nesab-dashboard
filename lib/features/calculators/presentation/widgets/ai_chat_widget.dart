import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/repositories/ai_chat_repository.dart';

/// Floating AI chat widget matching HTML `.ai-widget` / `.ai-fab` / `.ai-panel`.
/// Uses the Cloud Function proxy — never calls the API directly.
class AiChatWidget extends StatefulWidget {
  const AiChatWidget({
    super.key,
    this.contextBuilder,
  });

  /// Optional callback that returns the current calculator context string
  /// to send along with the AI message (e.g. "تمويل 100,000 ريال، 60 شهر").
  final String Function()? contextBuilder;

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget> {
  bool _isOpen = false;
  bool _isLoading = false;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <_ChatMsg>[
    _ChatMsg(
      text: 'مرحباً! احسب أولاً ثم اسألني.',
      isUser: false,
    ),
  ];

  String? _conversationId;
  final _repo = AiChatRepository();

  void _toggle() => setState(() => _isOpen = !_isOpen);

  Future<void> _send() async {
    final q = _inputCtrl.text.trim();
    if (q.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMsg(text: q, isUser: true));
      _isLoading = true;
      _inputCtrl.clear();
    });
    _scrollToBottom();

    try {
      final result = await _repo.sendMessage(
        message: q,
        pageContext: widget.contextBuilder?.call(),
        conversationId: _conversationId,
        source: 'app',
      );
      _conversationId = result.conversationId ?? _conversationId;
      setState(() {
        _messages.add(_ChatMsg(text: result.reply, isUser: false));
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _messages.add(_ChatMsg(text: 'تعذر الاتصال.', isUser: false));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
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
    return Positioned(
      bottom: 24,
      right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Panel
          if (_isOpen)
            Container(
              width: MediaQuery.of(context).size.width < 600 ? 260 : 320,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.calcCard,
                border: Border.all(color: AppColors.calcBorder2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 40,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.calcNeon2, AppColors.calcNeon],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المستشار البنكي',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggle,
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  // Messages
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(10),
                        shrinkWrap: true,
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == _messages.length) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 7),
                              child: Text(
                                'المستشار البنكي: ...',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.calcNeon,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }
                          final msg = _messages[i];
                          if (msg.isUser) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Text(
                                'أنت: ${msg.text}',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFFA0C0FF),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: RichText(
                              textDirection: TextDirection.rtl,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'المستشار البنكي: ',
                                    style: TextStyle(
                                      color: AppColors.calcNeon,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text: msg.text,
                                    style: const TextStyle(
                                      color: AppColors.calcText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.calcBorder)),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputCtrl,
                              style: const TextStyle(
                                color: AppColors.calcText,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'اسألني...',
                                hintStyle: const TextStyle(
                                  color: AppColors.calcMuted,
                                  fontSize: 13,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                filled: true,
                                fillColor: AppColors.calcInput,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(color: AppColors.calcBorder2),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(color: AppColors.calcBorder2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: const BorderSide(color: AppColors.calcNeon2),
                                ),
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _send,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.calcNeon2,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'إرسال',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // FAB
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.calcNeon2, AppColors.calcNeon],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.calcNeon2.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.chat_bubble, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  _ChatMsg({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
