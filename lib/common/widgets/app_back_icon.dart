import 'package:aura_real/aura_real.dart';

class AppBackIcon extends StatelessWidget {
  final String? title;

  const AppBackIcon({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(45),
          onTap: () => context.navigator.pop(),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: ColorRes.grey5,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SvgAsset(
                imagePath: AssetRes.leftIcon,
                color: ColorRes.black,
                height: 10,
                width: 10,
              ),
            ),
          ),
        ),
        16.pw.spaceHorizontal,
        Text(
          title ?? context.l10n?.back ?? "",
          style: styleW400S17.copyWith(color: ColorRes.black),
        ),
      ],
    );
  }
}
