import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/home/home/model/post_model.dart';
import 'package:flutter/material.dart';

class PostsProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get posts => _posts;

  bool get isLoading => _isLoading;

  String? get error => _error;

  PostsProvider() {
    _initializeDummyData();
  }

  void _initializeDummyData() {
    _posts = [
      PostModel(
        id: '1',
        userName: 'Paityn Dorwart',
        userProfileImage:
            'https://images.unsplash.com/photo-1494790108755-2616b612b589?w=100&h=100&fit=crop&crop=face',
        postImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop',
        rating: 5.0,
        totalRatings: 124,
        imageSize: '480 x 390',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        userRating: 0,
      ),
      PostModel(
        id: '2',
        userName: 'Alena Lubin',
        userProfileImage:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
        postImage:
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=600&fit=crop',
        rating: 4.8,
        totalRatings: 98,
        imageSize: '640 x 480',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        userRating: 0,
      ),
      PostModel(
        id: '3',
        userName: 'John Smith',
        userProfileImage:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
        postImage:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop',
        rating: 4.5,
        totalRatings: 156,
        imageSize: '720 x 540',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        userRating: 0,
      ),
      PostModel(
        id: '4',
        userName: 'Emma Johnson',
        userProfileImage:
            'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=100&h=100&fit=crop&crop=face',
        postImage:
            'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=600&fit=crop',
        rating: 4.9,
        totalRatings: 203,
        imageSize: '800 x 600',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        userRating: 0,
      ),
    ];
  }

  // Rate a post
  void ratePost(String postId, int rating) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];

      // Calculate new average rating
      double newRating;
      int newTotalRatings;

      if (post.userRating == 0) {
        // First time rating
        newTotalRatings = post.totalRatings + 1;
        newRating =
            ((post.rating * post.totalRatings) + rating) / newTotalRatings;
      } else {
        // Update existing rating
        newTotalRatings = post.totalRatings;
        newRating =
            ((post.rating * post.totalRatings) - post.userRating + rating) /
            newTotalRatings;
      }

      _posts[postIndex] = post.copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        totalRatings: newTotalRatings,
        userRating: rating,
      );

      notifyListeners();
    }
  }

  // Load posts (simulate API call)
  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In real app, you would make API call here
      // _posts = await ApiService.getPosts();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new post
  void addPost(PostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  // Remove post
  void removePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  // Get post by ID
  PostModel? getPostById(String postId) {
    try {
      return _posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  // Clear all posts
  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}
