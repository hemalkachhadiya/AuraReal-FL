import 'package:aura_real/aura_real.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String? imageUrl; // Made nullable
  final String? title;
  final List<String>? imageUrls; // For gallery view
  final int? initialIndex;

  const ImagePreviewScreen({
    Key? key,
    this.imageUrl, // Removed required since we'll handle null
    this.title,
    this.imageUrls,
    this.initialIndex,
  }) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Auto-hide app bar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _toggleAppBar();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<String> get _imageList {
    if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
      return widget.imageUrls!;
    }
    // Return empty list if imageUrl is null
    return widget.imageUrl != null ? [widget.imageUrl!] : [];
  }

  // Check if we have valid image data
  bool get _hasValidImage {
    return widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Show empty widget if no valid image
    if (!_hasValidImage &&
        (widget.imageUrls == null || widget.imageUrls!.isEmpty)) {
      return _buildEmptyWidget();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar:
          _showAppBar
              ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title:
                    widget.title != null && widget.title!.isNotEmpty
                        ? Text(
                          widget.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                        : null,
                centerTitle: true,
                actions: [
                  if (_imageList.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${_imageList.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
              : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: _toggleAppBar,
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (!_hasValidImage) {
      return _buildEmptyImageWidget();
    }
    return _buildSingleImage();
  }

  Widget _buildSingleImage() {
    if (widget.imageUrl == null) {
      return _buildEmptyImageWidget();
    }

    return PhotoView(
      imageProvider: CachedNetworkImageProvider(widget.imageUrl!),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3.0,
      initialScale: PhotoViewComputedScale.contained,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.imageUrl!),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder:
          (context, event) => Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              value:
                  event == null
                      ? 0
                      : (event.expectedTotalBytes != null
                          ? event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!
                          : 0),
            ),
          ),
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildEmptyWidget() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed:
              () => Navigator.of(navigatorKey.currentState!.context).pop(),
        ),
      ),
      body: _buildEmptyImageWidget(),
    );
  }

  Widget _buildEmptyImageWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'No image available',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
