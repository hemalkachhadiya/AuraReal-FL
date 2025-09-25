import 'package:aura_real/aura_real.dart';

class CommentBottomSheetContent extends StatefulWidget {
  final PostModel post;
  final Function(String)? onCommentSubmitted;

  const CommentBottomSheetContent({
    super.key,
    required this.post,
    this.onCommentSubmitted,
  });

  @override
  _CommentBottomSheetContentState createState() =>
      _CommentBottomSheetContentState();
}

class _CommentBottomSheetContentState extends State<CommentBottomSheetContent> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(
        navigatorKey.currentState!.context,
      ).requestFocus(FocusNode());
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isTextFieldFocused = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment(BuildContext context) async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Pass the comment text to the callback
      if (widget.onCommentSubmitted != null) {
        widget.onCommentSubmitted!(_commentController.text.trim());
      }

      Navigator.of(context).pop();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment. Please try again.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCommentText = _commentController.text.trim().isNotEmpty;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside the text field
        FocusScope.of(context).unfocus();
        setState(() {
          _isTextFieldFocused = false;
        });
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        // padding: EdgeInsets.only(bottom: Constants.horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalPadding,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorRes.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    context.l10n?.addComment ?? "Add Comment",
                    style: styleW700S18.copyWith(color: ColorRes.primaryColor),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom > 0
                          ? 0
                          : 0, // Add padding when keyboard is visible
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Post Preview
                    Container(
                      padding: EdgeInsets.all(Constants.horizontalPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorRes.primaryColor.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedImage(
                                _getProfileImageUrl(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.userId?.fullName ?? "Unknown",
                                  style: styleW600S14.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                if (widget.post.content?.isNotEmpty == true)
                                  Text(
                                    widget.post.content!,
                                    style: styleW400S12.copyWith(
                                      color: ColorRes.grey,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Post Image
                          if (widget.post.postImage?.isNotEmpty == true)
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ColorRes.grey.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedImage(
                                  "${EndPoints.domain}${widget.post.postImage.toString()}",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, thickness: 1),

                    // Comment Input Section
                    Padding(
                      padding: EdgeInsets.all(Constants.horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            context.l10n?.writeComment ?? "Your comment",
                            style: styleW600S14.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  _isTextFieldFocused
                                      ? Colors.white
                                      : Colors.grey.shade50,
                              border: Border.all(
                                color:
                                    _isTextFieldFocused
                                        ? ColorRes.primaryColor.withValues(alpha: 0.4)
                                        : ColorRes.grey.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow:
                                  _isTextFieldFocused
                                      ? [
                                        BoxShadow(
                                          color: ColorRes.primaryColor
                                              .withValues(alpha: 0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: TextField(
                              controller: _commentController,
                              maxLines: 5,
                              minLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    context.l10n?.typeYourComment ??
                                    "Share your thoughts...",
                                hintStyle: styleW400S14.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                              onTap: () {
                                setState(() {
                                  _isTextFieldFocused = true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Character count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${_commentController.text.length}/280',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _commentController.text.length > 280
                                          ? Colors.red
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button (always visible but positioned properly)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalPadding,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child:
                    isKeyboardOpen
                        ? null
                        : ElevatedButton(
                          onPressed:
                              hasCommentText && !_isLoading
                                  ? () => _submitComment(context)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorRes.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    context.l10n?.postComment ?? "Post Comment",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProfileImageUrl() {
    if (widget.post.userId?.profile?.profileImage == null) return '';
    final userId = widget.post.userId;
    if (userId == null || userId.runtimeType == String) return '';
    return EndPoints.domain + userId.profile!.profileImage.toString();
  }
}
