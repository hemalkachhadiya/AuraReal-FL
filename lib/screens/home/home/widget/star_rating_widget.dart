import 'package:flutter/material.dart';


class StarRatingWidget extends StatelessWidget {
  final double rating;
  final int totalStars;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool isInteractive;
  final Function(int)? onRatingChanged;
  final MainAxisAlignment alignment;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.totalStars = 5,
    this.size = 20.0,
    this.activeColor = const Color(0xFFFFD700),
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.isInteractive = false,
    this.onRatingChanged,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: List.generate(totalStars, (index) {
        return GestureDetector(
          onTap: isInteractive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              index < rating.floor()
                  ? Icons.star
                  : index < rating
                  ? Icons.star_half
                  : Icons.star_border,
              size: size,
              color: index < rating ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;
  final int totalStars;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const InteractiveStarRating({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
    this.totalStars = 5,
    this.size = 24.0,
    this.activeColor = const Color(0xFFFFD700),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.totalStars, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: AnimatedScale(
            scale: _currentRating > index ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(
              _currentRating > index ? Icons.star : Icons.star_border,
              size: widget.size,
              color: _currentRating > index ? widget.activeColor : widget.inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}