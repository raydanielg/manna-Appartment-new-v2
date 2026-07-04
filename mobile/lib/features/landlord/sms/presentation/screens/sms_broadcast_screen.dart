import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
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

  final _templates = {
    'Rent Reminder': 'Habari, tafadhali kulia kodi yako mapema ili kuepuka usumbufu. Asante.',
    'Payment Confirmation': 'Asante kwa malipo yako. Tulipokea kiasi cha TZS ____.',
    'General Notice': 'Habari, tunakutaarifu kuhusu mabadiliko ya uongozi wa nyumba.',
  };

  @override
  void dispose() {
    _messageController.dispose();
    _customNumbersController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(smsRepositoryProvider);
      final data = <String, dynamic>{
        'recipient_type': _recipientType,
        'message': message,
      };
      if (_recipientType == 'custom_numbers') {
        final numbers = _customNumbersController.text.split(',').map((n) => n.trim()).where((n) => n.isNotEmpty).toList();
        if (numbers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter at least one phone number'), backgroundColor: AppColors.error),
          );
          return;
        }
        data['custom_numbers'] = numbers;
      }
      final result = await repo.sendBroadcast(data);
      ref.invalidate(smsBalanceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Broadcast sent to ${result['sent_count'] ?? 0} recipients'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balanceAsync = ref.watch(smsBalanceProvider);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('SMS Broadcast', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: balanceAsync.when(
                loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                error: (_, __) => Text('0 SMS', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white)),
                data: (balance) => Text('$balance SMS', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipients', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildRecipientChip('All Tenants', 'all_tenants'),
                _buildRecipientChip('Active Tenants', 'active_tenants'),
                _buildRecipientChip('Overdue Tenants', 'overdue_tenants'),
                _buildRecipientChip('Custom Numbers', 'custom_numbers'),
              ],
            ),
            if (_recipientType == 'custom_numbers') ...[
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone Numbers',
                hint: '+255712..., +255713...',
                controller: _customNumbersController,
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 20),
            Text('Message', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Type message',
              controller: _messageController,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            Text('Quick Templates', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : AppColors.textLight)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _templates.entries.map((e) => ActionChip(
                label: Text(e.key, style: GoogleFonts.nunito(fontSize: 12)),
                onPressed: () => _messageController.text = e.value,
              )).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Switch(
                  value: _autoSend,
                  onChanged: (v) => setState(() => _autoSend = v),
                  activeColor: AppColors.primary,
                ),
                Text('Auto-send reminders', style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white : AppColors.textDark)),
              ],
            ),
            Text(
              'When enabled, this message will be saved for future automatic reminders.',
              style: GoogleFonts.nunito(fontSize: 11, color: isDark ? Colors.white60 : AppColors.textLight),
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Send Broadcast', isLoading: _isLoading, onPressed: _send),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
                child: Text('Cancel', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
