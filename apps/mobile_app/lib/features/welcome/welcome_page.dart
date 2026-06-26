import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _iconScaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = Duration(
      milliseconds: context.theme.sizes.motion.normal.toInt(),
    );
    if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors.semantic;
    final spacing = theme.sizes.spacing;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _iconScaleAnimation,
                    child: Container(
                      padding: EdgeInsets.all(spacing.md),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          theme.sizes.radius.lg,
                        ),
                      ),
                      child: Icon(
                        Icons.offline_bolt_rounded,
                        size: spacing.xxxl,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.xl),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Welcome',
                    style: theme.typography.display.large.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.sm),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Plan tasks offline, sync when you are back online.',
                    style: theme.typography.body.large.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.section),
              FadeTransition(
                opacity: _fadeAnimation,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ComponentCatalogPage(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.xl,
                      vertical: spacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(theme.sizes.radius.md),
                    ),
                  ),
                  child: Text(
                    'Get started',
                    style: theme.typography.title.large.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacing.lg),
              FadeTransition(
                opacity: _fadeAnimation,
                child: TextButton.icon(
                  onPressed: context.themeNotifier.toggleMode,
                  icon: Icon(
                    Icons.brightness_6_rounded,
                    color: colors.textSecondary,
                    size: theme.sizes.spacing.lg,
                  ),
                  label: Text(
                    'Switch to ${context.themeNotifier.mode == FoundationThemeMode.light ? 'dark' : 'light'} mode',
                    style: theme.typography.label.medium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
