import 'dart:math';
import 'package:flutter/material.dart';
import 'plane_angle_radians.dart';

const double toRadians = 2.0 * pi;

double convertRadiusToSigma(double radius) {
  return radius * 0.57735 + 0.5;
}

class Thermostat extends StatefulWidget {
  final double radius;
  final Color glowColor;
  final Color tickColor;
  final Color thumbColor;
  final Color dividerColor;
  final Color turnOnColor;
  final bool turnOn;
  final Widget modeIcon;
  final int minValue;
  final int maxValue;
  final int initialValue;
  final ValueChanged<int>? onValueChanged;
  final TextStyle? textStyle;

  const Thermostat({
    super.key,
    required this.radius,
    this.glowColor = const Color(0xFF3F5BFA),
    this.tickColor = const Color(0xFFD5D9F0),
    this.thumbColor = const Color(0xFFF3F4FA),
    this.dividerColor = const Color(0xFF3F5BFA),
    this.turnOnColor = const Color(0xFF66F475),
    required this.turnOn,
    required this.modeIcon,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.onValueChanged,
    this.textStyle,
  });

  @override
  State<Thermostat> createState() => _ThermostatState();
}

class _ThermostatState extends State<Thermostat>
    with SingleTickerProviderStateMixin {
  static const double minRingRad = 4.538;
  static const double midRingRad = 4.7123889803847;
  static const double maxRingRad = 4.895;
  static const double deg90ToRad = 1.5708;

  late AnimationController _glowController;

  late double _angle;
  late int _value;

  @override
  void initState() {
    super.initState();

    _value = widget.initialValue;

    if (widget.initialValue == widget.minValue) {
      _angle = maxRingRad;
    } else if (widget.initialValue == widget.maxValue) {
      _angle = minRingRad;
    } else {
      final normalizedInitialValue =
          (widget.initialValue - widget.minValue) /
          (widget.maxValue - widget.minValue);
      final initialAngle = toRadians * normalizedInitialValue - deg90ToRad;
      final normalizedAngle = normalizeBetweenZeroAndTwoPi(initialAngle);
      _angle = _clampAngleValue(normalizedAngle);
    }

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _glowController.addListener(_handleChange);
  }

  @override
  void dispose() {
    _glowController.removeListener(_handleChange);
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.radius * 2.0;
    final double halfWidth = widget.radius;
    final Size size = Size(width, width);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: width,
        height: width,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: halfWidth - 16.0,
              left: halfWidth - 62.0,
              width: 32.0,
              height: 32.0,
              child: widget.modeIcon,
            ),
            Positioned(
              top: halfWidth - 4.0,
              right: halfWidth - 55.0,
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: widget.turnOn
                    ? BoxDecoration(
                        color: widget.turnOnColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.turnOnColor,
                            blurRadius: 4.0,
                            offset: const Offset(0.0, 3.0),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            Center(
              child: Text(
                '$_value',
                style:
                    widget.textStyle ??
                    Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            CustomPaint(
              size: size,
              painter: RingPainter(
                dividerColor: widget.dividerColor,
                glowColor: widget.glowColor,
                glowness: _glowController.value,
              ),
            ),
            CustomPaint(
              size: size,
              painter: TickThumbPainter(
                tickColor: widget.tickColor,
                thumbColor: widget.thumbColor,
                scoop: _glowController.value,
                angle: _angle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChange() {
    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    _glowRing();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final polarCoord = _polarCoordFromGlobalOffset(details.globalPosition);
    final angle = normalizeBetweenZeroAndTwoPi(polarCoord.angle);
    final double clampedAngle = _clampAngleValue(angle);

    if (clampedAngle != _angle) {
      setState(() {
        _angle = clampedAngle;

        final normalizedValue =
            normalizeBetweenZeroAndTwoPi(clampedAngle + deg90ToRad) / toRadians;

        final value =
            ((widget.maxValue - widget.minValue) * normalizedValue) +
            widget.minValue;

        final val = value.round();
        if (val != _value) {
          _value = val;
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _dimRing();
    widget.onValueChanged?.call(_value);
  }

  void _glowRing() {
    _glowController.forward();
  }

  void _dimRing() {
    _glowController.reverse();
  }

  double _clampAngleValue(double angle) {
    double clampedAngle = angle;
    if (angle > minRingRad && angle < midRingRad) {
      clampedAngle = minRingRad;
    } else if (angle >= midRingRad && angle < maxRingRad) {
      clampedAngle = maxRingRad;
    }
    return clampedAngle;
  }

  PolarCoord _polarCoordFromGlobalOffset(Offset globalOffset) {
    final localTouchOffset = (context.findRenderObject() as RenderBox)
        .globalToLocal(globalOffset);

    final Point<double> localTouchPoint = Point<double>(
      localTouchOffset.dx,
      localTouchOffset.dy,
    );

    final Size? size = context.size;
    final Point<double> originPoint = Point<double>(
      (size?.width ?? 0) / 2,
      (size?.height ?? 0) / 2,
    );

    return PolarCoord.fromPoints(originPoint, localTouchPoint);
  }
}

class RingPainter extends CustomPainter {
  final Color dividerColor;
  final Color glowColor;
  final double glowness;

  RingPainter({
    required this.dividerColor,
    required this.glowColor,
    required this.glowness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double center = size.width / 2.0;
    final Offset centerOffset = Offset(center, center);
    final double outerRingRadius = (size.width / 2.0) - 30.0;
    final double innerRingRadius = outerRingRadius - 32.0;

    final dividerGlowPaint = Paint()
      ..color = dividerColor
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        convertRadiusToSigma(4.0),
      );

    final dividerPaint = Paint()..color = dividerColor;

    final outerGlowPaint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        convertRadiusToSigma(18.0 + (5.0 * glowness)),
      );

    final gradient = RadialGradient(
      colors: <Color>[glowColor.withOpacity(0.0), glowColor.withOpacity(0.5)],
      stops: [0.8 - (0.13 * glowness), 1.0],
    );

    final Rect gradientRect = Rect.fromCircle(
      center: centerOffset,
      radius: innerRingRadius,
    );

    final Paint paint = Paint()..shader = gradient.createShader(gradientRect);

    canvas.saveLayer(rect, Paint());
    canvas.drawCircle(centerOffset, outerRingRadius, outerGlowPaint);
    canvas.drawCircle(centerOffset, innerRingRadius, paint);

    canvas.translate(center, center);
    final Rect dividerRect = Rect.fromLTWH(
      -2.0,
      -outerRingRadius,
      4.0,
      outerRingRadius - innerRingRadius,
    );
    canvas.drawRect(dividerRect, dividerPaint);
    canvas.drawRect(dividerRect, dividerGlowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    return oldDelegate.glowColor != glowColor ||
        oldDelegate.glowness != glowness ||
        oldDelegate.dividerColor != dividerColor;
  }
}

class TickThumbPainter extends CustomPainter {
  final Color tickColor;
  final Color thumbColor;
  final double scoop;
  final double angle;

  static const int tickCount = 180;

  TickThumbPainter({
    required this.tickColor,
    required this.thumbColor,
    required this.scoop,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2.0;
    final double outerRingRadius = (size.width / 2.0) - 30.0;
    final Offset centerOffset = Offset(center, center);
    final double innerRingRadius = outerRingRadius - 32.0 + 15.0;

    final double dx = innerRingRadius * cos(angle) + center;
    final double dy = innerRingRadius * sin(angle) + center;

    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = tickColor.withOpacity(0.3)
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(center, center);

    final double radians = toRadians / tickCount;
    double tRadians = 0.0;
    final curve = Curves.easeOut;

    for (int i = 0; i < tickCount; i++) {
      double lomber = 0.0;
      final diff = acos(cos(angle - tRadians));

      if (diff <= 0.3) {
        lomber = curve.transform(1 - (diff / 0.3)) * (15.0 * scoop);
      }

      canvas.drawLine(
        Offset(outerRingRadius + 0.5, 0.0),
        Offset(outerRingRadius + 15.0 + lomber, 0.0),
        tickPaint,
      );

      tRadians += radians;
      canvas.rotate(radians);
    }

    canvas.restore();

    final thumbPaint = Paint()
      ..color = thumbColor.withOpacity(0.7 + (0.3 * scoop));

    canvas.drawCircle(Offset(dx, dy), 14.0, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant TickThumbPainter oldDelegate) {
    return oldDelegate.tickColor != tickColor ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.scoop != scoop ||
        oldDelegate.angle != angle;
  }
}

class PolarCoord {
  final double angle;
  final double radius;

  factory PolarCoord.fromPoints(Point<double> origin, Point<double> point) {
    final Point<double> vectorPoint = point - origin;
    final Offset vector = Offset(vectorPoint.x, vectorPoint.y);

    return PolarCoord(vector.direction, vector.distance);
  }

  PolarCoord(this.angle, this.radius);

  @override
  String toString() {
    return 'Polar Coord: ${radius.toStringAsFixed(2)} at '
        '${(angle / toRadians * 360).toStringAsFixed(2)}°';
  }
}
