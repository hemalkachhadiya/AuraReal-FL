import 'package:aura_real/aura_real.dart';
import 'package:video_player/video_player.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({super.key});

  static const routeName = "add_post_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<AddPostProvider>(
      create: (c) => AddPostProvider(),
      child: const AddPostScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPostProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 15,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: SubmitButton(
                loading: provider.loader,
                bgColor:
                    !provider.canPublish()
                        ? ColorRes.grey3
                        : ColorRes.primaryColor,
                onTap:
                    provider.canPublish()
                        ? () => provider.createPostAPI()
                        : null,
                title: context.l10n?.publish ?? "",
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                8.ph.spaceVertical,
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constants.horizontalPadding,
                  ),
                  child: AppBackIcon(title: context.l10n?.post ?? ""),
                ),
                34.ph.spaceVertical,
                // Main content area
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constants.horizontalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post composition area
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text input area
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.zero,
                                    child: AppTextField(
                                      controller: provider.textController,
                                      textInputType: TextInputType.multiline,
                                      hintText: "Write a Caption?",
                                      customPadding: const EdgeInsets.only(
                                        left: 10,
                                        right: 5,
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      maxLine: 6,
                                      minLine: 1,
                                      textInputAction: TextInputAction.newline,
                                      borderRadius: 5,
                                      fillColor: ColorRes.grey7,
                                      customBorder: InputBorder.none,
                                      textAlign: TextAlign.left,
                                      onChanged: (value) {
                                        // handle text change
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    onTap: () => provider.pickMedia(),
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      child:
                                          provider.selectedMedia != null
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child:
                                                      provider.videoController !=
                                                              null
                                                          ? VideoPlayer(
                                                            provider
                                                                .videoController!,
                                                          )
                                                          : Image.file(
                                                            provider
                                                                .selectedMedia!,
                                                            fit: BoxFit.cover,
                                                          ),
                                                ),
                                              )
                                              : Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    style: BorderStyle.solid,
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons
                                                        .add_to_photos_outlined,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        10.ph.spaceVertical,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...['hashtag', 'demo', 'test'].map((value) {
                              final isSelected = provider.selectedHashtags
                                  .contains(value);
                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => provider.toggleHashtag(value),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? ColorRes.primaryColor
                                              : Colors.grey.shade300,
                                      width: isSelected ? 1 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        isSelected
                                            ? ColorRes.primaryColor.withOpacity(
                                              0.1,
                                            )
                                            : null,
                                  ),
                                  child: Text("#$value", style: styleW500S10),
                                ),
                              );
                            }),
                          ],
                        ),
                        16.ph.spaceVertical,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
