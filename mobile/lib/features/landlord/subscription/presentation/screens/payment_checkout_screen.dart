import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _isPaying = false;
  bool _showSuccess = false;
  bool _showWaiting = false;
  int _pollAttempts = 0;
  Timer? _pollTimer;
  late final AnimationController _successController;

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

    setState(() {
      _isPaying = true;
      _showWaiting = false;
    });

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.initiatePayment(
        plan['id'] as String,
        phone,
        paymentMethod: 'mobile_money',
      );

      final providerReference = result['provider_reference'] as String?;
      final reference = result['reference'] as String?;

      if (providerReference == null && reference == null) {
        _showSnack('Imeshindwa kuanzisha malipo. Tafadhali jaribu tena.');
        return;
      }

      // USSD push is sent automatically by Snippe - no browser needed
      setState(() {
        _isPaying = false;
        _showWaiting = true;
      });
      _startPolling(providerReference ?? reference!);
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
    _pollAttempts = 0;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _pollAttempts++;

      // Stop after 24 attempts (2 minutes)
      if (_pollAttempts > 24) {
        timer.cancel();
        setState(() => _showWaiting = false);
        _showSnack('Muda wa kusubiri umekwisha. Tafadhali angalia hali ya malipo baadaye.');
        return;
      }

      try {
        final repo = ref.read(subscriptionRepositoryProvider);
        final status = await repo.verifyPayment(reference);

        if (status['status'] == 'completed') {
          timer.cancel();
          setState(() => _showWaiting = false);
          _showSuccessAnimation();
        } else if (status['status'] == 'failed') {
          timer.cancel();
          setState(() => _showWaiting = false);
          _showSnack('Malipo yameshindwa. Huenda USSD push haikufika kwenye simu yako. Tafadhali hakikisha namba ya simu ni sahihi na jaribu tena.');
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
                // Mobile Money info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_android, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mobile Money', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                            const SizedBox(height: 2),
                            Text('M-Pesa, Tigo Pesa, Airtel Money, Halopesa', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(label: 'Namba ya Simu ya Kulipia', hint: '0712345678', controller: _phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Lipa Sasa',
                  icon: const Icon(Icons.lock),
                  isLoading: _isPaying,
                  onPressed: plan.isEmpty ? null : () => _pay(plan),
                ),
              ],
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(),
          if (_showWaiting) _buildWaitingOverlay(),
        ],
      ),
    );
  }

  Widget _buildWaitingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Subiri USSD kwenye simu yako',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ombi la malipo limetumwa kwenye simu yako. Ingiza PIN yako ya mobile money kukamilisha malipo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  _pollTimer?.cancel();
                  setState(() => _showWaiting = false);
                  _showSnack('Malipo yamekatishwa. Hali ya malipo itaangaliwa baadaye.');
                },
                child: const Text('Katisha', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
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
