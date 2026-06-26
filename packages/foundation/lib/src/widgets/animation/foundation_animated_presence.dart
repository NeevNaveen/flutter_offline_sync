import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class FoundationAnimatedPresence extends StatefulWidget {
  const FoundationAnimatedPresence({
    super.key,
    required this.child,
    this.visible = true,
    this.slideOffset = const Offset(0, -0.08),
  });

  final Widget child;
  final bool visible;
  final Offset slideOffset;

  @override
  State<FoundationAnimatedPresence> createState() =>
      _FoundationAnimatedPresenceState();
}

class _FoundationAnimatedPresenceState extends State<FoundationAnimatedPresence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.visible) {
      _controller.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = Duration(
      milliseconds: context.theme.sizes.motion.normal.toInt(),
    );
  }

  @override
  void didUpdateWidget(FoundationAnimatedPresence oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _controller.forward(from: 0);
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class FoundationShake extends StatefulWidget {
  const FoundationShake({
    super.key,
    required this.child,
    this.trigger = 0,
  });

  final Widget child;
  final int trigger;

  @override
  State<FoundationShake> createState() => _FoundationShakeState();
}

class _FoundationShakeState extends State<FoundationShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = Duration(
      milliseconds: context.theme.sizes.motion.fast.toInt(),
    );
  }

  @override
  void didUpdateWidget(FoundationShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offset.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
