import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  final _firestore = FirebaseFirestore.instance;
  static const _docPath = 'ai_config/settings';

  bool _loading = true;
  bool _saving = false;
  String? _error;
  bool _saved = false;

  // ── Nesab-AI (PHP chat backend) ──────────────────────────────────────────
  bool _nesabAiEnabled = true;
  final _systemPromptController = TextEditingController();

  // Per-page placement
  final Map<String, bool> _pageEnabled = {
    'splash': false,
    'onboarding': false,
    'login': false,
    'register': false,
    'forgotPassword': false,
    'home': true,
    'categoryDetails': true,
    'calculator': true,
    'profile': false,
    'settings': false,
  };

  final Map<String, String> _pageLabels = {
    'splash': 'شاشة البداية (Splash)',
    'onboarding': 'الإعداد الأولي (Onboarding)',
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'forgotPassword': 'نسيت كلمة المرور',
    'home': 'الرئيسية',
    'categoryDetails': 'تفاصيل الفئة',
    'calculator': 'الحاسبات',
    'profile': 'الملف الشخصي',
    'settings': 'الإعدادات',
  };

  // ── Grok AI (profit margins scheduler) ──────────────────────────────────
  String _grokModel = 'grok-3';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final doc = await _firestore.doc(_docPath).get();
      if (doc.exists) {
        final d = doc.data()!;
        setState(() {
          _nesabAiEnabled = d['enabled'] as bool? ?? true;
          _systemPromptController.text = d['systemPrompt'] as String? ?? '';
          _grokModel = d['grokModel'] as String? ?? 'grok-3';
          final pages = d['pages'] as Map<String, dynamic>?;
          if (pages != null) {
            for (final k in _pageEnabled.keys) {
              if (pages.containsKey(k)) {
                _pageEnabled[k] = pages[k] as bool? ?? false;
              }
            }
          }
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _save() async {
    setState(() { _saving = true; _saved = false; _error = null; });
    try {
      await _firestore.doc(_docPath).set({
        // Nesab-AI fields
        'enabled': _nesabAiEnabled,
        'systemPrompt': _systemPromptController.text.trim(),
        'pages': Map<String, dynamic>.from(_pageEnabled),
        // Grok fields
        'grokModel': _grokModel,
        // Legacy compat with chat.php reads
        'provider': 'nesab-ai',
        'model': 'nesab-ai',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      setState(() { _saved = true; });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() { _saved = false; });
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.dashboardBg : AppColors.lightModeBg;
    final cardColor = isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
    final textPrimary = isDark ? AppColors.dashboardTextPrimary : AppColors.lightModeTextPrimary;
    final textSecondary = isDark ? AppColors.dashboardTextSecondary : AppColors.lightModeTextSecondary;
    final borderColor = isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Header ───────────────────────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.smart_toy_rounded, color: AppColors.blue, size: 28),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Text(
                          'إعدادات الذكاء الاصطناعي',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const Spacer(),
                        if (_saved)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                const SizedBox(width: 6),
                                Text('تم الحفظ', style: TextStyle(color: AppColors.success, fontSize: 13)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    // Architecture info banner
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: AppColors.blue.withOpacity(0.18)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'المنصة تستخدم نظامَي ذكاء اصطناعي منفصلَين:\n'
                              '• Nesab-AI — المساعد المحادثاتي الظاهر في التطبيق (PHP backend على api.nesab.sa)\n'
                              '• Grok AI — يُحدّث هوامش الربح تلقائياً كل يوم الساعة 10:00 صباحاً',
                              style: TextStyle(color: textPrimary, fontSize: 12, height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),

                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(_error!, style: TextStyle(color: AppColors.error)),
                      ),

                    // ═══════════════════════════════════════════════════════
                    // SECTION 1 — Nesab-AI (chat assistant)
                    // ═══════════════════════════════════════════════════════
                    _SectionHeader(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Nesab-AI — المساعد المحادثاتي',
                      sublabel: 'يعمل عبر api.nesab.sa/Nesab.Ai/chat.php',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentColor: AppColors.blue,
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    _SectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      title: 'تفعيل المساعد',
                      titleColor: textPrimary,
                      child: _SettingRow(
                        label: 'تشغيل Nesab-AI في التطبيق',
                        subtitle: 'تشغيل أو إيقاف زر المحادثة في واجهة المستخدم',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        trailing: Switch(
                          value: _nesabAiEnabled,
                          activeThumbColor: AppColors.blue,
                          onChanged: (v) => setState(() => _nesabAiEnabled = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    _SectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      title: 'System Prompt',
                      titleColor: textPrimary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التعليمات الأساسية للمساعد. يُرسل في بداية كل محادثة عبر chat.php.',
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          TextField(
                            controller: _systemPromptController,
                            maxLines: 6,
                            style: TextStyle(color: textPrimary, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'أنت مساعد مالي ذكي لمنصة نِسب...',
                              hintStyle: TextStyle(color: textSecondary),
                              filled: true,
                              fillColor: isDark ? AppColors.dashboardBg : AppColors.lightModeBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    _SectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      title: 'ظهور Nesab-AI في صفحات التطبيق',
                      titleColor: textPrimary,
                      child: Column(
                        children: _pageEnabled.entries.map((entry) {
                          final isLast = entry.key == _pageEnabled.keys.last;
                          return Column(
                            children: [
                              _SettingRow(
                                label: _pageLabels[entry.key] ?? entry.key,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                trailing: Switch(
                                  value: entry.value,
                                  activeThumbColor: AppColors.blue,
                                  onChanged: (v) => setState(() => _pageEnabled[entry.key] = v),
                                ),
                              ),
                              if (!isLast) Divider(height: 1, color: borderColor),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),

                    // ═══════════════════════════════════════════════════════
                    // SECTION 2 — Grok AI (profit margins)
                    // ═══════════════════════════════════════════════════════
                    _SectionHeader(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Grok AI — تحديث هوامش الربح',
                      sublabel: 'مهمة يومية تلقائية عبر Cloud Functions',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentColor: const Color(0xFF7C3AED),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    _SectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      title: 'نموذج Grok',
                      titleColor: textPrimary,
                      child: Column(
                        children: [
                          _SettingRow(
                            label: 'نموذج الاستعلام اليومي',
                            subtitle: 'يُستخدم في مهمة updateProfitMargins والتحديث اليدوي من صفحة هوامش الربح',
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            trailing: DropdownButton<String>(
                              value: _grokModel,
                              dropdownColor: cardColor,
                              style: TextStyle(color: textPrimary),
                              items: const [
                                DropdownMenuItem(value: 'grok-3', child: Text('grok-3')),
                                DropdownMenuItem(value: 'grok-3-mini', child: Text('grok-3-mini')),
                                DropdownMenuItem(value: 'grok-2', child: Text('grok-2')),
                              ],
                              onChanged: (v) { if (v != null) setState(() => _grokModel = v); },
                            ),
                          ),
                          Divider(height: 1, color: borderColor),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, color: textSecondary, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'الجدول: يومياً الساعة 10:00 صباحاً (07:00 UTC)\n'
                                    'المهمة: updateProfitMargins في Cloud Functions\n'
                                    'يحفظ النتيجة في Firestore → bank_rates/profit_margins',
                                    style: TextStyle(color: textSecondary, fontSize: 12, height: 1.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('حفظ الإعدادات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(sublabel, style: TextStyle(color: textSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.cardColor,
    required this.borderColor,
    required this.title,
    required this.titleColor,
    required this.child,
  });

  final Color cardColor;
  final Color borderColor;
  final String title;
  final Color titleColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppDimensions.spacingMd),
          child,
        ],
      ),
    );
  }
}

// ─── Setting row ──────────────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.textPrimary,
    required this.textSecondary,
    required this.trailing,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final Color textPrimary;
  final Color textSecondary;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: TextStyle(color: textSecondary, fontSize: 12)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
