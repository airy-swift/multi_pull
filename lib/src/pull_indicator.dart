

part of 'multi_pull.dart';

/// TODO: write what is this
class PullIndicator extends StatelessWidget {
  const PullIndicator({
    required this.icon,
    this.label,
    this.action,
    this.onRefresh,
    this.mainAxisAlignment = MainAxisAlignment.center,
  }) : assert((action != null) != (onRefresh != null));

  final Widget icon;
  final String? label;
  final Function? action;
  final RefreshCallback? onRefresh;
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
