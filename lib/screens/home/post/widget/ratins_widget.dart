import 'package:aura_real/aura_real.dart';

Future<double?> showRatingDialog(
  BuildContext context,
  double postRating, {
  VoidCallback? onSubmit,
  bool? loading,
  bool? isProfile = false,
}) async {
  double selectedRating =
      postRating.toStarRating() ; // Initialize with star rating (0–5)

  final result = await showDialog<double?>(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setDialogState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(null),
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: ColorRes.red,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: ColorRes.white,
                              size: 15,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    Text(
                      isProfile!
                          ? context.l10n?.rateThisProfile ?? "Rate this profile"
                          : context.l10n?.rateThisPost ?? "Rate this post",
                      style: styleW700S24.copyWith(
                        color: ColorRes.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((postRating) > 0) ...[
                        Text(
                          "Current Rating: ${postRating.toStringAsFixed(2)}",
                          // Display raw rating
                          style: styleW400S14.copyWith(color: ColorRes.grey),
                        ),
                        const SizedBox(height: 15),
                      ],
                      const SizedBox(height: 20),
                      StarRatingWidget(
                        rating: selectedRating,
                        // Use star rating (0–5)
                        size: 30.0,
                        activeColor: ColorRes.primaryColor,
                        inactiveColor: ColorRes.primaryColor.withValues(
                          alpha: 0.3,
                        ),
                        onRatingChanged: (rating) {
                          setDialogState(() {
                            selectedRating = rating; // Update star rating
                          });
                          if (kDebugMode) {
                            print(
                              'Rating changed to: $rating (stars), ${rating.toRawRating()} (raw)',
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      if (selectedRating > 0) ...[
                        Text(
                          'Selected: ${selectedRating.toRawRating().toStringAsFixed(2)}', // Display raw rating
                          style: styleW500S14.copyWith(
                            color: ColorRes.primaryColor,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Tap stars to rate',
                          style: styleW400S13.copyWith(color: ColorRes.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  Center(
                    child: Container(
                      width: 225.pw,
                      padding: EdgeInsets.only(top: 15.ph),
                      child: SubmitButton(
                        height: 45.ph,
                        loading: loading ?? false,
                        raduis: 15,
                        onTap:
                            loading == true || selectedRating == 0
                                ? null
                                : () {
                                  if (kDebugMode) {
                                    print(
                                      'Submit tapped! Rating: $selectedRating (stars), ${selectedRating.toRawRating()} (raw)',
                                    );
                                  }
                                  Navigator.of(
                                    context,
                                  ).pop(selectedRating); // Return star rating
                                  if (onSubmit != null) {
                                    if (kDebugMode) print('OnSubmit executed');
                                    onSubmit();
                                  }
                                },
                        title:
                            (postRating) > 0
                                ? (context.l10n?.update ?? "Update")
                                : (context.l10n?.submit ?? "Submit"),
                        style: styleW600S12.copyWith(color: ColorRes.white),
                      ),
                    ),
                  ),
                ],
              ),
        ),
  );

  if (kDebugMode)
    print(
      'Dialog closed with rating: $result (stars), ${result?.toRawRating()} (raw)',
    );
  return result; // Return star rating (0–5)
}
