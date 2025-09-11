import 'package:aura_real/aura_real.dart';

class RatingService {
  static const Map<int, double> _starValues = {
    1: 0.02,
    2: 0.04,
    3: 0.06,
    4: 0.08,
    5: 0.10,
  };
  final List<int> _ratings = [5]; // Initialize with 5 stars

  void updateRating(int index, int stars) {
    if (index < _ratings.length && stars >= 1 && stars <= 5) {
      _ratings[index] = stars;
    }
  }

  void addRating(int stars) {
    if (stars >= 1 && stars <= 5) {
      _ratings.add(stars);
    }
  }

  double getTotalRating() {
    return _ratings.fold(0.0, (total, stars) => total + _starValues[stars]!);
  }

  String getRatingDisplay(int index) {
    return '⭐' *
        (_ratings.isNotEmpty && index < _ratings.length ? _ratings[index] : 5);
  }
}

class Rating2Screen extends StatefulWidget {
  const Rating2Screen({super.key});

  @override
  State<Rating2Screen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<Rating2Screen> {
  final RatingService _ratingService = RatingService();

  void _showRatingDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Rating'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => _buildStarOption(context, i + 1, index),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildStarOption(BuildContext context, int stars, int index) {
    return ListTile(
      title: Text('⭐' * stars),
      onTap: () {
        setState(() {
          if (index < _ratingService._ratings.length) {
            _ratingService.updateRating(index, stars);
          } else {
            _ratingService.addRating(stars);
          }
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.ph,
      width: double.infinity,
      child: Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showRatingDialog(context, 0),
                  child: Text(
                    _ratingService.getRatingDisplay(0),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Total Rating: ${_ratingService.getTotalRating().toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      () => _showRatingDialog(
                        context,
                        _ratingService._ratings.length,
                      ),
                  child: const Text('Add New Rating'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
