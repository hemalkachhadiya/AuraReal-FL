import 'package:aura_real/aura_real.dart';

class UserProfileRatingWidget extends StatelessWidget {
  final RatingProfileUserModel? user; // ✅ Pass only the model
  final VoidCallback? onRate;
  final VoidCallback? onVisitProfile;
  final VoidCallback? onPrivateChat;
  final VoidCallback? onRateAPITap;

  const UserProfileRatingWidget({
    super.key,
    this.user,
    this.onRate,
    this.onVisitProfile,
    this.onPrivateChat,
    this.onRateAPITap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Info & Rating
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    print("Check oprn rate---------");
                    openCustomDialog(
                      context,
                      borderRadius: 30,
                      title: context.l10n?.sendRating ?? "Send Rating",
                      customChild: StarRatingWidget(
                        rating: user?.ratingsAverage ?? 0.0,
                        activeColor: ColorRes.primaryColor,
                        inactiveColor: ColorRes.primaryColor,
                        size: 37,
                      ),
                      confirmBtnTitle: context.l10n?.send ?? "Send",
                      onConfirmTap: onRateAPITap,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorRes.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Unknown",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: styleW700S20.copyWith(
                            color: ColorRes.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 9),

                        // Rating Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "(${(user?.ratingsAverage ?? 0).toStringAsFixed(2)}/10)",
                              style: styleW700S10.copyWith(
                                color: ColorRes.primaryColor,
                              ),
                            ),
                            6.pw.spaceHorizontal,
                            StarRatingWidget(
                              rating:
                                  (user?.ratingsAverage ?? 0.0).toStarRating(),
                              size: 10,
                              space: 8,
                              activeColor: ColorRes.yellowColor,
                              inactiveColor: ColorRes.yellowColor,
                            ),
                            6.pw.spaceHorizontal,
                            Text(
                              "${user?.ratingsAverage.toStringAsFixed(2)}",
                              style: styleW700S10.copyWith(
                                color: ColorRes.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Rate Button
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 80,
                            child: SubmitButton(
                              title: context.l10n?.rate ?? "Rate",
                              height: 28,
                              style: styleW500S12.copyWith(
                                color: ColorRes.white,
                              ),
                              onTap: onRate,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              15.pw.spaceHorizontal,

              // Action Buttons
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: SubmitButton2(
                        raduis: 15,
                        height: 45,
                        title: context.l10n?.profileVisit ?? "Visit Profile",
                        onTap: onVisitProfile,
                        icon: AssetRes.userIcon2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 120,
                      child: SubmitButton2(
                        height: 45,
                        raduis: 15,
                        title: context.l10n?.privateChat ?? "Private Chat",
                        onTap: onPrivateChat,
                        icon: AssetRes.msgIcon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
