import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart'; // Assuming you have this package

class CommentsWidget extends StatefulWidget {
  final PostModel post;
  final Function(String)? onCommentSubmitted;

  const CommentsWidget({
    super.key,
    required this.post,
    this.onCommentSubmitted,
  });

  @override
  State<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [
    Comment(
      id: '1',
      username: 'dev_chandresh_jobanjputra729',
      content: 'Price',
      timeAgo: '1w',
    ),
    Comment(
      id: '2',
      username: 'axcorporationsurat',
      content:
          'Savy_chandresh_jobanjputra729 instagram k bio main whats app group ka link hai aap waha se group join karlo group main detail ayegi ya whats app main 9033763827',
      timeAgo: '7d',
      isAuthor: true,
    ),
    Comment(id: '3', username: 'khan.978', content: 'Price', timeAgo: '1d'),
    Comment(
      id: '4',
      username: 'axcorporationsurat',
      content:
          '@khan.978 instagram k bio main whats app group ka link hai aap waha se group join karlo group main detail ayegi ya whats app main 9033763827',
      timeAgo: '4d',
      isAuthor: true,
    ),
    Comment(
      id: '5',
      username: 'mezbaan_pizza_',
      content: 'Location?',
      timeAgo: '5d',
    ),
    Comment(
      id: '6',
      username: 'axcorporationsurat',
      content:
          '@mezbaan_pizza_ instagram k bio main whats app group ka link hai aap waha se group join karlo group main detail ayegi ya whats app main 9033763827',
      timeAgo: '4d',
      isAuthor: true,
    ),
  ];

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

          const Divider(color: Colors.grey, height: 1),

          // Comments list
          Expanded(
            child: CustomListView(
              itemCount: _comments.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return CommentTile(comment: comment);
              },
            ),
          ),
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // color: const Color(0xFF1C1C1E),
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
                  onPressed: _addComment,
                  icon: const Icon(Icons.send, color: ColorRes.primaryColor),
                ),
              ],
            ),
          ),
          24.ph.spaceVertical,
        ],
      ),
    );
  }

  Widget _buildReactionButton(String emoji) {
    return GestureDetector(
      onTap: () {
        // Handle reaction tap
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.add(
        Comment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          username: 'current_user',
          content: _commentController.text.trim(),
          timeAgo: 'now',
        ),
      );
    });

    // Notify parent widget about the new comment
    if (widget.onCommentSubmitted != null) {
      widget.onCommentSubmitted!(_commentController.text.trim());
    }
    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// Individual comment tile widget
class CommentTile extends StatelessWidget {
  final Comment comment;

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
                comment.isAuthor ? ColorRes.primaryColor : Colors.grey,
            child:
                comment.avatarUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        comment.avatarUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Icon(Icons.person, color: Colors.white, size: 16),
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
                        comment.username,
                        style: styleW600S14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(comment.timeAgo, style: styleW500S12),
                    if (comment.isAuthor) ...[
                      ///Author Role
                      // const SizedBox(width: 4),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 6,
                      //     vertical: 2,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.orange,
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: const Text(
                      //     'Author',
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 10,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: styleW500S14),
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

          ///Favourite
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     Icons.favorite_border,
          //     color: Colors.grey.shade500,
          //     size: 20,
          //   ),
          // ),
        ],
      ),
    );
  }
}
