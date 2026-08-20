import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/utils/app_error.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/sms_provider.dart';

class SmsBroadcastScreen extends ConsumerStatefulWidget {
  const SmsBroadcastScreen({super.key});

  @override
  ConsumerState<SmsBroadcastScreen> createState() => _SmsBroadcastScreenState();
}

class _SmsBroadcastScreenState extends ConsumerState<SmsBroadcastScreen> {
  final _messageController = TextEditingController();
  final _customNumbersController = TextEditingController();
  String _recipientType = 'all_tenants';
  bool _autoSend = false;
  bool _isLoading = false;

  final _templates = <_SmsTemplate>[];
  bool _templatesInitialized = false;

  void _initTemplates() {
    if (_templatesInitialized) return;
    _templatesInitialized = true;
    _templates.addAll([
      _SmsTemplate(
        icon: Icons.payments,
        label: context.tr('rent_reminder'),
        message: 'Habari, hii ni ukumbusho wa kodi yako ya mwezi. Tafadhali lipa mapema ili kuepuka usumbufu. Asante - Manna Apartment.',
      ),
      _SmsTemplate(
        icon: Icons.check_circle,
        label: context.tr('payment_received'),
        message: 'Asante kwa malipo yako. Tulipokea kiasi chako cha kodi. Mwisho wa mwezi utapata risiti yako. - Manna Apartment',
      ),
      _SmsTemplate(
        icon: Icons.build,
        label: context.tr('maintenance_notice'),
        message: 'Tunakujulisha kuna matengenezo ya maji/umeme kwenye jengo letu tarehe ____. Tafadhali jipangalie. Asante - Manna Apartment',
      ),
      _SmsTemplate(
        icon: Icons.celebration,
        label: context.tr('general_notice'),
        message: 'Habari, tunakutaarifu kuhusu mabadiliko ya utawala wa jengo. Kwa maelezo zaidi wasiliana nasi. Asante - Manna Apartment',
      ),
      _SmsTemplate(
        icon: Icons.warning,
        label: context.tr('overdue_notice'),
        message: 'Kodi yako haijalipwa bado. Tafadhali lipa ndani ya siku 3 zijazo ili kuepuka hatua za kisheria. Asante - Manna Apartment',
      ),
      _SmsTemplate(
        icon: Icons.meeting_room,
        label: context.tr('meeting_notice'),
        message: 'Kuna mkutano wa wapangaji tarehe ____ saa ____ kwenye ofisi ya jengo. Kuja ni muhimu. Asante - Manna Apartment',
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _customNumbersController.dispose();
    super.dispose();
  }

  int _calcSmsCount(String text) {
    if (text.isEmpty) return 0;
    final len = text.length;
    if (len <= 160) return 1;
    if (len <= 306) return 2;
    if (len <= 459) return 3;
    if (len <= 612) return 4;
    if (len <= 765) return 5;
    return ((len - 765) ~/ 153) + 6;
  }

  int _calcCustomRecipientCount() {
    if (_recipientType != 'custom_numbers') return 0;
    return _customNumbersController.text.split(',').map((n) => n.trim()).where((n) => n.isNotEmpty).length;
  }

  Future<void> _send() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_write_message')), backgroundColor: AppColors.error),
      );
      return;
    }
    final data = <String, dynamic>{
      'recipient_type': _recipientType,
      'message': message,
    };
    if (_recipientType == 'custom_numbers') {
      final numbers = _customNumbersController.text.split(',').map((n) => n.trim()).where((n) => n.isNotEmpty).toList();
      if (numbers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('please_enter_phone')), backgroundColor: AppColors.error),
        );
        return;
      }
      data['custom_numbers'] = numbers;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(smsRepositoryProvider);
      final result = await repo.sendBroadcast(data);
      ref.invalidate(smsBalanceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('message_sent_to').replaceAll('{0}', '${result['sent_count'] ?? 0}')), backgroundColor: AppColors.success),
        );
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('send_failed').replaceAll('{0}', AppError.getMessage(e))), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _initTemplates();
    final balanceAsync = ref.watch(smsBalanceProvider);
    final messageText = _messageController.text;
    final smsPerMessage = _calcSmsCount(messageText);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(context.tr('sms_broadcast'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            balanceAsync.when(
              loading: () => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
              error: (_, __) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400),
                    const SizedBox(width: 12),
                    Expanded(child: Text(context.tr('failed_load_sms_balance'), style: GoogleFonts.nunito(fontSize: 13, color: Colors.red.shade700))),
                  ],
                ),
              ),
              data: (balance) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.info, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sms, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(context.tr('sms_balance_label'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$balance', style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                    Text(context.tr('sms_remaining'), style: GoogleFonts.nunito(fontSize: 11, color: Colors.white60)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recipients
            Text(context.tr('recipients'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildRecipientChip(context.tr('all_tenants'), 'all_tenants'),
                _buildRecipientChip(context.tr('active_tenants'), 'active_tenants'),
                _buildRecipientChip(context.tr('overdue_tenants'), 'overdue_tenants'),
                _buildRecipientChip(context.tr('custom_numbers'), 'custom_numbers'),
              ],
            ),
            if (_recipientType == 'custom_numbers') ...[
              const SizedBox(height: 16),
              AppTextField(
                label: context.tr('phone_numbers'),
                hint: '+255712..., +255713...',
                controller: _customNumbersController,
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 24),

            // Message
            Text(context.tr('message'), style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            AppTextField(
              label: context.tr('type_message_here'),
              controller: _messageController,
              maxLines: 5,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),

            // SMS counter
            if (messageText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: smsPerMessage > 1 ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: smsPerMessage > 1 ? Colors.orange.shade200 : Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(smsPerMessage > 1 ? Icons.info_outline : Icons.check_circle_outline, size: 16, color: smsPerMessage > 1 ? Colors.orange.shade700 : Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${messageText.length} herufi = $smsPerMessage SMS',
                        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: smsPerMessage > 1 ? Colors.orange.shade700 : Colors.green.shade700),
                      ),
                    ),
                    if (_recipientType == 'custom_numbers' && _calcCustomRecipientCount() > 0)
                      Text(
                        'Jumla: ${smsPerMessage * _calcCustomRecipientCount()} SMS',
                        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Quick templates
            Text(context.tr('quick_templates'), style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : AppColors.textLight)),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _templates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final t = _templates[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _messageController.text = t.message),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(t.icon, size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                                const SizedBox(height: 2),
                                Text(t.message, style: GoogleFonts.nunito(fontSize: 11, color: isDark ? Colors.white60 : AppColors.textLight), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white30 : AppColors.textLight),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Auto-send toggle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Switch(
                    value: _autoSend,
                    onChanged: (v) => setState(() => _autoSend = v),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(context.tr('auto_save_reminder'), style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white : AppColors.textDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(text: context.tr('send_message'), isLoading: _isLoading, onPressed: _send),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
                child: Text(context.tr('cancel_btn'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientChip(String label, String value) {
    final isSelected = _recipientType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textLight))),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (_) => setState(() => _recipientType = value),
    );
  }
}

class _SmsTemplate {
  final IconData icon;
  final String label;
  final String message;

  _SmsTemplate({required this.icon, required this.label, required this.message});
}
