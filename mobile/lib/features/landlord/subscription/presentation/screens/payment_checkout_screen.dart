import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
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
  String _paymentStatus = '';
  String _currentReference = '';
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

  String _normalizePhone(String phone) {
    var p = phone.trim();
    if (p.startsWith('+')) p = p.substring(1);
    p = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('255')) return p;
    if (p.startsWith('0')) return '255${p.substring(1)}';
    if (p.length == 9) return '255$p';
    return p;
  }

  Future<void> _pay(Map<String, dynamic> plan) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Weka namba ya simu ya kulipia.');
      return;
    }

    final normalizedPhone = _normalizePhone(phone);

    setState(() {
      _isPaying = true;
      _showWaiting = false;
      _paymentStatus = '';
    });

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.initiateCheckout(
        plan['id'] as String,
        normalizedPhone,
      );

      final checkoutUrl = result['checkout_url'] as String?;
      final providerReference = result['provider_reference'] as String?;
      final reference = result['reference'] as String?;

      if (checkoutUrl == null) {
        _showSnack('Imeshindwa kupata link ya malipo. Tafadhali jaribu tena.');
        return;
      }

      final paymentRef = providerReference ?? reference ?? '';
      setState(() {
        _isPaying = false;
        _showWaiting = true;
        _paymentStatus = 'pending';
        _currentReference = paymentRef;
      });

      // Open checkout URL in browser
      final launched = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showSnack('Imeshindwa kufungua ukurasa wa malipo. Tafadhali jaribu tena.');
        setState(() => _showWaiting = false);
        return;
      }

      // Start polling for payment status after browser opens
      if (paymentRef.isNotEmpty) {
        _startPolling(paymentRef);
      }
    } catch (e) {
      final message = _extractErrorMessage(e);
      _showSnack(message);
    } finally {
      if (mounted) setState(() => _isPaying = false);
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

      if (_pollAttempts > 24) {
        timer.cancel();
        setState(() => _showWaiting = false);
        _showSnack('Muda wa kusubiri umekwisha. Tafadhali angalia hali ya malipo baadaye.');
        return;
      }

      try {
        final repo = ref.read(subscriptionRepositoryProvider);
        final status = await repo.verifyPayment(reference);
        final statusStr = status['status']?.toString() ?? '';

        if (mounted) {
          setState(() => _paymentStatus = statusStr);
        }

        if (statusStr == 'completed' || statusStr == 'paid' || statusStr == 'successful' || statusStr == 'success') {
          timer.cancel();
          setState(() => _showWaiting = false);
          _showSuccessAnimation();
        } else if (statusStr == 'failed' || statusStr == 'expired' || statusStr == 'cancelled') {
          timer.cancel();
          setState(() => _showWaiting = false);
          _showSnack('Malipo yameshindwa. Huenda USSD push haikufika kwenye simu yako. Tafadhali hakikisha namba ya simu ni sahihi na jaribu tena.');
        }
      } catch (e) {
        // ignore polling errors
      }
    });
  }

  Future<void> _checkNow(String reference) async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final status = await repo.verifyPayment(reference);
      final statusStr = status['status']?.toString() ?? '';

      if (mounted) setState(() => _paymentStatus = statusStr);

      if (statusStr == 'completed' || statusStr == 'paid' || statusStr == 'successful' || statusStr == 'success') {
        _pollTimer?.cancel();
        setState(() => _showWaiting = false);
        _showSuccessAnimation();
      } else if (statusStr == 'failed' || statusStr == 'expired' || statusStr == 'cancelled') {
        _pollTimer?.cancel();
        setState(() => _showWaiting = false);
        _showSnack('Malipo yameshindwa.');
      } else {
        _showSnack('Hali ya malipo: $statusStr. Bado subiri USSD kwenye simu yako.');
      }
    } catch (e) {
      _showSnack('Imeshindwa kuangalia hali ya malipo. Tafadhali subiri.');
    }
  }

  void _showSuccessAnimation() {
    ref.invalidate(currentPlanProvider);
    ref.invalidate(subscriptionInvoicesProvider);
    setState(() => _showSuccess = true);
    _successController.forward();
  }

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? AppColors.error,
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
    final planFeatures = (plan['features_json'] as List<dynamic>? ?? (plan['features'] as List<dynamic>? ?? []));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Checkout',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: AppColors.textDark, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Order Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Muhtasari wa Oda',
                        style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  planName,
                                  style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatPrice(planPrice)} / ${planCycle.toLowerCase()}',
                                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (planFeatures.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 12),
                        ...planFeatures.take(4).map((f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  f.toString(),
                                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Method Section
                Text(
                  'Njia ya Malipo',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_android_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mobile Money',
                              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'M-Pesa, Tigo Pesa, Airtel Money, Halopesa',
                              style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Phone Input
                Text(
                  'Namba ya Simu ya Kulipia',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: '0712345678 au 255712345678',
                      hintStyle: GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 12),
                        child: Icon(Icons.phone_rounded, color: AppColors.primary, size: 22),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Utapokea ombi la malipo kwenye simu hii baada ya kufungua ukurasa wa malipo. Ingiza PIN yako ya mobile money kukamilisha.',
                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textLight, height: 1.4),
                ),

                const SizedBox(height: 28),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (plan.isEmpty || _isPaying) ? null : () => _pay(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isPaying
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Lipa ${_formatPrice(planPrice)}',
                                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Security note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: Color(0xFF16A34A), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Malipo yako yanalindwa kupitia Snippe Payment Gateway. Simu yako itapokea USSD push kwa usalama.',
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF15803D), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
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
      color: Colors.black.withValues(alpha: 0.75),
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
              // Animated phone icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_in_browser_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Malipo yanaendelea',
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ukurasa wa malipo umefunguliwa kwenye browser. Kamilisha malipo hapo, kisha rudi kwenye app kuangalia hali.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLight, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Status badge
              if (_paymentStatus.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Hali: ${_paymentStatus.toUpperCase()}',
                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning),
                  ),
                ),

              const SizedBox(height: 20),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),

              // Check status button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: _currentReference.isEmpty ? null : () => _checkNow(_currentReference),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Angalia Hali ya Malipo',
                    style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _pollTimer?.cancel();
                  setState(() => _showWaiting = false);
                  _showSnack('Malipo yamekatishwa. Hali ya malipo itaangaliwa baadaye.');
                },
                child: Text(
                  'Katisha',
                  style: GoogleFonts.nunito(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 13),
                ),
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
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
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
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Malipo yamekamilika!',
                      style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subscription yako sasa imewashwa. Asante.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textLight),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _pollTimer?.cancel();
                          context.go('/landlord/subscription');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Endelea',
                          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
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
