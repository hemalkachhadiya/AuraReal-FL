import 'package:aura_real/aura_real.dart';

import 'package:flutter/material.dart';



class ChatMessage {
  final String id;
  final String name;
  final String message;
  final String avatarUrl;
  final String time;
  final int unreadCount;
  final bool isOnline;

  ChatMessage({
    required this.id,
    required this.name,
    required this.message,
    required this.avatarUrl,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
  });
}



class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _chatList = [];
  List<ChatMessage> _filteredChatList = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<ChatMessage> get chatList => _filteredChatList.isEmpty && _searchQuery.isEmpty
      ? _chatList
      : _filteredChatList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Initialize chat data
  void initializeChatData() {
    _isLoading = true;
    notifyListeners();

    // Sample chat data similar to the image
    _chatList = [
      ChatMessage(
        id: '1',
        name: 'Jenny Wilson',
        message: 'Of course, we just added that to you...',
        time: '3:40 PM',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b789?w=150&h=150&fit=crop&crop=face',
        unreadCount: 2,
        isOnline: true,
      ),
      ChatMessage(
        id: '2',
        name: 'Davis Siphron',
        message: 'From chew toys to cozy beds, we\'ve got ev...',
        time: '3:40 PM',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        unreadCount: 0,
        isOnline: false,
      ),
      ChatMessage(
        id: '3',
        name: 'Aspen Herwitz',
        message: 'From chew toys to cozy beds, we\'ve got ev...',
        time: '3:40 PM',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        unreadCount: 0,
        isOnline: false,
      ),
      ChatMessage(
        id: '4',
        name: 'Cheyenne Kenter',
        message: 'From chew toys to cozy beds, we\'ve got ev...',
        time: '3:40 PM',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
        unreadCount: 0,
        isOnline: false,
      ),
      ChatMessage(
        id: '5',
        name: 'Livia Ekstrom Bothman',
        message: 'From chew toys to cozy beds, we\'ve got ev...',
        time: '3:40 PM',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
        unreadCount: 0,
        isOnline: false,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Search functionality
  void searchChats(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredChatList = [];
    } else {
      _filteredChatList = _chatList.where((chat) {
        return chat.name.toLowerCase().contains(query.toLowerCase()) ||
            chat.message.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredChatList = [];
    notifyListeners();
  }

  // Mark chat as read
  void markAsRead(String chatId) {
    final chatIndex = _chatList.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _chatList[chatIndex] = ChatMessage(
        id: _chatList[chatIndex].id,
        name: _chatList[chatIndex].name,
        message: _chatList[chatIndex].message,
        time: _chatList[chatIndex].time,
        avatarUrl: _chatList[chatIndex].avatarUrl,
        unreadCount: 0,
        isOnline: _chatList[chatIndex].isOnline,
      );
      notifyListeners();
    }
  }

  // Add new message
  void addNewMessage(ChatMessage message) {
    _chatList.insert(0, message);
    notifyListeners();
  }

  // Delete chat
  void deleteChat(String chatId) {
    _chatList.removeWhere((chat) => chat.id == chatId);
    _filteredChatList.removeWhere((chat) => chat.id == chatId);
    notifyListeners();
  }

  // Get unread count
  int get totalUnreadCount {
    return _chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
  }
}