
part of 'multi_pull.dart';

abstract class CircleIndicator implements Widget {
  CircleIndicator();
}


class DefaultCircle extends StatelessWidget implements CircleIndicator {
  const DefaultCircle({this.circleColor = Colors.grey, this.circleOpacity = 0.3, this.radius = 35});
  
  final double circleOpacity;

  final Color circleColor;

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: circleColor.withOpacity(circleOpacity),
      ),
    );
  }
}


class ArrowIndicator extends StatelessWidget implements CircleIndicator {
  ArrowIndicator({this.size, this.alignment, this.color});

  final double? size;

  final Alignment? alignment;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _indicatorSize + 15,
      height: _indicatorSize + 15,
      child: Align(
        alignment: alignment ?? Alignment.bottomCenter,
        child: Icon(
          Icons.arrow_upward_rounded,
          color: color ?? Theme.of(context).accentColor,
          size: size,
        ),
      ),
    );
  }
}