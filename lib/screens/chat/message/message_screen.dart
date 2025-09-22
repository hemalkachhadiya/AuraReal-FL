import 'package:aura_real/aura_real.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';

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

  bool _isEmojiVisible = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    connectSocketFun(); // ✅ connect when screen opens

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _isEmojiVisible) {
        setState(() {
          _isEmojiVisible = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    disconnectSocketFun(); // ✅ disconnect when leaving
    super.dispose();
  }

  connectSocketFun() async {
    socketIoHelper.connectSocket(widget.chatUser.id ?? "");
  }

  disconnectSocketFun() async {
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
                // Scroll to bottom whenever messages update
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return _buildMessagesList(messageProvider);
              },
            ),
          ),
          _buildTypingIndicator(),
          _buildMessageInput(context),
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
      title: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          final user = messageProvider.currentUser ?? widget.chatUser;
          return Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(user.avatarUrl ?? ""),
                    backgroundColor: Colors.grey[300],
                  ),
                  if (user.isOnline)
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
                      user.name ?? "",
                      style: styleW700S20.copyWith(color: ColorRes.primaryColor),
                    ),
                    Text(
                      user.isOnline ? "Online" : "Offline",
                      style: TextStyle(
                        color: user.isOnline ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // AppBar _buildAppBar(BuildContext context) {
  //   return AppBar(
  //     backgroundColor: Colors.white,
  //     surfaceTintColor: ColorRes.white,
  //     elevation: 0,
  //     leading: Padding(
  //       padding: const EdgeInsets.all(0),
  //       child: IconButton(
  //         icon: const Icon(
  //           Icons.arrow_back_ios,
  //           color: ColorRes.primaryColor,
  //           size: 20,
  //         ),
  //         onPressed: () => Navigator.of(context).pop(),
  //       ),
  //     ),
  //     actionsPadding: EdgeInsets.zero,
  //     titleSpacing: 0,
  //
  //     title: Row(
  //       children: [
  //         Stack(
  //           children: [
  //             CircleAvatar(
  //               radius: 20,
  //               backgroundImage: NetworkImage(widget.chatUser.avatarUrl ?? ""),
  //               backgroundColor: Colors.grey[300],
  //             ),
  //             // if (widget.chatUser.isOnline)
  //             Positioned(
  //               right: 0,
  //               bottom: 0,
  //               child: Container(
  //                 width: 14,
  //                 height: 14,
  //                 decoration: BoxDecoration(
  //                   color: Colors.green,
  //                   shape: BoxShape.circle,
  //                   border: Border.all(color: Colors.white, width: 2),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 widget.chatUser.name ?? "",
  //                 style: styleW700S20.copyWith(color: ColorRes.primaryColor),
  //               ),
  //               Text(
  //                 "Offline",
  //                 style: TextStyle(
  //                   color:
  //                       !widget.chatUser.isOnline ? Colors.green : Colors.grey,
  //                   fontSize: 12,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //     // actions: [
  //     //   IconButton(
  //     //     icon: const Icon(Icons.videocam, color: Colors.blue),
  //     //     onPressed: () {},
  //     //   ),
  //     //   IconButton(
  //     //     icon: const Icon(Icons.call, color: Colors.blue),
  //     //     onPressed: () {},
  //     //   ),
  //     // ],
  //   );
  // }

  Widget _buildMessagesList(MessageProvider messageProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messageProvider.messages.length,
      itemBuilder: (context, index) {
        final message = messageProvider.messages[index];
        // final showTimestamp =
        //     index == 0 ||
        //     message.timestamp
        //             .difference(messageProvider.messages[index - 1].timestamp)
        //             .inMinutes >
        //         5;
        final prevMessage =
            index > 0 ? messageProvider.messages[index - 1] : null;
        final showTimestamp =
            prevMessage == null ||
            message.timestamp.difference(prevMessage.timestamp).inMinutes > 5;

        return Column(
          children: [
            if (showTimestamp) _buildTimestamp(message.timestamp),
            _buildMessageBubble(message, messageProvider),
          ],
        );
      },
    );
  }

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
                        ? const Color(0xFF7C3AED)
                        : Colors.grey[100],
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
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isFromMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        messageProvider.formatMessageTime(message.timestamp),
                        style: TextStyle(
                          color:
                              message.isFromMe
                                  ? Colors.white70
                                  : Colors.grey[600],
                          fontSize: 11,
                        ),
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
                  color: Colors.grey[100],
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

  Widget _buildMessageInput(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ input bar
        SafeArea(
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isEmojiVisible = !_isEmojiVisible;
                            });

                            if (_isEmojiVisible) {
                              // Hide keyboard when emoji panel opens
                              FocusScope.of(context).unfocus();
                            } else {
                              // Show keyboard when emoji panel closes
                              FocusScope.of(context).requestFocus(_focusNode);
                            }
                          },
                          child: SvgAsset(
                            imagePath: AssetRes.smileIcon,
                            width: 18.pw,
                            height: 18.ph,
                          ),
                        ),

                        const SizedBox(width: 8),

                             Expanded(
                              child: TextField(
                                focusNode: _focusNode,
                                controller: _messageController,
                                onChanged: (text) {
                                  context
                                      .read<MessageProvider>()
                                      .updateMessageText(text);

                                  // hide emoji if typing starts
                                  if (_isEmojiVisible) {
                                    setState(() {
                                      _isEmojiVisible = false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Type a message...",
                                  border: InputBorder.none,
                                  hintStyle: styleW400S12,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 5,
                                  ),
                                ),
                                maxLines: null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            )
                            ,

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
                              ? () => _sendMessage(messageProvider)
                              : null,
                      child: Container(
                        width: 53,
                        height: 53,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: ColorRes.primaryColor,
                        ),
                        child: const Center(
                          child: Icon(Icons.send, color: ColorRes.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // ✅ emoji picker shown separately
        if (_isEmojiVisible)
          Flexible(
            child: SizedBox(
              height: 350,
              width: double.infinity,
              child: EmojiKeyboard(
                onEmojiChanged: (emoji) {
                  final newText = _messageController.text + emoji;
                  _messageController
                    ..text = newText
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: newText.length),
                    );
                  context.read<MessageProvider>().updateMessageText(newText);
                },
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildMessageInput(BuildContext context) {
  //   return SafeArea(
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: const BoxDecoration(color: ColorRes.white),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 15),
  //               decoration: BoxDecoration(
  //                 color: ColorRes.lightGrey2,
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: Row(
  //                 children: [
  //                   InkWell(
  //                     onTap: () {
  //                       setState(() {
  //                         _isEmojiVisible = !_isEmojiVisible;
  //                       });
  //                       if (_isEmojiVisible) {
  //                         FocusScope.of(context).unfocus(); // hide keyboard
  //                       } else {
  //                         FocusScope.of(context).requestFocus(_focusNode);
  //                       }
  //                     },
  //                     child: SvgAsset(
  //                       imagePath: AssetRes.smileIcon,
  //                       width: 18.pw,
  //                       height: 18.ph,
  //                     ),
  //                   ),
  //                   _isEmojiVisible
  //                       ? Expanded(
  //                         child: SizedBox(
  //                           width: double.infinity,
  //                           child: EmojiKeyboard(
  //                             onEmojiChanged: (emoji) {
  //                               final newText = _messageController.text + emoji;
  //                               _messageController
  //                                 ..text = newText
  //                                 ..selection = TextSelection.fromPosition(
  //                                   TextPosition(offset: newText.length),
  //                                 );
  //
  //                               // ✅ sync with provider
  //                               context
  //                                   .read<MessageProvider>()
  //                                   .updateMessageText(newText);
  //                             },
  //                           ),
  //                         ),
  //                       )
  //                       : const SizedBox.shrink(),
  //
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: Consumer<MessageProvider>(
  //                       builder: (context, messageProvider, child) {
  //                         return TextField(
  //                           focusNode: _focusNode,
  //                           controller: _messageController,
  //                           onChanged:
  //                               (text) =>
  //                                   messageProvider.updateMessageText(text),
  //                           onSubmitted:
  //                               (text) => _sendMessage(messageProvider),
  //                           decoration: InputDecoration(
  //                             hintText: context.l10n?.typeAMessage ?? "",
  //                             hintStyle: TextStyle(fontSize: 12),
  //                             border: InputBorder.none,
  //                             contentPadding: const EdgeInsets.symmetric(
  //                               horizontal: 05,
  //                               vertical: 05,
  //                             ),
  //                           ),
  //                           maxLines: null,
  //                           textCapitalization: TextCapitalization.sentences,
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   SvgAsset(
  //                     imagePath: AssetRes.attachIcon,
  //                     width: 18.pw,
  //                     height: 18.ph,
  //                   ),
  //                   const SizedBox(width: 8),
  //                   SvgAsset(
  //                     imagePath: AssetRes.cameraIcon2,
  //                     width: 18.pw,
  //                     height: 18.ph,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 14),
  //           Consumer<MessageProvider>(
  //             builder: (context, messageProvider, child) {
  //               return GestureDetector(
  //                 onTap:
  //                     messageProvider.canSendMessage
  //                         ? () => _sendMessage(messageProvider)
  //                         : null,
  //                 child: Container(
  //                   width: 53,
  //                   height: 53,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(28),
  //                     color: ColorRes.primaryColor,
  //                   ),
  //                   child: Center(
  //                     child: Icon(Icons.send, color: ColorRes.white) /*SvgAsset(
  //                       imagePath: AssetRes.voiceIcon,
  //                       color: ColorRes.white,
  //                       height: 28.ph,
  //                       width: 28.pw,
  //                     )*/,
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _sendMessage(MessageProvider messageProvider) {
    messageProvider.sendMessage(
      receiverId: widget.chatUser.id ?? "",
    ); // 👈 pass roomId
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
}
