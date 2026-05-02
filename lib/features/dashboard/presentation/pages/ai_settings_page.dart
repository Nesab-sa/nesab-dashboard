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

  // Fields
  bool _enabled = true;
  String _provider = 'grok';
  String _model = 'grok-3-mini';
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
          _enabled = d['enabled'] as bool? ?? true;
          _provider = d['provider'] as String? ?? 'grok';
          _model = d['model'] as String? ?? 'grok-3-mini';
          _systemPromptController.text = d['systemPrompt'] as String? ?? '';
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
        'enabled': _enabled,
        'provider': _provider,
        'model': _model,
        'systemPrompt': _systemPromptController.text.trim(),
        'pages': Map<String, dynamic>.from(_pageEnabled),
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
                    // Header
                    Row(
                      children: [
                        Icon(Icons.smart_toy_rounded, color: AppColors.blue, size: 28),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Text(
                          'إعدادات الذكاء الاصطناعي',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
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

                    // ── Section: General ──────────────────────────────────────
                    _SectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      title: 'الإعدادات العامة',
                      titleColor: textPrimary,
                      child: Column(
                        children: [
                          _SettingRow(
                            label: 'تفعيل الذكاء الاصطناعي',
                            subtitle: 'تشغيل أو إيقاف خدمة AI في التطبيق',
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            trailing: Switch(
                              value: _enabled,
                              activeColor: AppColors.blue,
                              onChanged: (v) => setState(() => _enabled = v),
                            ),
                          ),
                          Divider(height: 1, color: borderColor),
                          const SizedBox(height: AppDimensions.spacingMd),
                          // Provider selector
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('مزود الذكاء الاصطناعي', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('اختر المزود الذي يتم استخدام مفتاحه من Secret Manager', style: TextStyle(color: textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingMd),
                              DropdownButton<String>(
                                value: _provider,
                                dropdownColor: cardColor,
                                style: TextStyle(color: textPrimary),
                                items: const [
                                  DropdownMenuItem(value: 'grok', child: Text('xAI Grok')),
                                  DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    _provider = v;
                                    _model = v == 'grok' ? 'grok-3-mini' : 'gpt-4o-mini';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          // Model
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('النموذج', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('اسم النموذج المستخدم في API', style: TextStyle(color: textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingMd),
                              DropdownButton<String>(
                                value: _model,
                                dropdownColor: cardColor,
                                style: TextStyle(color: textPrimary),
                                items: _provider == 'grok'
                                    ? const [
                                        DropdownMenuItem(value: 'grok-3-mini', child: Text('grok-3-mini')),
                                        DropdownMenuItem(value: 'grok-3', child: Text('grok-3')),
                                        DropdownMenuItem(value: 'grok-2', child: Text('grok-2')),
                                      ]
                                    : const [
                                        DropdownMenuItem(value: 'gpt-4o-mini', child: Text('gpt-4o-mini')),
                                        DropdownMenuItem(value: 'gpt-4o', child: Text('gpt-4o')),
                                        DropdownMenuItem(value: 'gpt-4-turbo', child: Text('gpt-4-turbo')),
                                      ],
                                onChanged: (v) { if (v != null) setState(() => _model = v); },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    // ── Section: System Prompt ────────────────────────────────
                    _SectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      title: 'System Prompt',
                      titleColor: textPrimary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التعليمات الأساسية للذكاء الاصطناعي. يُرسل هذا النص في بداية كل محادثة.',
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

                    // ── Section: Per-page placement ───────────────────────────
                    _SectionCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      title: 'ظهور AI في صفحات التطبيق',
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
                                  activeColor: AppColors.blue,
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
                                height: 20,
                                width: 20,
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
