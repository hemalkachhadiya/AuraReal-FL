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
      final lastMessage = room.createdAt?.toString() ?? "Tap to view messages";

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
}

// import 'package:aura_real/aura_real.dart';
//
// class ChatProvider extends ChangeNotifier {
//   ChatProvider() {
//     initializeChatData();
//   }
//
//   /// Chat List =============================
//   List<GetUserChatRoomModel> _chatList = [];
//   List<GetUserChatRoomModel> _filteredChatList = [];
//   String _searchQuery = '';
//   bool isLoading = false;
//
//   // Getters
//   List<GetUserChatRoomModel> get chatList =>
//       _filteredChatList.isEmpty && _searchQuery.isEmpty
//           ? _chatList
//           : _filteredChatList;
//
//   String get searchQuery => _searchQuery;
//
//   /// 🔥 Fetch user chat rooms from API
//   Future<void> fetchUserChatRooms() async {
//     isLoading = true;
//     notifyListeners();
//     print("User Chat ------ ${userData!.id!}");
//
//     try {
//       final response = await ChatApis.getUserChatRoom(userId: userData!.id!);
//
//       if (response != null && response.data != null) {
//         _chatList = response.data!;
//       } else {
//         _chatList = [];
//       }
//     } catch (e, st) {
//       debugPrint("Error fetching chat rooms: $e\n$st");
//       _chatList = [];
//     }
//
//     isLoading = false;
//     notifyListeners();
//   }
//
//   initializeChatData() async {
//     isLoading = true;
//     await fetchUserChatRooms();
//     notifyListeners();
//
//     isLoading = false;
//     notifyListeners();
//   }
//
//   // Search functionality
//   void searchChats(String query) {
//     _searchQuery = query;
//
//     if (query.isEmpty) {
//       _filteredChatList = [];
//     } else {
//       _filteredChatList =
//           _chatList.where((room) {
//             final otherParticipant = room.participants?.firstWhere(
//               (participant) => participant.id != userData!.id!,
//               orElse: () => room.participants!.first,
//             );
//
//             final name = otherParticipant?.fullName ?? "";
//             final lastMessage =
//                 (room.createdAt?.toString() ?? "Tap to view messages");
//
//             return name.toLowerCase().contains(query.toLowerCase()) ||
//                 lastMessage.toLowerCase().contains(query.toLowerCase());
//           }).toList();
//     }
//
//     notifyListeners();
//   }
//
//   // Clear search
//   void clearSearch() {
//     _searchQuery = '';
//     _filteredChatList = [];
//     notifyListeners();
//   }
//
//   // Mark chat as read
//   void markAsRead(String chatId) {
//     final chatIndex = _chatList.indexWhere((chat) => chat.id == chatId);
//     if (chatIndex != -1) {
//       // ✅ Update unread count map
//       if (_chatList[chatIndex].unreadCount != null &&
//           userData!.id != null &&
//           _chatList[chatIndex].unreadCount!.containsKey(userData!.id!)) {
//         _chatList[chatIndex].unreadCount![userData!.id!] = 0;
//       }
//       notifyListeners();
//     }
//   }
//
//   // Add new chat room
//   void addNewChat(GetUserChatRoomModel room) {
//     _chatList.insert(0, room);
//     notifyListeners();
//   }
//
//   // Delete chat
//   void deleteChat(String chatId) {
//     _chatList.removeWhere((chat) => chat.id == chatId);
//     _filteredChatList.removeWhere((chat) => chat.id == chatId);
//     notifyListeners();
//   }
//
//   // Get unread count
//   int get totalUnreadCount {
//     return _chatList.fold(0, (sum, room) {
//       if (room.unreadCount != null && userData!.id != null) {
//         return sum + (room.unreadCount![userData!.id!] ?? 0);
//       }
//       return sum;
//     });
//   }
// }
//
// //
// // import 'package:aura_real/aura_real.dart' ;
// //
// // class ChatMessage {
// //   final String id;
// //   final String name;
// //   final String message;
// //   final String avatarUrl;
// //   final String time;
// //   final int unreadCount;
// //   final bool isOnline;
// //
// //   ChatMessage({
// //     required this.id,
// //     required this.name,
// //     required this.message,
// //     required this.avatarUrl,
// //     required this.time,
// //     required this.unreadCount,
// //     required this.isOnline,
// //   });
// // }
// //
// // class ChatProvider extends ChangeNotifier {
// //   ChatProvider() {
// //     initializeChatData();
// //   }
// //
// //   ///Chat List=============================
// //   List<ChatMessage> _chatList = [];
// //   List<ChatMessage> _filteredChatList = [];
// //   String _searchQuery = '';
// //   bool isLoading = false;
// //
// //   // Getters
// //   List<ChatMessage> get chatList =>
// //       _filteredChatList.isEmpty && _searchQuery.isEmpty
// //           ? _chatList
// //           : _filteredChatList;
// //
// //   String get searchQuery => _searchQuery;
// //
// //
// //
// //   /// 🔥 Fetch user chat rooms from API
// //   Future<void> fetchUserChatRooms() async {
// //     isLoading = true;
// //     notifyListeners();
// //     print("User Chat ------ ${userData!.id!}");
// //
// //     try {
// //       final response = await ChatApis.getUserChatRoom(userId: userData!.id!);
// //
// //       if (response != null && response.data != null) {
// //         _chatList =
// //             response.data!.map((room) {
// //               // Find the participant that is NOT the logged-in user
// //               final otherParticipant = room.participants?.firstWhere(
// //                 (participant) => participant.id != userData!.id!,
// //               );
// //
// //               // ✅ Updated to handle Map<String, int> unreadCount
// //               int unreadCount = 0;
// //               if (room.unreadCount != null && userData!.id != null) {
// //                 // Get unread count for current user
// //                 unreadCount = room.unreadCount![userData!.id!] ?? 0;
// //               }
// //
// //               print("_chatList=========== ${_chatList.length}");
// //               return ChatMessage(
// //                 id: room.id ?? "",
// //                 name: otherParticipant?.fullName ?? "Unknown",
// //                 message: "Tap to view messages",
// //                 // You can replace with last message API
// //                 avatarUrl:
// //                     otherParticipant?.profile?.profileImage != null
// //                         ? "https://your-base-url.com/${otherParticipant!.profile!.profileImage}" // ✅ Add your base URL
// //                         : "https://via.placeholder.com/150",
// //                 time:
// //                     room.updatedAt != null
// //                         ? _formatTime(room.updatedAt!)
// //                         : "--:--",
// //                 unreadCount: unreadCount,
// //                 isOnline:
// //                     false, // No online status in API → maybe set via socket later
// //               );
// //             }).toList();
// //       } else {
// //         _chatList = [];
// //       }
// //     } catch (e, st) {
// //       debugPrint("Error fetching chat rooms: $e\n$st");
// //       _chatList = [];
// //     }
// //
// //     isLoading = false;
// //     notifyListeners();
// //   }
// //
// //   /// Format time to display (example: "3:40 PM")
// //   String _formatTime(DateTime dateTime) {
// //     final now = DateTime.now();
// //     final isToday =
// //         now.year == dateTime.year &&
// //         now.month == dateTime.month &&
// //         now.day == dateTime.day;
// //
// //     if (isToday) {
// //       return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}"; // 14:05
// //     } else {
// //       return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
// //     }
// //   }
// //
// //   initializeChatData() async {
// //     isLoading = true;
// //     await fetchUserChatRooms();
// //     notifyListeners();
// //
// //     isLoading = false;
// //     notifyListeners();
// //   }
// //
// //   // Search functionality
// //   void searchChats(String query) {
// //     _searchQuery = query;
// //
// //     if (query.isEmpty) {
// //       _filteredChatList = [];
// //     } else {
// //       _filteredChatList =
// //           _chatList.where((chat) {
// //             return chat.name.toLowerCase().contains(query.toLowerCase()) ||
// //                 chat.message.toLowerCase().contains(query.toLowerCase());
// //           }).toList();
// //     }
// //
// //     notifyListeners();
// //   }
// //
// //   // Clear search
// //   void clearSearch() {
// //     _searchQuery = '';
// //     _filteredChatList = [];
// //     notifyListeners();
// //   }
// //
// //   // Mark chat as read
// //   void markAsRead(String chatId) {
// //     final chatIndex = _chatList.indexWhere((chat) => chat.id == chatId);
// //     if (chatIndex != -1) {
// //       _chatList[chatIndex] = ChatMessage(
// //         id: _chatList[chatIndex].id,
// //         name: _chatList[chatIndex].name,
// //         message: _chatList[chatIndex].message,
// //         time: _chatList[chatIndex].time,
// //         avatarUrl: _chatList[chatIndex].avatarUrl,
// //         unreadCount: 0,
// //         isOnline: _chatList[chatIndex].isOnline,
// //       );
// //       notifyListeners();
// //     }
// //   }
// //
// //   // Add new message
// //   void addNewMessage(ChatMessage message) {
// //     _chatList.insert(0, message);
// //     notifyListeners();
// //   }
// //
// //   // Delete chat
// //   void deleteChat(String chatId) {
// //     _chatList.removeWhere((chat) => chat.id == chatId);
// //     _filteredChatList.removeWhere((chat) => chat.id == chatId);
// //     notifyListeners();
// //   }
// //
// //   // Get unread count
// //   int get totalUnreadCount {
// //     return _chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
// //   }
// // }
