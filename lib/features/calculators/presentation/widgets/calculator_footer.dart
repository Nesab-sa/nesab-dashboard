import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Shared footer widget matching the HTML `.footer` section.
/// Shows "By Abdullah Almalki" and social icons (WhatsApp, Twitter/X, Telegram).
class CalculatorFooter extends StatelessWidget {
  const CalculatorFooter({super.key});

  static const _socials = [
    _Social('WhatsApp', 'https://wa.me/966500768074', Color(0xFF25D366)),
    _Social('X', 'https://twitter.com/hala_7171', Color(0xFF1DA1F2)),
    _Social('Telegram', 'https://t.me/Nesab.sa', Color(0xFF0088CC)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'By Abdullah Almalki',
                  style: TextStyle(fontSize: 10, color: Color(0xFF2A4060)),
                ),
                const SizedBox(width: 10),
                for (final s in _socials)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () => launchUrl(Uri.parse(s.url)),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: s.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          s.url.contains('wa.me')
                              ? Icons.chat_bubble
                              : s.url.contains('twitter')
                                  ? Icons.alternate_email
                                  : Icons.send,
                          size: 12,
                          color: s.color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Text(
              'www.Nesab.sa',
              style: TextStyle(fontSize: 10, color: AppColors.calcMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Social {
  const _Social(this.label, this.url, this.color);
  final String label;
  final String url;
  final Color color;
}
