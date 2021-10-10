part of 'multi_pull.dart';

/// Pull Indicator can alternate RefreshIndicator on MultiPull
/// you can set this as one of List<PullIndicator> property 'pullIndicators' of MultiPull
/// user pull down a ListView what MultiPull setted, its shown horizontal arranged Pull Indicators.
/// and when continue scroll vertical and horizontal, choose "what i pull choose"
/// then user took off from screen, MultiPull call the PullIndicator's onPull

abstract class PullIndicator implements Widget {
  PullIndicator(this.onPull);

  final FutureOr<void> Function() onPull;
}

class DefaultPullIndicator extends StatelessWidget implements PullIndicator {
  const DefaultPullIndicator({
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
          width: _indicatorSize - 30,
          height: _indicatorSize - 30,
          child: icon,
        ),
        if (_label != null) //
          _label,
      ],
    );
  }
}

class LabelPullIndicator extends StatelessWidget implements PullIndicator {
  const LabelPullIndicator({
    required this.onPull,
    required this.label,
    this.labelStyle = const TextStyle(),
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final String label;
  final TextStyle labelStyle;
  final FutureOr<void> Function() onPull;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: TextStyle(fontFamily: DefaultTextStyle.of(context).style.fontFamily),
      ),
    );
  }
}
