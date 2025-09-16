import 'package:aura_real/apis/model/post_model.dart';
import 'package:aura_real/aura_real.dart';

Future<double?> showRatingDialog(
  BuildContext context,
  PostModel post, {
  VoidCallback? onSubmit,
  bool? loading,
}) async {
  double selectedRating =
      (post.postRating ?? 0.0).toStarRating(); // Scale raw to 0-5 for display

  final result = await showDialog<double?>(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
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
                          // Cancel
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
                      context.l10n?.rateThisPost ?? "Rate this post",
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
                      const SizedBox(height: 20),
                      StarRatingWidget(
                        rating: selectedRating,
                        size: 30.0,
                        activeColor: ColorRes.primaryColor,
                        inactiveColor: ColorRes.primaryColor,
                        onRatingChanged: (rating) {
                          setDialogState(() {
                            selectedRating =
                                rating; // Update dialog state (now on 0-5 scale)
                          });
                          if (kDebugMode) {
                            print('Rating changed to: $rating');
                          }
                        },
                      ),
                      if (selectedRating == 0) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Please select a rating',
                          style: styleW400S13.copyWith(color: ColorRes.red),
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
                                ? null // Disable if loading or no rating
                                : () {
                                  if (kDebugMode) {
                                    print(
                                      'Submit button tapped! Display rating: $selectedRating',
                                    );
                                  }
                                  // Convert back to raw format before returning (e.g., 3.0 → 0.06)
                                  final rawRating =
                                      DoubleRatingExtension(
                                        selectedRating,
                                      ).toRawRating(); // e.g., 3.0 → 60.0
                                  if (kDebugMode) {
                                    print('Returning raw rating: $rawRating');
                                  }
                                  Navigator.of(context).pop(rawRating);
                                  if (onSubmit != null) {
                                    if (kDebugMode) {
                                      print('On Submit executed');
                                    }
                                    onSubmit();
                                  }
                                },
                        title: context.l10n?.submit ?? "Submit",
                        style: styleW600S12.copyWith(color: ColorRes.white),
                      ),
                    ),
                  ),
                ],
              ),
        ),
  );

  if (kDebugMode) {
    print('Dialog closed with raw rating: $result');
  }
  return result;
}
