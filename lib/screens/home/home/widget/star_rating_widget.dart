import 'package:aura_real/aura_real.dart';

class StarRatingWidget extends StatefulWidget {
  final double rating;
  final double space;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<double>? onRatingChanged;

  const StarRatingWidget({
    super.key,
    this.rating = 0.0,
    this.size = 20.0,
    this.space = 12.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.onRatingChanged,
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
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: widget.space,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return InkWell(
          onTap:
              (widget.onRatingChanged != null)
                  ? () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                    if (widget.onRatingChanged != null) {
                      widget.onRatingChanged!(_rating);
                    }
                  }
                  : null,
          child: SvgAsset(
            imagePath:
                index < _rating.floor()
                    ? AssetRes.starFillIcon
                    : index < _rating
                    ? AssetRes.halfStarIcon
                    : AssetRes.starUnFillIcon,
            width: widget.size,
            height: widget.size,

            color:
                index < _rating
                    ? null
                    : index < _rating
                    ? widget.activeColor
                    : widget.inactiveColor,
          ),
        ) /*IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating ? widget.activeColor : widget.inactiveColor,
            size: widget.size,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
            if (widget.onRatingChanged != null) {
              widget.onRatingChanged!(_rating);
            }
          },
        )*/;
      }),
    );
  }
}
