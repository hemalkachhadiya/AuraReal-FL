import 'dart:async';

import '../../../aura_real.dart';

class MessageScreen extends StatefulWidget {
  final ChatUser chatUser;

  const MessageScreen({super.key, required this.chatUser});

  static const routeName = "message_screen";

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isEmojiVisible = false;
  final FocusNode _focusNode = FocusNode();
  MessageProvider? _messageProvider;
  bool _isUserAtBottom = true;
  bool _hasScrolledToBottomOnInit = false; // Track if we've scrolled on init

  @override
  void initState() {
    super.initState();
    _initializeChat();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _isEmojiVisible) {
        setState(() {
          _isEmojiVisible = false;
        });
      }
    });
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;

    _messageProvider = Provider.of<MessageProvider>(
      navigatorKey.currentContext!,
      listen: false,
    );

    if (widget.chatUser.id == null || widget.chatUser.id!.isEmpty) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(const SnackBar(content: Text("Error: Invalid chat user")));
      Navigator.of(navigatorKey.currentContext!).pop();
      return;
    }

    await _messageProvider?.initializeChat(
      user: widget.chatUser,
      roomId: widget.chatUser.id!,
    );

    _messageProvider?.markAllAsRead();

    // Multiple attempts to ensure scrolling works
    _scrollToBottomWithDelay();
  }

  void _scrollToBottomWithDelay() {
    // Try immediately
    _scrollToBottom();

    // Try after a short delay
    Timer(const Duration(milliseconds: 100), _scrollToBottom);

    // Try after messages should be rendered
    Timer(const Duration(milliseconds: 500), _scrollToBottom);

    // Final attempt
    Timer(const Duration(seconds: 1), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        debugPrint(
          "📜 Scrolled to bottom: ${_scrollController.position.maxScrollExtent}",
        );
      }
    });
  }

  // Alternative method using jumpTo for immediate scrolling
  void _jumpToBottom() {
    if (!mounted || !_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        debugPrint(
          "📜 Jumped to bottom: ${_scrollController.position.maxScrollExtent}",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_isEmojiVisible) {
          setState(() {
            _isEmojiVisible = false;
          });
        }
      },
      child: Scaffold(
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

                  // Mark messages as read and scroll to bottom when messages load
                  if (messageProvider.messages.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      messageProvider.markAllAsRead();

                      // Scroll to bottom on first load or when new messages arrive
                      if (!_hasScrolledToBottomOnInit) {
                        _hasScrolledToBottomOnInit = true;
                        _jumpToBottom(); // Use jumpTo for immediate scroll on first load
                      } else if (_isUserAtBottom) {
                        _scrollToBottom(); // Smooth scroll for new messages
                      }
                    });
                  }

                  return _buildMessagesList(messageProvider);
                },
              ),
            ),
            Consumer<MessageProvider>(
              builder: (context, provider, _) {
                return provider.isTyping
                    ? _buildTypingIndicator()
                    : const SizedBox.shrink();
              },
            ),
            _buildMessageInput(context, keyboardHeight),
          ],
        ),
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
                    backgroundImage:
                        user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    backgroundColor: Colors.grey[300],
                    child:
                        user.avatarUrl == null || user.avatarUrl!.isEmpty
                            ? Text(
                              user.name?.substring(0, 1).toUpperCase() ?? "?",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            )
                            : null,
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
                      style: styleW700S20.copyWith(
                        color: ColorRes.primaryColor,
                      ),
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

  Widget _buildMessagesList(MessageProvider messageProvider) {
    debugPrint(
      "🔄 Rebuilding messages list with ${messageProvider.messages.length} messages",
    );

    if (messageProvider.messages.isEmpty) {
      return const Center(
        child: Text(
          "No messages yet. Start a conversation!",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return CustomListView(
      controller: _scrollController,
      itemCount: messageProvider.messages.length,
      separatorBuilder:
          (ctx, ind) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
      itemBuilder: (context, index) {
        final message = messageProvider.messages[index];
        final prevMessage =
            index > 0 ? messageProvider.messages[index - 1] : null;
        final showTimestamp =
            prevMessage == null ||
            message.timestamp.difference(prevMessage.timestamp).inMinutes > 5;

        // For the last message, ensure we scroll to bottom after it renders
        if (index == messageProvider.messages.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_isUserAtBottom && _hasScrolledToBottomOnInit) {
              _scrollToBottom();
            }
          });
        }

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
    // Convert timestamp to IST (UTC+5:30)
    final istTimestamp = timestamp.toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );

    final now = DateTime.now().toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      istTimestamp.year,
      istTimestamp.month,
      istTimestamp.day,
    );

    String dayString;
    if (messageDate == today) {
      dayString = "Today";
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dayString = "Yesterday";
    } else {
      dayString =
          "${istTimestamp.day}/${istTimestamp.month}/${istTimestamp.year}";
    }

    // Format hours and minutes in 24h or 12h format
    final hour = istTimestamp.hour % 12 == 0 ? 12 : istTimestamp.hour % 12;
    final minute = istTimestamp.minute.toString().padLeft(2, '0');
    final period = istTimestamp.hour >= 12 ? "PM" : "AM";

    return "$dayString, $hour:$minute $period";
  }

  Widget _buildMessageBubble(Message message, MessageProvider messageProvider) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: Constants.horizontalPadding,
      ),
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
                          color: messageProvider.getStatusColor(message.status),
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
        if (messageProvider.isTyping) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  child: Icon(Icons.more_horiz, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  "${messageProvider.currentUser?.name ?? "User"} is typing...",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[50],
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage:
                    widget.chatUser.avatarUrl != null &&
                            widget.chatUser.avatarUrl!.isNotEmpty
                        ? NetworkImage(widget.chatUser.avatarUrl!)
                        : null,
                backgroundColor: Colors.grey[300],
                child:
                    widget.chatUser.avatarUrl == null ||
                            widget.chatUser.avatarUrl!.isEmpty
                        ? Text(
                          widget.chatUser.name?.substring(0, 1).toUpperCase() ??
                              "?",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 6),
                    _buildTypingDot(200),
                    const SizedBox(width: 6),
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

  Widget _buildTypingDot(int index) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 600),
      curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, double keyboardHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                              FocusScope.of(context).unfocus();
                            } else {
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
                              context.read<MessageProvider>().updateMessageText(
                                text,
                              );
                              if (_isEmojiVisible) {
                                setState(() {
                                  _isEmojiVisible = false;
                                });
                              }
                              if (text.isNotEmpty) {
                                socketIoHelper.sendTyping(
                                  senderId: userData?.id ?? "",
                                  roomId: widget.chatUser.id ?? "",
                                );
                              } else {
                                socketIoHelper.stopTyping(
                                  senderId: userData?.id ?? "",
                                  roomId: widget.chatUser.id ?? "",
                                );
                              }
                            },
                            onSubmitted: (text) {
                              if (context
                                  .read<MessageProvider>()
                                  .canSendMessage) {
                                _sendMessage(context.read<MessageProvider>());
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
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction:
                                TextInputAction
                                    .send, // Indicates "send" action for Enter key
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            openFilePicker(context: context);
                          },
                          child: SvgAsset(
                            imagePath: AssetRes.attachIcon,
                            width: 18.pw,
                            height: 18.ph,
                          ),
                        ),
                        15.pw.spaceHorizontal,
                        InkWell(
                          onTap: () {
                            context.read<MessageProvider>().pickMedia();
                          },
                          child: SvgAsset(
                            imagePath: AssetRes.cameraIcon2,
                            width: 18.pw,
                            height: 18.ph,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, textValue, child) {
                    final hasText = textValue.text.trim().isNotEmpty;

                    return GestureDetector(
                      onTap:
                          hasText
                              ? () =>
                                  _sendMessage(context.read<MessageProvider>())
                              : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 53,
                        height: 53,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: hasText ? ColorRes.primaryColor : Colors.grey,
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

        if (_isEmojiVisible)
          Flexible(
            child: SizedBox(
              height: 350 - keyboardHeight,
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

  void _sendMessage(MessageProvider messageProvider) {
    if (!mounted) return;
    debugPrint("Sending message to receiverId: ${widget.chatUser.id}");
    messageProvider.sendMessage(receiverId: widget.chatUser.id ?? "");
    _messageController.clear();
    setState(() {
      _isUserAtBottom = true;
    });

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      FocusScope.of(navigatorKey.currentContext!).requestFocus(_focusNode);
    });
  }

  // ... rest of your existing methods remain the same
}
