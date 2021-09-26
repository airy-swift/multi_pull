

part of 'multi_pull.dart';

/// TODO: write what is this
class PullIndicator extends StatelessWidget {
  const PullIndicator({
    required this.icon,
    required this.onPull,
    this.label,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final Widget icon;
  final String? label;
  final FutureOr<void> Function() onPull;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _actionSize - 30,
          height: _actionSize - 30,
          child: icon,
        ),
        if (label != null) //
          Text(label!),
      ],
    );
  }
}
