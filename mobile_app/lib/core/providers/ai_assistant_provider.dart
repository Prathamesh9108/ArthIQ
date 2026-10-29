import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiAssistantProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg_welcome',
      text: 'Hi Rahul! 🤖 How can I help you today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  final List<String> suggestionChips = [
    'How much can I save?',
    'Forecast my expenses',
    'Find unusual spending',
    'Rebalance my food budget',
  ];

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      final replyText = await _apiService.queryAiAssistant(text);
      final botMsg = ChatMessage(
        id: 'msg_bot_${DateTime.now().millisecondsSinceEpoch}',
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMsg);
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
          text: "I'm having trouble analyzing that right now. Please try again in a moment.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        text: 'Hi Rahul! 🤖 How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
