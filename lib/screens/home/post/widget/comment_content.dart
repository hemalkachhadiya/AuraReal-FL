import 'package:aura_real/aura_real.dart';

class CommentsWidget extends StatefulWidget {
  final PostModel post;
  final List<CommentModel>? comments;
  final Function(String)? onCommentSubmitted;

  const CommentsWidget({
    super.key,
    required this.post,
    this.comments,
    this.onCommentSubmitted,
  });

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode(); // Added FocusNode
  CommentModel? _replyToComment;
  final Set<String?> _repliedCommentIds =
      <String?>{}; // Track replied comment IDs

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  // Function to hide keyboard
  void _hideKeyboard() {
    FocusScope.of(navigatorKey.currentContext!).unfocus();
  }

  // Function to show keyboard and focus on TextField
  void _showKeyboard() {
    FocusScope.of(navigatorKey.currentContext!).requestFocus(_commentFocusNode);
  }

  // Recursive function to check if any reply exists in the subtree with null safety
  bool hasAnyReply(CommentModel? comment) {
    if (comment == null) return false;
    if (comment.replies.isNotEmpty) return true;
    for (var reply in comment.replies) {
      if (hasAnyReply(reply)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            decoration: BoxDecoration(
              color: ColorRes.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Image
                InkWell(
                  onTap: () {
                    context.navigator.pushNamed(
                      UploadScreen.routeName,
                      arguments: widget.post.userId?.id,
                    );
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedImage(
                      (widget.post.userId != null &&
                              widget.post.userId?.profile != null &&
                              widget.post.userId?.profile?.profileImage != null)
                          ? EndPoints.domain +
                              widget.post.userId!.profile!.profileImage!
                                  .toString()
                          : "",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Divider(color: Colors.grey, height: 1),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          context.navigator.pushNamed(
                            UploadScreen.routeName,
                            arguments: widget.post.userId?.id,
                          );
                        },
                        child: Text(
                          widget.post.userId?.fullName ?? "Unknown User",
                          style: styleW600S14.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          context.navigator.pushNamed(
                            UploadScreen.routeName,
                            arguments: widget.post.userId?.id,
                          );
                        },
                        child: Text(
                          widget.post.userId?.email ?? "No email",
                          style: styleW400S12.copyWith(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Post Preview Image
                if (widget.post.postImage != null &&
                    widget.post.postImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImage(
                      EndPoints.domain +
                          widget.post.postImage!.toBackslashPath(),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),

          ///Divider
          const Divider(color: Colors.grey, height: 1),
          // Comments list with scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children:
                    (widget.comments ?? []).map((comment) {
                      // Check if the parent comment has a direct reply
                      bool hasDirectReply = _repliedCommentIds.contains(
                        comment.id,
                      );

                      return CommentTile(
                        comment: comment,
                        onTapProfileImg: () {
                          context.navigator.pushNamed(
                            UploadScreen.routeName,
                            arguments: comment.userId?.id,
                          );
                        },
                        onReply: (c) {
                          setState(() {
                            _replyToComment = c;
                            _showKeyboard(); // Show keyboard on reply
                          });
                        },
                        hasReplied:
                            hasDirectReply, // Only consider direct replies to parent
                      );
                    }).toList(),
              ),
            ),
          ),

          // Persistent input field with keyboard padding
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade800, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // const CircleAvatar(
                  //   radius: 16,
                  //   backgroundColor: Colors.grey,
                  //   child: Icon(Icons.person, color: Colors.white, size: 16),
                  // ),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode, // Assign FocusNode
                      style: styleW400S12,
                      decoration: InputDecoration(
                        hintText:
                            _replyToComment != null
                                ? "Replying to ${_replyToComment!.userId?.fullName ?? 'user'}"
                                : context.l10n?.whatDoYouThink ?? "",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: ColorRes.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: ColorRes.lightGrey2,
                      ),
                    ),
                  ),
                  8.pw.spaceHorizontal,
                  IconButton(
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) return;
                      final text = _commentController.text.trim();

                      final provider = context.read<PostsProvider>();

                      // Call API to post comment
                      await provider.commentPostAPI(
                        context,
                        postId: widget.post.id,
                        content: text,
                        parentCommentId: _replyToComment?.id,
                      );

                      // Update replied state if it's a reply
                      if (_replyToComment?.id != null) {
                        setState(() {
                          _repliedCommentIds.add(
                            _replyToComment!.id,
                          ); // Mark as replied
                        });
                      }

                      // Clear text field and hide keyboard
                      _commentController.clear();
                      _hideKeyboard();
                      setState(() {
                        _replyToComment = null; // Reset reply state
                      });

                      // Notify parent if needed
                      widget.onCommentSubmitted?.call(text);
                    },
                    icon: const Icon(Icons.send, color: ColorRes.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Updated CommentTile widget
class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final Function(CommentModel) onReply;
  final int depth;
  final bool hasReplied; // New parameter to check if a reply exists
  final VoidCallback onTapProfileImg;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onReply,
    this.depth = 0,
    required this.hasReplied,
    required this.onTapProfileImg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0 + (depth * 0),
        right: 16,
        top: 8 + (depth * 4),
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          // CircleAvatar(
          //   radius: 16,
          //   backgroundColor:
          //       comment.userId != null ? ColorRes.primaryColor : Colors.grey,
          //   child: const Icon(Icons.person, color: Colors.white, size: 16),
          // ),
          InkWell(
            onTap: onTapProfileImg,
            child: Container(
              width: 45.pw,
              height: 45.ph,
              child: CachedImage(
                borderRadius: 50,
                "${EndPoints.domain}${comment.userId!.profile?.profileImage?.toBackslashPath()}",
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User + Time
                Row(
                  children: [
                    InkWell(
                      onTap: onTapProfileImg,
                      child: Text(
                        comment.userId?.fullName ?? "Unknown",
                        style: styleW600S14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.createdAt != null
                          ? _formatTimeAgo(comment.createdAt!)
                          : "now",
                      style: styleW400S12.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(comment.content ?? "", style: styleW500S14),
                const SizedBox(height: 6),

                // Actions: Like + Reply
                Row(
                  children: [
                    // Only show "Reply" for parent comments (depth = 0) and if no direct reply exists
                    if (depth == 0)
                      GestureDetector(
                        onTap: () => onReply(comment),
                        child: Text(
                          context.l10n?.reply ?? "Reply",
                          style: styleW400S12.copyWith(
                            color: ColorRes.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                // Nested replies with null safety
                if (comment.replies.isNotEmpty)
                  Column(
                    children:
                        (comment.replies)
                            .map(
                              (reply) => CommentTile(
                                onTapProfileImg: onTapProfileImg,
                                comment: reply,
                                onReply: onReply,
                                depth: depth + 1,
                                hasReplied: hasReplied,
                              ),
                            )
                            .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) return "${difference.inDays}d";
    if (difference.inHours > 0) return "${difference.inHours}h";
    if (difference.inMinutes > 0) return "${difference.inMinutes}m";
    return "now";
  }
}
