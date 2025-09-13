import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/apis/model/comment_model.dart';
import 'package:aura_real/aura_real.dart';

class CommentsWidget extends StatefulWidget {
  final PostModel post;
  final List<CommentModel>? comments; // Accept dynamic comment list
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
                ClipRRect(
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
                const SizedBox(width: 16),
                const Divider(color: Colors.grey, height: 1),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userId?.fullName ?? "Unknown User",
                        style: styleW600S14.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.post.userId?.email ?? "No email",
                        style: styleW400S12.copyWith(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          const Divider(color: Colors.grey, height: 1),
          // Comments list with scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    (widget.comments ?? []).map((comment) {
                      return CommentTile(comment: comment);
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
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: styleW400S12,
                      decoration: InputDecoration(
                        hintText: 'What do you think of this?',
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
                      if (widget.onCommentSubmitted != null) {
                        widget.onCommentSubmitted!(
                          _commentController.text.trim(),
                        );
                        _commentController.clear();
                        // No pop, just refresh
                        setState(() {}); // Trigger UI update
                      }
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// Individual comment tile widget (unchanged)
class CommentTile extends StatelessWidget {
  final CommentModel comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                comment.userId != null ? ColorRes.primaryColor : Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
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
                      style: styleW500S12,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content ?? "", style: styleW500S14),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text('Reply', style: styleW400S12),
                    ),
                    const SizedBox(width: 16),
                  ],
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
