import 'package:flutter/material.dart';
import 'package:foundation/foundation.dart';

/// Live preview of all foundation UI components.
class ComponentCatalogPage extends StatefulWidget {
  const ComponentCatalogPage({super.key});

  @override
  State<ComponentCatalogPage> createState() => _ComponentCatalogPageState();
}

class _ComponentCatalogPageState extends State<ComponentCatalogPage> {
  final _nameKey = GlobalKey<PrimaryTextInputFieldState>();
  final _emailKey = GlobalKey<EmailInputFieldState>();
  final _phoneKey = GlobalKey<PhoneInputFieldState>();
  final _notesKey = GlobalKey<MultilineTextInputFieldState>();

  bool _showSuccess = false;
  bool _showError = false;
  bool _buttonLoading = false;

  void _validateForm() {
    final valid = [
      _nameKey.currentState?.validate() ?? false,
      _emailKey.currentState?.validate() ?? false,
      _phoneKey.currentState?.validate() ?? false,
      _notesKey.currentState?.validate() ?? false,
    ].every((passed) => passed);

    setState(() {
      _showSuccess = valid;
      _showError = !valid;
    });
  }

  void _toggleLoading() {
    setState(() => _buttonLoading = true);
    Future<void>.delayed(
      Duration(milliseconds: context.theme.sizes.motion.slow.toInt()),
      () {
        if (mounted) setState(() => _buttonLoading = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.sizes.spacing;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Component catalog',
          style: theme.typography.title.large.copyWith(
            color: theme.colors.semantic.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(spacing.lg),
        children: [
          _Section(
            title: 'Typography',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                PrimaryText('Primary text — main content and labels'),
                SizedBox(height: 8),
                SecondaryText('Secondary text — supporting descriptions'),
              ],
            ),
          ),
          _Section(
            title: 'Buttons',
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Primary button',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _toggleLoading,
                  isLoading: _buttonLoading,
                ),
                SizedBox(height: spacing.sm),
                SecondaryButton(
                  label: 'Secondary button',
                  icon: Icons.tune_rounded,
                  onPressed: () => context.themeNotifier.toggleMode(),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Alerts',
            child: Column(
              children: [
                SuccessAlert(
                  visible: _showSuccess,
                  title: 'All good',
                  message: 'Your form passed validation.',
                  onDismiss: () => setState(() => _showSuccess = false),
                ),
                if (_showSuccess) SizedBox(height: spacing.sm),
                ErrorAlert(
                  visible: _showError,
                  title: 'Check your input',
                  message: 'Fix the highlighted fields and try again.',
                  onDismiss: () => setState(() => _showError = false),
                ),
                if (!_showSuccess && !_showError)
                  SecondaryText('Submit the form below to preview alerts.'),
              ],
            ),
          ),
          _Section(
            title: 'Inputs',
            child: Column(
              children: [
                PrimaryTextInputField(key: _nameKey),
                SizedBox(height: spacing.md),
                EmailInputField(key: _emailKey),
                SizedBox(height: spacing.md),
                PhoneInputField(key: _phoneKey),
                SizedBox(height: spacing.md),
                MultilineTextInputField(key: _notesKey),
                SizedBox(height: spacing.lg),
                PrimaryButton(
                  label: 'Validate form',
                  onPressed: _validateForm,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Bottom sheet',
            child: SecondaryButton(
              label: 'Open bottom sheet',
              onPressed: () {
                FoundationBottomSheet.show<void>(
                  context: context,
                  title: 'Schedule task',
                  actionLabel: 'Confirm',
                  child: const SecondaryText(
                    'Pick a time slot for your offline task. '
                    'Changes sync when you reconnect.',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final spacing = theme.sizes.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.headline.large.copyWith(
              color: theme.colors.semantic.textPrimary,
            ),
          ),
          SizedBox(height: spacing.md),
          child,
        ],
      ),
    );
  }
}
