import 'package:aura_real/aura_real.dart';

class StarRatingWidget extends StatefulWidget {
  final double rating;
  final double space;
  final double size;
  final Color? activeColor;
  final Color inactiveColor;
  final ValueChanged<double>? onRatingChanged;
  final bool cumulative; // NEW: whether tapping adds to current rating

  const StarRatingWidget({
    super.key,
    this.rating = 0.0,
    this.size = 20.0,
    this.space = 12.0,
    this.activeColor,
    this.inactiveColor = Colors.grey,
    this.onRatingChanged,
    this.cumulative = false,
  });

  @override
  _StarRatingWidgetState createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
    _rating = widget.rating.clamp(0.0, 5.0); // Clamp to valid range 0-5
    print("StarRatingWidget initState: rating = $_rating");
  }

  @override
  void didUpdateWidget(StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // CRITICAL: Update local rating when widget rating changes
    if (oldWidget.rating != widget.rating) {
      setState(() {
        _rating = widget.rating;
      });
      print(
        "StarRatingWidget didUpdateWidget: rating updated from ${oldWidget.rating} to ${widget.rating}",
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: widget.space,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        String starIcon;
        if (index < _rating.floor()) {
          starIcon = AssetRes.starFillIcon; // full star
        } else if (index < _rating) {
          starIcon = AssetRes.halfStarIcon; // half star
        } else {
          starIcon = AssetRes.starUnFillIcon; // empty star
        }

        Color starColor =
            index < _rating
                ? (widget.activeColor ?? Colors.amber)
                : widget.inactiveColor;

        return InkWell(
          onTap:
              widget.onRatingChanged != null
                  ? () {
                    setState(() {
                      double tappedStars = index + 1.0;
                      if (widget.cumulative) {
                        _rating = (_rating + tappedStars).clamp(0.0, 5.0);
                      } else {
                        _rating = tappedStars;
                      }
                    });
                    widget.onRatingChanged!(_rating);
                  }
                  : null,
          child: SvgAsset(
            imagePath: starIcon,
            width: widget.size,
            height: widget.size,
            color: starColor,
          ),
        );
      }),
    );
  }
}
