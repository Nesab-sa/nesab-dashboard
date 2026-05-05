import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:nesab/core/constants/app_constants.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Terms of Use and Privacy Policy agreement text.
///
/// Displays "By continuing, you agree to the Terms of Use and Privacy Policy"
/// with the linked portions styled in the primary color.
class TermsText extends StatefulWidget {
  const TermsText({super.key});

  @override
  State<TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<TermsText> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalPage(AppConstants.termsOfUseUrl);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalPage(AppConstants.privacyPolicyUrl);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _openLegalPage(String url) async {
    final uri = Uri.parse(url);
    final openedInApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);

    if (openedInApp || !mounted) {
      return;
    }

    final openedExternally = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (openedExternally || !mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.errorOccurred)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = AppTextStyles.caption.copyWith(
      color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
      height: 1.8,
    );
    final linkStyle = AppTextStyles.caption.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.termsPrefix),
          TextSpan(
            text: ' ${l10n.termsOfUse} ',
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          TextSpan(text: l10n.termsAnd),
          TextSpan(
            text: ' ${l10n.privacyPolicy}',
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
