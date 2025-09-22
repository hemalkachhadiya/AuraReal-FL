import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/chat/chat_list/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const routeName = "chat_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => ChatProvider(),
      child: const ChatScreen(),
    );
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 0, left: 20, bottom: 20),
                color: Colors.white,
                child: Text('Message', style: styleW700S22),
              ),
              _buildSearchBar(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await chatProvider.fetchUserChatRooms();
                  },
                  child:
                      chatProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : chatProvider.visibleChatList.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: chatProvider.visibleChatList.length,
                            itemBuilder: (context, index) {
                              final chat = chatProvider.visibleChatList[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  top: index == 0 ? 0 : 30,
                                ),
                                child: _buildChatTile(context, chat),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A03241E),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          Provider.of<ChatProvider>(context, listen: false).searchChats(value);
        },
        decoration: InputDecoration(
          hintText: 'Search..',
          hintStyle: const TextStyle(color: ColorRes.black, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 15,
              bottom: 15,
              right: 15,
            ),
            child: SvgAsset(
              imagePath: AssetRes.serchIcon,
              height: 20,
              width: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, GetUserChatRoomModel chatRoom) {
    final otherParticipant = chatRoom.participants?.firstWhere(
      (p) => p.id != userData!.id!,
      orElse: () => chatRoom.participants!.first,
    );

    final avatarUrl =
        (otherParticipant?.profile?.profileImage != null &&
                otherParticipant!.profile!.profileImage!.isNotEmpty)
            ? "${EndPoints.domain}${otherParticipant.profile!.profileImage}"
            : "https://via.placeholder.com/150";

    // ✅ Fix unread count for current user
    final unreadCount = chatRoom.unreadCount?[userData!.id!] ?? 0;

    final formattedTime =
        chatRoom.updatedAt != null ? formatTime(chatRoom.updatedAt!) : "--:--";

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          final chatUser = ChatUser(
            id: otherParticipant?.id ?? "",
            name: otherParticipant?.fullName ?? "Unknown",
            avatarUrl: avatarUrl,
            isOnline: false,
          );

          Provider.of<ChatProvider>(
            context,
            listen: false,
          ).markAsRead(chatRoom.id ?? "");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChangeNotifierProvider(
                    create: (_) {
                      final provider = MessageProvider();
                      provider.initializeChat(
                        user: chatUser,
                        roomId: chatRoom.id ?? "",
                      );
                      return provider;
                    },
                    child: MessageScreen(chatUser: chatUser),
                  ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  height: 70.pw,
                  width: 70.ph,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          avatarUrl.isEmpty
                              ? ColorRes.white
                              : ColorRes.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.pw),
                    child: CachedImage(avatarUrl),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14.pw,
                    height: 14.ph,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherParticipant?.fullName ?? "Unknown",
                    style: styleW700S18.copyWith(
                      color: ColorRes.darkJungleGreen,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.ph.spaceVertical,
                  Text(
                    "Tap to view messages",
                    style: styleW400S12.copyWith(
                      color:
                          unreadCount > 0
                              ? ColorRes.primaryColor
                              : ColorRes.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: styleW400S12.copyWith(color: ColorRes.darkJungleGreen),
                ),
                5.ph.spaceVertical,
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ColorRes.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: styleW700S12.copyWith(color: ColorRes.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation with someone',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:aura_real/aura_real.dart';
// import 'package:aura_real/screens/chat/chat_list/chat_provider.dart';
// import 'package:aura_real/screens/chat/message/message_provider.dart';
// import 'package:aura_real/screens/chat/message/message_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   static const routeName = "chat_screen";
//
//   static Widget builder(BuildContext context) {
//     return ChangeNotifierProvider<ChatProvider>(
//       create: (context) => ChatProvider()..initializeChatData(),
//       child: const ChatScreen(),
//     );
//   }
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatProvider>(
//       builder: (context, chatProvider, child) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 40),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.only(top: 0, left: 20, bottom: 20),
//                 color: Colors.white,
//                 child: Text('Message', style: styleW700S22),
//               ),
//               _buildSearchBar(context),
//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: () async {
//                     await chatProvider.initializeChatData();
//                   },
//                   child:
//                       chatProvider.isLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : chatProvider.chatList.isEmpty
//                           ? _buildEmptyState(context)
//                           : ListView.builder(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             itemCount: chatProvider.chatList.length,
//                             itemBuilder: (context, index) {
//                               final chat = chatProvider.chatList[index];
//                               return Padding(
//                                 padding: EdgeInsets.only(
//                                   left: 24,
//                                   right: 24,
//                                   top: index == 0 ? 0 : 30,
//                                 ),
//                                 child: _buildChatTile(context, chat),
//                               );
//                             },
//                           ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSearchBar(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0x1A03241E),
//             blurRadius: 40,
//             offset: const Offset(0, 16),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (value) {
//           Provider.of<ChatProvider>(context, listen: false).searchChats(value);
//         },
//         decoration: InputDecoration(
//           hintText: 'Search..',
//           hintStyle: const TextStyle(color: ColorRes.black, fontSize: 14),
//           prefixIcon: Padding(
//             padding: const EdgeInsets.only(
//               left: 20,
//               top: 15,
//               bottom: 15,
//               right: 15,
//             ),
//             child: SvgAsset(
//               imagePath: "assets/images/serch_icon.svg",
//               height: 20,
//               width: 20,
//             ),
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildChatTile(BuildContext context, GetUserChatRoomModel chatRoom) {
//     // Find other participant (not current user)
//     final otherParticipant = chatRoom.participants?.firstWhere(
//       (p) => p.id != userData!.id!,
//       orElse: () => chatRoom.participants!.first,
//     );
//
//     // Profile image
//     final avatarUrl =
//         (otherParticipant?.profile?.profileImage != null &&
//                 otherParticipant!.profile!.profileImage!.isNotEmpty)
//             ? "${EndPoints.domain}${otherParticipant.profile!.profileImage}"
//             : "https://via.placeholder.com/150";
//
//     // Unread count for current user
//     final unreadCount = chatRoom.unreadCount?[otherParticipant!.id!] ?? 0;
//
//     // Last updated time
//     final formattedTime =
//         chatRoom.updatedAt != null ? formatTime(chatRoom.updatedAt!) : "--:--";
//
//     return GestureDetector(
//       onTap: () {
//         if (context.mounted) {
//           final chatUser = ChatUser(
//             id: otherParticipant?.id ?? "",
//             name: otherParticipant?.fullName ?? "Unknown",
//             avatarUrl: avatarUrl,
//             isOnline: false, // set via socket later
//           );
//
//           // Mark chat as read
//           Provider.of<ChatProvider>(
//             context,
//             listen: false,
//           ).markAsRead(chatRoom.id ?? "");
//
//           // Navigate to Message Screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (_) => ChangeNotifierProvider(
//                     create: (_) {
//                       final provider = MessageProvider();
//                       provider.initializeChat(
//                         user: chatUser,
//                         roomId: chatRoom.id ?? "",
//                       );
//                       return provider;
//                     },
//                     child: MessageScreen(chatUser: chatUser),
//                   ),
//             ),
//           );
//         }
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           children: [
//             Stack(
//               children: [
//                 Container(
//                   height: 70.pw,
//                   width: 70.ph,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(
//                       color:
//                           avatarUrl.isEmpty
//                               ? ColorRes.white
//                               : ColorRes.primaryColor,
//                       width: 2,
//                     ),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(24.pw),
//                     child: CachedImage(avatarUrl),
//                   ),
//                 ),
//                 // Optional online indicator if you add it later
//                 Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     width: 14.pw,
//                     height: 14.ph,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     otherParticipant?.fullName ?? "Unknown",
//                     style: styleW700S18.copyWith(
//                       color: ColorRes.darkJungleGreen,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   4.ph.spaceVertical,
//                   Text(
//                     "Tap to view messages", // can be replaced with last message
//                     style: styleW400S12.copyWith(
//                       color:
//                           unreadCount > 0
//                               ? ColorRes.primaryColor
//                               : ColorRes.black,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   formattedTime,
//                   style: styleW400S12.copyWith(color: ColorRes.darkJungleGreen),
//                 ),
//                 5.ph.spaceVertical,
//                 if (unreadCount > 0)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: ColorRes.primaryColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       unreadCount.toString(),
//                       style: styleW700S12.copyWith(color: ColorRes.white),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(BuildContext context) {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       children: [
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.6,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.chat_bubble_outline,
//                   size: 64,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No messages yet',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Start a conversation with someone',
//                   style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // import 'package:aura_real/aura_real.dart';
// // import 'package:aura_real/screens/chat/chat_list/chat_provider.dart';
// // import 'package:aura_real/screens/chat/message/message_provider.dart';
// // import 'package:aura_real/screens/chat/message/message_screen.dart';
// //
// // class ChatScreen extends StatefulWidget {
// //   const ChatScreen({super.key});
// //
// //   static const routeName = "chat_screen";
// //
// //   static Widget builder(BuildContext context) {
// //     return ChangeNotifierProvider<ChatProvider>(
// //       create: (context) => ChatProvider()..initializeChatData(),
// //       child: const ChatScreen(),
// //     );
// //   }
// //
// //   @override
// //   State<ChatScreen> createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> {
// //   final TextEditingController _searchController = TextEditingController();
// //
// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Consumer<ChatProvider>(
// //       builder: (context, chatProvider, child) {
// //         return Scaffold(
// //           backgroundColor: Colors.white,
// //           body: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const SizedBox(height: 40),
// //               Container(
// //                 width: double.infinity,
// //                 padding: const EdgeInsets.only(top: 0, left: 20, bottom: 20),
// //                 color: Colors.white,
// //                 child: Text('Message', style: styleW700S22),
// //               ),
// //               _buildSearchBar(context),
// //               Expanded(
// //                 child: RefreshIndicator(
// //                   onRefresh: () async {
// //                     await chatProvider.initializeChatData();
// //                   },
// //                   child:
// //                       chatProvider.isLoading
// //                           ? const Center(child: CircularProgressIndicator())
// //                           : chatProvider.chatList.isEmpty
// //                           ? _buildEmptyState(context)
// //                           : ListView.builder(
// //                             physics: const AlwaysScrollableScrollPhysics(),
// //                             itemCount: chatProvider.chatList.length,
// //                             itemBuilder: (context, index) {
// //                               final chat = chatProvider.chatList[index];
// //                               return Padding(
// //                                 padding: EdgeInsets.only(
// //                                   left: 24,
// //                                   right: 24,
// //                                   top: index == 0 ? 0 : 30,
// //                                 ),
// //                                 child: _buildChatTile(context, chat),
// //                               );
// //                             },
// //                           ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildSearchBar(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //             color: const Color(0x1A03241E),
// //             blurRadius: 40,
// //             offset: const Offset(0, 16),
// //             spreadRadius: 0,
// //           ),
// //         ],
// //       ),
// //       child: TextField(
// //         controller: _searchController,
// //         onChanged: (value) {
// //           Provider.of<ChatProvider>(context, listen: false).searchChats(value);
// //         },
// //         decoration: InputDecoration(
// //           hintText: 'Search..',
// //           hintStyle: const TextStyle(color: ColorRes.black, fontSize: 14),
// //           prefixIcon: Padding(
// //             padding: const EdgeInsets.only(
// //               left: 20,
// //               top: 15,
// //               bottom: 15,
// //               right: 15,
// //             ),
// //             child: SvgAsset(
// //               imagePath: "assets/images/serch_icon.svg",
// //               height: 20,
// //               width: 20,
// //             ),
// //           ),
// //           border: InputBorder.none,
// //           contentPadding: const EdgeInsets.symmetric(
// //             horizontal: 16,
// //             vertical: 12,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildChatTile(BuildContext context, ChatMessage chat) {
// //     return GestureDetector(
// //       onTap: () {
// //         if (context.mounted) {
// //           final chatUser = ChatUser(
// //             name: chat.name,
// //             avatarUrl: chat.avatarUrl,
// //             isOnline: chat.isOnline,
// //             id: chat.id,
// //           );
// //
// //           Provider.of<ChatProvider>(context, listen: false).markAsRead(chat.id);
// //
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder:
// //                   (_) => ChangeNotifierProvider(
// //                     create: (_) {
// //                       final provider = MessageProvider();
// //                       provider.initializeChat(
// //                         user: chatUser,
// //                         chatRoomId: chat.id,
// //                       );
// //                       return provider;
// //                     },
// //                     child: MessageScreen(chatUser: chatUser),
// //                   ),
// //             ),
// //           );
// //         }
// //       },
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
// //         child: Row(
// //           children: [
// //             Stack(
// //               children: [
// //                 Container(
// //                   height: 60,
// //                   width: 60,
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(30),
// //                     child: CachedImage(EndPoints.domain + chat.avatarUrl),
// //                   ),
// //                 ),
// //                 if (chat.isOnline)
// //                   Positioned(
// //                     right: 0,
// //                     bottom: 0,
// //                     child: Container(
// //                       width: 12,
// //                       height: 12,
// //                       decoration: BoxDecoration(
// //                         color: Colors.green,
// //                         shape: BoxShape.circle,
// //                         border: Border.all(color: Colors.white, width: 2),
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     chat.name,
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w700,
// //                       color: Colors.black87,
// //                     ),
// //                     overflow: TextOverflow.ellipsis,
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     chat.message,
// //                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: [
// //                 Text(
// //                   chat.time,
// //                   style: TextStyle(fontSize: 12, color: Colors.grey[500]),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 if (chat.unreadCount > 0)
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 6,
// //                       vertical: 2,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Color(0xFF9B59B6),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       chat.unreadCount.toString(),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmptyState(BuildContext context) {
// //     return ListView(
// //       physics: const AlwaysScrollableScrollPhysics(),
// //       children: [
// //         SizedBox(
// //           height: MediaQuery.of(context).size.height * 0.6,
// //           child: Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(
// //                   Icons.chat_bubble_outline,
// //                   size: 64,
// //                   color: Colors.grey[400],
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'No messages yet',
// //                   style: TextStyle(fontSize: 18, color: Colors.grey[600]),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   'Start a conversation with someone',
// //                   style: TextStyle(fontSize: 14, color: Colors.grey[500]),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
