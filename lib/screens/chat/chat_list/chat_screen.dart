import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/chat/chat_list/chat_provider.dart';
import 'package:aura_real/screens/chat/message/message_provider.dart';
import 'package:aura_real/screens/chat/message/message_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const routeName = "chat_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => ChatProvider()..initializeChatData(),
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

              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(context),
                    Expanded(
                      child:
                      chatProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : chatProvider.chatList.isEmpty
                          ? _buildEmptyState()
                          : _buildChatList(chatProvider.chatList),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text('Message', style: styleW700S22),
      ),
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
          hintStyle: TextStyle(color: ColorRes.black, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 15,
              bottom: 15,
              right: 15,
            ),
            child: SvgAsset(
              imagePath: "assets/images/serch_icon.svg",
              height: 20,
              width: 20,
            ),
          ),
          // prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
          // suffixIcon:
          //     Provider.of<ChatProvider>(context).searchQuery.isNotEmpty
          //         ? IconButton(
          //           onPressed: () {
          //             _searchController.clear();
          //             Provider.of<ChatProvider>(
          //               context,
          //               listen: false,
          //             ).clearSearch();
          //           },
          //           icon: Icon(Icons.clear, color: ColorRes.black, size: 20),
          //         )
          //         : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> chats) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: index == 0 ? 0 : 30,
          ),
          child: _buildChatTile(context, chat),
        );
      },
    );
  }

  Widget _buildChatTile(BuildContext context, ChatMessage chat) {
    return GestureDetector(
      onTap: () {
        print("Navigating to MessageScreen");
        if (context.mounted) {
          // Convert ChatMessage to ChatUser
          final chatUser = ChatUser(
            name: chat.name,
            avatarUrl: chat.avatarUrl,
            isOnline: chat.isOnline,
          );
          Navigator.of(context, rootNavigator: true).pushNamed(
            MessageScreen.routeName, // Should be "/message"
            arguments: chatUser,
          );
        }
        Provider.of<ChatProvider>(context, listen: false).markAsRead(chat.id);
        // },
      },
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),

                  image: DecorationImage(
                    image: NetworkImage(chat.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              if (chat.isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  style: styleW700S17,

                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  chat.message,
                  style: styleW400S12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: styleW400S10.copyWith(
                    color: ColorRes.darkJungleGreen,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorRes.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    // ListTile(
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    //   leading: Stack(
    //     children: [
    //       // CircleAvatar(
    //       //   radius: 24,
    //       //   backgroundImage: NetworkImage(chat.avatarUrl),
    //       //   backgroundColor: Colors.grey[300],
    //       // ),
    //       Container(
    //         height: 70,
    //         width: 70,
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(24),

    //           image: DecorationImage(
    //             image: NetworkImage(chat.avatarUrl),
    //             fit: BoxFit.cover,
    //           ),
    //         ),
    //       ),
    //       if (chat.isOnline)
    //         Positioned(
    //           right: 2,
    //           bottom: 2,
    //           child: Container(
    //             width: 16,
    //             height: 16,
    //             decoration: BoxDecoration(
    //               color: Colors.green,
    //               shape: BoxShape.circle,
    //               border: Border.all(color: Colors.white, width: 2),
    //             ),
    //           ),
    //         ),
    //     ],
    //   ),
    //   title: Text(chat.name, style: styleW700S18),
    //   subtitle: Text(
    //     chat.message,
    //     style: styleW400S12,
    //     maxLines: 1,
    //     overflow: TextOverflow.ellipsis,
    //   ),
    //   trailing: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     crossAxisAlignment: CrossAxisAlignment.end,
    //     children: [
    //       Text(
    //         chat.time,
    //         style: styleW400S12.copyWith(
    //           color:
    //               chat.unreadCount > 0
    //                   ? ColorRes.primaryColor
    //                   : Colors.grey[600],
    //           fontWeight:
    //               chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
    //         ),
    //       ),
    //       const SizedBox(height: 4),
    //       if (chat.unreadCount > 0)
    //         Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //           decoration: BoxDecoration(
    //             color: ColorRes.primaryColor,
    //             borderRadius: BorderRadius.circular(12),
    //           ),
    //           child: Text(
    //             chat.unreadCount.toString(),
    //             style: const TextStyle(
    //               color: Colors.white,
    //               fontSize: 12,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //         ),
    //     ],
    //   ),
    //   onTap: () {
    //     print("Navigating to MessageScreen");
    //     if (context.mounted) {
    //       // Convert ChatMessage to ChatUser
    //       final chatUser = ChatUser(
    //         name: chat.name,
    //         avatarUrl: chat.avatarUrl,
    //         isOnline: chat.isOnline,
    //       );
    //       Navigator.of(context, rootNavigator: true).pushNamed(
    //         MessageScreen.routeName, // Should be "/message"
    //         arguments: chatUser,
    //       );
    //     }
    //     Provider.of<ChatProvider>(context, listen: false).markAsRead(chat.id);
    //   },
    // );

    //  Dismissible(
    //   key: Key(chat.id),
    //   direction: DismissDirection.endToStart,
    //   background: Container(
    //     alignment: Alignment.centerRight,
    //     padding: const EdgeInsets.only(right: 16),
    //     color: Colors.red,
    //     child: const Icon(Icons.delete, color: Colors.white),
    //   ),
    //   onDismissed: (direction) {
    //     Provider.of<ChatProvider>(context, listen: false).deleteChat(chat.id);
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('${chat.name} deleted'),
    //         action: SnackBarAction(
    //           label: 'Undo',
    //           onPressed: () {
    //             // Could implement undo functionality here
    //           },
    //         ),
    //       ),
    //     );
    //   },
    //   child:
    // );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
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
    );
  }
}
