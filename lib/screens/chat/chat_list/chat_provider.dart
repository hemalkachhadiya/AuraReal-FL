import 'package:aura_real/aura_real.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    initializeChatData();
  }

  /// Chat Room List =============================
  List<GetUserChatRoomModel> _chatList = [];
  String _searchQuery = '';
  bool isLoading = false;

  // Getters
  List<GetUserChatRoomModel> get chatList => visibleChatList;
  String get searchQuery => _searchQuery;

  /// 🔥 Fetch user chat rooms from API
  Future<void> fetchUserChatRooms() async {
    isLoading = true;
    notifyListeners();

    try {
      print("Fetching Chat Rooms for user: ${userData!.id!}");

      final response = await ChatApis.getUserChatRoom(userId: userData!.id!);

      if (response != null && response.data != null) {
        _chatList = response.data!;
      } else {
        _chatList = [];
      }
    } catch (e, st) {
      debugPrint("❌ Error fetching chat rooms: $e\n$st");
      _chatList = [];
    }

    isLoading = false;
    notifyListeners();
  }

  /// Initialize chat data
  Future<void> initializeChatData() async {
    isLoading = true;
    notifyListeners();

    await fetchUserChatRooms();

    isLoading = false;
    notifyListeners();
  }

  /// 🔍 Search functionality
  void searchChats(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Filtered list based on search query
  List<GetUserChatRoomModel> get visibleChatList {
    if (_searchQuery.isEmpty) return _chatList;

    return _chatList.where((room) {
      final otherParticipant = room.participants?.firstWhere(
            (participant) => participant.id != userData!.id!,
        orElse: () => room.participants!.first,
      );

      final name = otherParticipant?.fullName ?? "";
      final lastMessage = room.latestMessage ?? "Tap to view messages";

      return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  /// ✅ Mark chat as read
  void markAsRead(String chatId) {
    final chatIndex = _chatList.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      if (_chatList[chatIndex].unreadCount != null &&
          userData?.id != null &&
          _chatList[chatIndex].unreadCount!.containsKey(userData!.id!)) {
        _chatList[chatIndex].unreadCount![userData!.id!] = 0;
      }
      notifyListeners();
    }
  }

  /// ➕ Add new chat room
  void addNewChat(GetUserChatRoomModel room) {
    _chatList.insert(0, room);
    notifyListeners();
  }

  /// ❌ Delete chat
  void deleteChat(String chatId) {
    _chatList.removeWhere((chat) => chat.id == chatId);
    notifyListeners();
  }

  /// 🔔 Get total unread count
  int get totalUnreadCount {
    return _chatList.fold(0, (sum, room) {
      if (room.unreadCount != null && userData?.id != null) {
        return sum + (room.unreadCount![userData!.id!] ?? 0);
      }
      return sum;
    });
  }

  /// 🔔 Get unread count for specific chat
  int getUnreadCount(String chatId) {
    final chat = _chatList.firstWhere(
          (c) => c.id == chatId,
      orElse: () => GetUserChatRoomModel(),
    );
    return chat.unreadCount?[userData!.id!] ?? 0;
  }

  // ======================== INDIAN TIME UTILITIES ========================

  /// Convert UTC time to Indian Standard Time (IST)
  DateTime convertToIndianTime(DateTime utcTime) {
    // Indian Standard Time is UTC + 5:30
    return utcTime.add(const Duration(hours: 5, minutes: 30));
  }

  /// Format time for Indian timezone display
  String formatTime(DateTime utcDateTime) {
    // Convert UTC to IST
    final istTime = convertToIndianTime(utcDateTime);

    final now = DateTime.now();
    final istNow = convertToIndianTime(now.toUtc());

    final today = DateTime(istNow.year, istNow.month, istNow.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(istTime.year, istTime.month, istTime.day);

    if (messageDate == today) {
      // Today - show time in 12-hour format
      return _formatTime12Hour(istTime);
    } else if (messageDate == yesterday) {
      // Yesterday
      return "Yesterday";
    } else {
      // Older dates - show date
      return "${istTime.day.toString().padLeft(2, '0')}/"
          "${istTime.month.toString().padLeft(2, '0')}/"
          "${istTime.year}";
    }
  }

  /// Format time in 12-hour format (AM/PM)
  String _formatTime12Hour(DateTime time) {
    int hour = time.hour;
    String period = 'AM';

    if (hour == 0) {
      hour = 12; // Midnight
    } else if (hour == 12) {
      period = 'PM'; // Noon
    } else if (hour > 12) {
      hour = hour - 12; // Afternoon/Evening
      period = 'PM';
    }

    String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  /// Alternative: Format time in 24-hour format
  String formatTime24Hour(DateTime utcDateTime) {
    final istTime = convertToIndianTime(utcDateTime);

    final now = DateTime.now();
    final istNow = convertToIndianTime(now.toUtc());

    final today = DateTime(istNow.year, istNow.month, istNow.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(istTime.year, istTime.month, istTime.day);

    if (messageDate == today) {
      // Today - show time in 24-hour format
      return "${istTime.hour.toString().padLeft(2, '0')}:"
          "${istTime.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == yesterday) {
      return "Yesterday";
    } else {
      return "${istTime.day.toString().padLeft(2, '0')}/"
          "${istTime.month.toString().padLeft(2, '0')}/"
          "${istTime.year}";
    }
  }

  /// Get current Indian time
  DateTime getCurrentIndianTime() {
    return convertToIndianTime(DateTime.now().toUtc());
  }

  /// Format message time for chat (more detailed)
  String formatMessageTime(DateTime utcDateTime) {
    final istTime = convertToIndianTime(utcDateTime);
    final now = getCurrentIndianTime();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(istTime.year, istTime.month, istTime.day);

    if (messageDate == today) {
      // Today - show time
      return _formatTime12Hour(istTime);
    } else if (messageDate == yesterday) {
      // Yesterday with time
      return "Yesterday ${_formatTime12Hour(istTime)}";
    } else {
      // Show date with time for recent messages (within a week)
      final difference = now.difference(istTime).inDays;
      if (difference <= 7) {
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return "${weekdays[istTime.weekday - 1]} ${_formatTime12Hour(istTime)}";
      } else {
        // Older messages - just date
        return "${istTime.day}/${istTime.month}/${istTime.year}";
      }
    }
  }

  /// Get formatted time for chat list display
  String getChatTimeFormatted(GetUserChatRoomModel room) {
    if (room.latestMessageTime != null) {
      return formatTime(room.latestMessageTime!);
    } else if (room.updatedAt != null) {
      return formatTime(room.updatedAt!);
    } else {
      return "--:--";
    }
  }
}