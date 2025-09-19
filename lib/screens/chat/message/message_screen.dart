import 'package:aura_real/aura_real.dart';

class MessageScreen extends StatefulWidget {
  final ChatUser chatUser;

  const MessageScreen({super.key, required this.chatUser});

  static const routeName = "message_screen"; // Ensure this matches RouteManager

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // conectCocketFun() async {
  //   socketIoHelper.connectSocket("", setState);
  // }
  //
  // disconectCocketFun() async {
  //   socketIoHelper.disconnectSocket();
  // }
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _scrollToBottom();
  //   });
  // }
  //
  // @override
  // void dispose() {
  //   _messageController.dispose();
  //   _scrollController.dispose();
  //   conectCocketFun();
  //   super.dispose();
  // }
  @override
  void initState() {
    super.initState();
    conectCocketFun(); // ✅ connect when screen opens

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    disconectCocketFun(); // ✅ disconnect when leaving
    super.dispose();
  }

  conectCocketFun() async {
    socketIoHelper.connectSocket(
      userData?.id ?? "",
      roomId: widget.chatUser.id.toString(),
    );
  }

  disconectCocketFun() async {
    socketIoHelper.disconnectSocket();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                if (messageProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildMessagesList(messageProvider);
              },
            ),
          ),
          _buildTypingIndicator(),
          _buildMessageInput(
            context,
            roomId: widget.chatUser.id,
            receiveId: widget.chatUser.id,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: ColorRes.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorRes.primaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actionsPadding: EdgeInsets.zero,
      titleSpacing: 0,

      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.chatUser.avatarUrl ?? ""),
                backgroundColor: Colors.grey[300],
              ),
              // if (widget.chatUser.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
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
                  widget.chatUser.name ?? "",
                  style: styleW700S20.copyWith(color: ColorRes.primaryColor),
                ),
                Text(
                  widget.chatUser.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color:
                        !widget.chatUser.isOnline ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.videocam, color: Colors.blue),
      //     onPressed: () {},
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.call, color: Colors.blue),
      //     onPressed: () {},
      //   ),
      // ],
    );
  }

  Widget _buildMessagesList(MessageProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final msg = provider.messages[index];
        bool? isFromMe = msg.id==userData?.id;

        print("Message --- ${msg.id}");
        print("Login User id -- ${userData?.id}");
        print("isFromMe -- ${isFromMe}");

        return Align(
          alignment:
              msg.isFromMe
                  ? Alignment
                      .centerRight // ✅ Right side if I sent
                  : Alignment.centerLeft, // ✅ Left side if received
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: msg.isFromMe ? ColorRes.primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(12).copyWith(
                bottomRight:
                    msg.isFromMe
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                bottomLeft:
                    msg.isFromMe
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  msg.isFromMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    color: msg.isFromMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.formatMessageTime(msg.timestamp),
                      style: TextStyle(
                        color: msg.isFromMe ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                    if (msg.isFromMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        provider.getStatusIcon(msg.status),
                        color: provider.getStatusColor(msg.status),
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildMessagesList(MessageProvider messageProvider) {
  //
  //   return ListView.builder(
  //     controller: _scrollController,
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     itemCount: messageProvider.messages.length,
  //     itemBuilder: (context, index) {
  //       final message = messageProvider.messages[index];
  //       print("message from ${message.isFromMe}");
  //       final showTimestamp =
  //           index == 0 ||
  //           messageProvider.messages[index - 1].timestamp
  //                   .difference(message.timestamp)
  //                   .inMinutes >
  //               5;
  //
  //       return Column(
  //         children: [
  //           if (showTimestamp) _buildTimestamp(message.timestamp),
  //           _buildMessageBubble(message, messageProvider),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildTimestamp(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        _formatTimestamp(timestamp),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) return 'Today';
    if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  Widget _buildMessageBubble(Message message, MessageProvider messageProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 08),
      child: Row(
        mainAxisAlignment:
            message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isFromMe) const Spacer(),
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    message.isFromMe
                        ? ColorRes.primaryColor
                        : ColorRes.lightGrey4,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(message.isFromMe ? 16 : 0),
                  bottomRight: Radius.circular(message.isFromMe ? 0 : 16),
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                ),
                // borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: styleW400S16),
                  8.ph.spaceVertical,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        messageProvider.formatMessageTime(message.timestamp),
                        style: styleW500S12.copyWith(
                          color:
                              message.isFromMe
                                  ? Colors.white70
                                  : Colors.grey[600],
                        ) /*TextStyle(
                          color:
                              message.isFromMe
                                  ? Colors.white70
                                  : Colors.grey[600],
                          fontSize: 11,
                        )*/,
                      ),
                      if (message.isFromMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          messageProvider.getStatusIcon(message.status),
                          size: 12,
                          color:
                              messageProvider.getStatusColor(message.status) ==
                                      ColorRes.primaryColor
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!message.isFromMe) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (!messageProvider.isTyping) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(widget.chatUser.avatarUrl ?? ""),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ColorRes.lightGrey5,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    4.pw.spaceHorizontal,
                    _buildTypingDot(200),
                    4.pw.spaceHorizontal,
                    _buildTypingDot(400),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * (0.5 - (value - 0.5).abs()) * 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(
    BuildContext context, {
    String? roomId,
    String? receiveId,
  }) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(color: ColorRes.white),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: ColorRes.lightGrey2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    SvgAsset(
                      imagePath: AssetRes.smileIcon,
                      width: 18.pw,
                      height: 18.ph,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer<MessageProvider>(
                        builder: (context, messageProvider, child) {
                          return TextField(
                            controller: _messageController,
                            onChanged:
                                (text) =>
                                    messageProvider.updateMessageText(text),
                            onSubmitted:
                                (text) =>
                                    _sendMessage(messageProvider, receiveId),
                            decoration: InputDecoration(
                              hintText: context.l10n?.typeAMessage ?? "",
                              hintStyle: TextStyle(fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 05,
                                vertical: 05,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgAsset(
                      imagePath: AssetRes.attachIcon,
                      width: 18.pw,
                      height: 18.ph,
                    ),
                    const SizedBox(width: 8),
                    SvgAsset(
                      imagePath: AssetRes.cameraIcon2,
                      width: 18.pw,
                      height: 18.ph,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                return GestureDetector(
                  onTap:
                      messageProvider.canSendMessage
                          ? () => _sendMessage(messageProvider, receiveId)
                          : null,
                  child: Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: ColorRes.primaryColor,
                    ),
                    child: Center(
                      child: SvgAsset(
                        imagePath: AssetRes.voiceIcon,
                        color: ColorRes.white,
                        height: 28.ph,
                        width: 28.pw,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(MessageProvider messageProvider, String? receiveID) {
    messageProvider.sendMessage(
      // roomId: "68ca7d9c1a4757664c281b9d",
      receiverId: receiveID,
    ); // 👈 pass roomId
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
}
