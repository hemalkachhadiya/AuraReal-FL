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
                child:
                chatProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chatProvider.visibleChatList.isEmpty
                    ? _buildEmptyState(context)
                    : CustomListView(
                  itemCount: chatProvider.visibleChatList.length,
                  onRefresh: () => chatProvider.fetchUserChatRooms(),
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
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final otherParticipant = chatRoom.participants?.firstWhere(
          (p) => p.id != userData!.id!,
      orElse: () => chatRoom.participants!.first,
    );

    final avatarUrl =
    (otherParticipant?.profile?.profileImage != null &&
        otherParticipant!.profile!.profileImage!.isNotEmpty)
        ? "${EndPoints.domain}${otherParticipant.profile!.profileImage}"
        : "https://via.placeholder.com/150";

    // Fix unread count for current user
    final unreadCount = chatRoom.unreadCount?[userData!.id!] ?? 0;

    // Use ChatProvider's time formatting method
    final formattedTime = chatProvider.getChatTimeFormatted(chatRoom);

    // Check if other participant is online
    final isOtherUserOnline = otherParticipant?.isOnline ?? false;

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          final chatUser = ChatUser(
            id: otherParticipant?.id ?? "",
            name: otherParticipant?.fullName ?? "Unknown",
            avatarUrl: avatarUrl,
            isOnline: isOtherUserOnline,
          );

          chatProvider.markAsRead(chatRoom.id ?? "");

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
                // Show green circle only if other user is online
                Positioned(
                  right: 0,
                  bottom: 0,
                  child:
                  isOtherUserOnline
                      ? Container(
                    width: 14.pw,
                    height: 14.ph,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  )
                      : const SizedBox.shrink(),
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
                    // Show latest message or fallback text
                    chatRoom.latestMessage?.isNotEmpty == true
                        ? chatRoom.latestMessage!
                        : "Tap to view messages",
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
                  formattedTime, // Now shows Indian time via ChatProvider
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
