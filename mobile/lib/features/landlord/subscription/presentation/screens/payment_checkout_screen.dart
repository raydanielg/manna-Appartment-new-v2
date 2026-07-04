import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/subscription_provider.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  const PaymentCheckoutScreen({super.key});

  @override
  ConsumerState<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends ConsumerState<PaymentCheckoutScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _accountNumberController = TextEditingController();
  bool _isPaying = false;
  bool _showSuccess = false;
  String _paymentMethod = 'mobile_money';
  String? _selectedBank;
  Timer? _pollTimer;
  late final AnimationController _successController;

  final _banks = [
    'NMB Bank',
    'CRDB Bank',
    'NBC Bank',
    'Stanbic Bank',
    'Diamond Trust Bank',
    'Exim Bank',
    'KCB Bank',
    'Absa Bank',
    'TPB Bank',
    'Bank of Africa',
  ];

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _accountNumberController.dispose();
    _pollTimer?.cancel();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _pay(Map<String, dynamic> plan) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Weka namba ya simu ya kulipia.');
      return;
    }
    if (_paymentMethod == 'bank_transfer' && (_selectedBank == null || _selectedBank!.isEmpty)) {
      _showSnack('Chagua benki ya kulipia.');
      return;
    }

    setState(() => _isPaying = true);

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.initiatePayment(
        plan['id'] as String,
        phone,
        paymentMethod: _paymentMethod,
        bank: _selectedBank,
        accountNumber: _accountNumberController.text.trim(),
      );

      final checkoutUrl = result['checkout_url'] as String?;
      final providerReference = result['provider_reference'] as String?;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        _showSnack('Imeshindwa kuanzisha malipo. Hakikisha API key ya Snippe imewekwa.');
        return;
      }

      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      _startPolling(providerReference ?? result['reference'] as String);
    } catch (e) {
      final message = _extractErrorMessage(e);
      _showSnack(message);
    } finally {
      setState(() => _isPaying = false);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response?.data is Map) {
        final data = response!.data as Map;
        if (data['message'] is String && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              for (final msg in value) {
                messages.add('${msg.toString()}');
              }
            }
          });
          if (messages.isNotEmpty) return messages.join('\n');
        }
      }
      return error.message ?? 'Imeshindwa kuanzisha malipo. Tafadhali jaribu tena.';
    }
    return error.toString();
  }

  void _startPolling(String reference) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final repo = ref.read(subscriptionRepositoryProvider);
        final status = await repo.verifyPayment(reference);

        if (status['status'] == 'completed') {
          timer.cancel();
          _showSuccessAnimation();
        }
      } catch (e) {
        // ignore polling errors
      }
    });
  }

  void _showSuccessAnimation() {
    setState(() => _showSuccess = true);
    _successController.forward();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatPrice(dynamic price) {
    final value = (price is num ? price : num.tryParse(price.toString())) ?? 0;
    return 'TZS ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planId = GoRouterState.of(context).uri.queryParameters['plan_id'] ?? '';
    final plansAsync = ref.watch(subscriptionPlansProvider);

    final plan = plansAsync.maybeWhen(
      data: (plans) => plans.cast<Map<String, dynamic>>().firstWhere(
            (p) => p['id'] == planId,
            orElse: () => <String, dynamic>{},
          ),
      orElse: () => <String, dynamic>{},
    );

    final planName = plan['name'] as String? ?? 'Subscription Plan';
    final planPrice = plan['price'] ?? 0;
    final planCycle = plan['billing_cycle'] as String? ?? 'monthly';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Checkout'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(planName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                              const SizedBox(height: 4),
                              Text('${_formatPrice(planPrice)} / $planCycle', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                const SizedBox(height: 12),
                _buildMethodToggle(context),
                const SizedBox(height: 16),
                if (_paymentMethod == 'bank_transfer') ...[
                  _buildBankDropdown(context),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Account Number / Reference', hint: 'Optional', controller: _accountNumberController, keyboardType: TextInputType.text),
                  const SizedBox(height: 16),
                ],
                AppTextField(label: 'Phone Number', hint: '0712345678', controller: _phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: _paymentMethod == 'bank_transfer' ? 'Pay via Bank' : 'Pay Now',
                  icon: const Icon(Icons.lock),
                  isLoading: _isPaying,
                  onPressed: plan.isEmpty ? null : () => _pay(plan),
                ),
              ],
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildMethodToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildMethodButton(context, 'mobile_money', Icons.phone_android, 'Mobile Money'),
          _buildMethodButton(context, 'bank_transfer', Icons.account_balance, 'Bank'),
        ],
      ),
    );
  }

  Widget _buildMethodButton(BuildContext context, String method, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? AppColors.primary.withValues(alpha: 0.2) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: isActive ? AppColors.primary : (isDark ? Colors.white54 : Colors.grey.shade500)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600, color: isActive ? AppColors.primary : (isDark ? Colors.white54 : Colors.grey.shade500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankDropdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedBank,
          hint: Text('Chagua benki', style: TextStyle(color: isDark ? Colors.white60 : AppColors.textLight)),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: _banks.map((bank) => DropdownMenuItem(
            value: bank,
            child: Text(bank, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
          )).toList(),
          onChanged: (value) => setState(() => _selectedBank = value),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        final scale = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
        ).value;

        return Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Malipo yamekamilika!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Subscription yako sasa imewashwa. Asante.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textLight),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Endelea',
                      onPressed: () {
                        _pollTimer?.cancel();
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
