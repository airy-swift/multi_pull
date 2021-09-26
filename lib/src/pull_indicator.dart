
part of 'multi_pull.dart';

/// Pull Indicator can alternate RefreshIndicator on MultiPull
/// you can set this as one of List<PullIndicator> property 'pullIndicators' of MultiPull
/// user pull down a ListView what MultiPull setted, its shown horizontal arranged Pull Indicators.
/// and when continue scroll vertical and horizontal, choose "what i pull choose"
/// then user took off from screen, MultiPull call the PullIndicator's onPull
class PullIndicator extends StatelessWidget {
  const PullIndicator({
    required this.icon,
    required this.onPull,
    this.label,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final Widget icon;
  final Widget? label;
  final FutureOr<void> Function() onPull;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final _label = label;

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _actionSize - 30,
          height: _actionSize - 30,
          child: icon,
        ),
        if (_label != null) //
          _label,
      ],
    );
  }
}
