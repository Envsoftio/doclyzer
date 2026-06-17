import 'dart:math';

import 'package:flutter/material.dart';

class ConfettiBurst {
  static void show(BuildContext context) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ConfettiOverlay(
        onComplete: () {
          entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _particles = List.generate(96, (index) {
      final fromLeft = index.isEven;
      return _ConfettiParticle(
        fromLeft: fromLeft,
        dx: random.nextDouble() * 0.42 + 0.08,
        dy: random.nextDouble() * 0.58 + 0.08,
        size: random.nextDouble() * 5 + 4,
        rotation: random.nextDouble() * pi * 2,
        color: _confettiColors[index % _confettiColors.length],
      );
    });
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1500),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onComplete();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(
              progress: Curves.easeOutCubic.transform(_controller.value),
              particles: _particles,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress, required this.particles});

  final double progress;
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final originX = particle.fromLeft ? 0.08 * size.width : 0.92 * size.width;
      final originY = 0.92 * size.height;
      final direction = particle.fromLeft ? 1.0 : -1.0;
      final targetX = originX + direction * particle.dx * size.width * progress;
      final arcLift = sin(progress * pi) * size.height * 0.22;
      final targetY = originY - particle.dy * size.height * progress - arcLift;
      final rect = Rect.fromCenter(
        center: Offset(targetX, targetY),
        width: particle.size,
        height: particle.size * 1.8,
      );

      paint.color = particle.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(particle.rotation + progress * pi * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: rect.width,
            height: rect.height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.fromLeft,
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
    required this.color,
  });

  final bool fromLeft;
  final double dx;
  final double dy;
  final double size;
  final double rotation;
  final Color color;
}

const _confettiColors = [
  Color(0xFF0A7C8C),
  Color(0xFF19A974),
  Color(0xFFE9B44C),
  Color(0xFFE85D75),
  Color(0xFF3D5A80),
  Color(0xFF7C3AED),
];
