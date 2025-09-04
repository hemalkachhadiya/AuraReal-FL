import 'package:aura_real/aura_real.dart';

import 'package:flutter/material.dart';

// Message Model
class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

// Chat User Model
class ChatUser {
  final String? id;
  final String? name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
   this.id,
   this.name,
   this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });
}

class MessageProvider extends ChangeNotifier {
  List<Message> _messages = [];
  ChatUser? _currentUser;
  bool _isLoading = false;
  bool _isTyping = false;
  String _messageText = '';

  // Getters
  List<Message> get messages => _messages;
  ChatUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String get messageText => _messageText;
  bool get canSendMessage => _messageText.trim().isNotEmpty;

  // Initialize chat data
  void initializeChat({required ChatUser user}) {
    _currentUser = user;
    _isLoading = true;
    notifyListeners();

    // Sample messages similar to the image
    _messages = [
      Message(
        id: '1',
        text: 'Hey there! 👋',
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
        isFromMe: false,
      ),
      Message(
        id: '2',
        text: 'This is your delivery driver from Speedy Chow. I\'m just around the corner from your place. 😊',
        timestamp: DateTime.now().subtract(const Duration(minutes: 49)),
        isFromMe: false,
      ),
      Message(
        id: '3',
        text: 'Hi!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 48)),
        isFromMe: true,
        status: MessageStatus.read,
      ),
      Message(
        id: '4',
        text: 'Awesome, thanks for letting me know! Can\'t wait for my delivery. 🚀',
        timestamp: DateTime.now().subtract(const Duration(minutes: 47)),
        isFromMe: true,
        status: MessageStatus.read,
      ),
      Message(
        id: '5',
        text: 'No problem at all! I\'ll be there in about 15 minutes.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 46)),
        isFromMe: false,
      ),
      Message(
        id: '6',
        text: 'I\'ll text you when I arrive.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isFromMe: false,
      ),
      Message(
        id: '7',
        text: 'Great! 😊',
        timestamp: DateTime.now().subtract(const Duration(minutes: 44)),
        isFromMe: true,
        status: MessageStatus.delivered,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Update message text
  void updateMessageText(String text) {
    _messageText = text;
    notifyListeners();
  }

  // Send message
  void sendMessage() {
    if (!canSendMessage) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageText.trim(),
      timestamp: DateTime.now(),
      isFromMe: true,
      status: MessageStatus.sending,
    );

    _messages.add(newMessage);
    _messageText = '';
    notifyListeners();

    // Simulate message sending
    _simulateMessageSending(newMessage.id);
  }

  // Simulate message sending process
  void _simulateMessageSending(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Update to sent
    _updateMessageStatus(messageId, MessageStatus.sent);

    await Future.delayed(const Duration(seconds: 1));

    // Update to delivered
    _updateMessageStatus(messageId, MessageStatus.delivered);

    // Simulate auto-reply (optional)
    _simulateAutoReply();
  }

  // Update message status
  void _updateMessageStatus(String messageId, MessageStatus status) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = Message(
        id: _messages[messageIndex].id,
        text: _messages[messageIndex].text,
        timestamp: _messages[messageIndex].timestamp,
        isFromMe: _messages[messageIndex].isFromMe,
        status: status,
      );
      notifyListeners();
    }
  }

  // Simulate auto-reply (for demo purposes)
  void _simulateAutoReply() async {
    await Future.delayed(const Duration(seconds: 2));

    _isTyping = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final replies = [
      'Thanks for your message! 👍',
      'Got it!',
      'On my way! 🚗',
      'See you soon!',
      'Perfect! 😊',
    ];

    final reply = replies[DateTime.now().millisecond % replies.length];

    final autoReply = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: reply,
      timestamp: DateTime.now(),
      isFromMe: false,
    );

    _messages.add(autoReply);
    _isTyping = false;
    notifyListeners();
  }

  // Mark messages as read
  void markMessagesAsRead() {
    bool hasChanges = false;
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isFromMe && _messages[i].status != MessageStatus.read) {
        _messages[i] = Message(
          id: _messages[i].id,
          text: _messages[i].text,
          timestamp: _messages[i].timestamp,
          isFromMe: _messages[i].isFromMe,
          status: MessageStatus.read,
        );
        hasChanges = true;
      }
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  // Format timestamp for display
  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  // Get status icon for sent messages
  IconData getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  // Get status color
  Color getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
    }
  }

  // Clear messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
