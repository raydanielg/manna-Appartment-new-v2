import 'dart:async';
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
  bool _isPaying = false;
  bool _showSuccess = false;
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

    setState(() => _isPaying = true);

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.initiatePayment(plan['id'] as String, phone);

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
      _showSnack('Kosa: $e');
    } finally {
      setState(() => _isPaying = false);
    }
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
                _buildOption(context, Icons.phone_android, 'Mobile Money', 'Vodacom, Tigo, Airtel'),
                _buildOption(context, Icons.credit_card, 'Card', 'Visa, Mastercard'),
                const SizedBox(height: 24),
                AppTextField(label: 'Phone Number', hint: '0712345678', controller: _phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Pay Now',
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

  Widget _buildOption(BuildContext context, IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
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
