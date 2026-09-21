import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/subscription_provider.dart';

import 'package:manna_apartment/core/utils/app_toast.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  const PaymentCheckoutScreen({super.key});

  @override
  ConsumerState<PaymentCheckoutScreen> createState() =>
      _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends ConsumerState<PaymentCheckoutScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool _isPaying = false;
  bool _showSuccess = false;
  bool _showWaiting = false;
  String _paymentStatus = '';
  String _currentReference = '';
  Map<String, dynamic> _paymentResult = {};
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

  Future<void> _proceed(Map<String, dynamic> plan) async {
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
        _paymentResult = result;
      });

      final launched = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );

      if (!launched) {
        _showSnack(
            'Imeshindwa kufungua ukurasa wa malipo. Tafadhali jaribu tena.');
        setState(() => _showWaiting = false);
        return;
      }

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
        if (data['message'] is String &&
            data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              for (final msg in value) {
                messages.add(msg.toString());
              }
            }
          });
          if (messages.isNotEmpty) return messages.join('\n');
        }
      }
      return error.message ??
          'Imeshindwa kuanzisha malipo. Tafadhali jaribu tena.';
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
        _showSnack(
            'Muda wa kusubiri umekwisha. Tafadhali angalia hali ya malipo baadaye.');
        return;
      }

      try {
        final repo = ref.read(subscriptionRepositoryProvider);
        final status = await repo.verifyPayment(reference);
        final statusStr = status['status']?.toString() ?? '';

        if (mounted) {
          setState(() => _paymentStatus = statusStr);
        }

        if (statusStr == 'completed' ||
            statusStr == 'paid' ||
            statusStr == 'successful' ||
            statusStr == 'success') {
          timer.cancel();
          setState(() {
            _showWaiting = false;
            _paymentResult = status;
          });
          _showSuccessAnimation();
        } else if (statusStr == 'failed' ||
            statusStr == 'expired' ||
            statusStr == 'cancelled') {
          timer.cancel();
          setState(() => _showWaiting = false);
          _showSnack(
              'Malipo yameshindwa. Tafadhali hakikisha namba ya simu ni sahihi na jaribu tena.');
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

      if (statusStr == 'completed' ||
          statusStr == 'paid' ||
          statusStr == 'successful' ||
          statusStr == 'success') {
        _pollTimer?.cancel();
        setState(() {
          _showWaiting = false;
          _paymentResult = status;
        });
        _showSuccessAnimation();
      } else if (statusStr == 'failed' ||
          statusStr == 'expired' ||
          statusStr == 'cancelled') {
        _pollTimer?.cancel();
        setState(() => _showWaiting = false);
        _showSnack('Malipo yameshindwa.');
      } else {
        _showSnack(
            'Hali ya malipo: $statusStr. Bado subiri malipo kwenye simu yako.');
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

  void _showSnack(String message) {
    if (!mounted) return;
    AppToast.error(context, message);
  }

  String _formatPrice(dynamic price) {
    final value = (price is num ? price : num.tryParse(price.toString())) ?? 0;
    return 'TZS ${value.toStringAsFixed(0)}';
  }

  String _formatDateTime(dynamic value) {
    if (value == null) return DateTime.now().toString().substring(0, 19);
    return value.toString().substring(0, 19);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final planId =
        GoRouterState.of(context).uri.queryParameters['plan_id'] ?? '';
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
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Checkout',
          style: typography.display.md.copyWith(fontWeight: FontWeight.w700),
        ),
        leading: FButton.icon(
          variant: .ghost,
          size: .sm,
          onPress: () => context.pop(),
          child: context.theme.icons.arrowLeft(context),
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

                // Order summary
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius:
                                    context.theme.style.borderRadius.md,
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCrown,
                                  size: 22,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                planName,
                                style: typography.body.md
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                            height: 1,
                            color: colors.border.withValues(alpha: 0.6)),
                        const SizedBox(height: 12),
                        _receiptRow(colors, typography, 'Plan', planName),
                        const SizedBox(height: 10),
                        _receiptRow(colors, typography, 'Mzunguko',
                            planCycle.toString().toLowerCase()),
                        const SizedBox(height: 10),
                        _receiptRow(colors, typography, 'Kiasi',
                            _formatPrice(planPrice),
                            valueColor: colors.primary),
                        const SizedBox(height: 12),
                        Divider(
                            height: 1,
                            color: colors.border.withValues(alpha: 0.6)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumla',
                              style: typography.body.sm
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              _formatPrice(planPrice),
                              style: typography.body.lg.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FTextField(
                  control: .managed(controller: _phoneController),
                  label: const Text('Namba ya Simu ya Kulipia'),
                  hint: '0712345678 au 255712345678',
                  keyboardType: TextInputType.phone,
                  prefixBuilder: (context, style, variants) =>
                      FTextField.prefixIconBuilder(
                        context,
                        style,
                        variants,
                        const HugeIcon(
                            icon: HugeIcons.strokeRoundedSmartPhone01,
                            size: null),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Weka namba ya simu utakayolipia nayo.',
                  style: typography.body.xs3.copyWith(
                      color: colors.mutedForeground, height: 1.4),
                ),

                const SizedBox(height: 24),

                FButton(
                  variant: .primary,
                  onPress:
                      (plan.isEmpty || _isPaying) ? null : () => _proceed(plan),
                  child: _isPaying
                      ? const FCircularProgress()
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                size: null),
                            const SizedBox(width: 8),
                            const Text('Endelea kwa Malipo'),
                          ],
                        ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(planName, planPrice),
          if (_showWaiting) _buildWaitingOverlay(colors, typography),
        ],
      ),
    );
  }

  Widget _buildWaitingOverlay(FColors colors, FTypography typography) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: context.theme.style.borderRadius.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSmartPhone01,
                    size: 32,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Malipo yanaendelea',
                style:
                    typography.body.lg.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ukurasa wa malipo umefunguliwa ndani ya app. Kamilisha malipo, kisha funga huo ukurasa kurudi hapa.',
                textAlign: TextAlign.center,
                style: typography.body.xs2.copyWith(
                    color: colors.mutedForeground, height: 1.5),
              ),
              const SizedBox(height: 14),
              if (_paymentStatus.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    borderRadius: context.theme.style.borderRadius.pill,
                  ),
                  child: Text(
                    'HALI: ${_paymentStatus.toUpperCase()}',
                    style: typography.body.xs3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const FCircularProgress(),
              const SizedBox(height: 18),
              FButton(
                variant: .outline,
                size: .sm,
                onPress: _currentReference.isEmpty
                    ? null
                    : () => _checkNow(_currentReference),
                child: const Text('Angalia Hali ya Malipo'),
              ),
              const SizedBox(height: 8),
              FButton(
                variant: .ghost,
                size: .sm,
                onPress: () {
                  _pollTimer?.cancel();
                  setState(() => _showWaiting = false);
                  _showSnack(
                      'Malipo yamekatishwa. Hali ya malipo itaangaliwa baadaye.');
                },
                child: Text(
                  'Katisha',
                  style: TextStyle(color: colors.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(String planName, dynamic planPrice) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final amount = _paymentResult['amount'] ?? planPrice;
    final currency = _paymentResult['currency'] ?? 'TZS';
    final reference = _paymentResult['reference'] ?? _currentReference;
    final paidAt = _paymentResult['paid_at'] ?? DateTime.now().toIso8601String();

    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        final scale = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
        ).value;
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _successController, curve: Curves.easeIn),
        ).value;

        return Opacity(
          opacity: opacity,
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: context.theme.style.borderRadius.lg,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF16A34A),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Malipo Yamekamilika!',
                          style: typography.body.lg
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Subscription yako imewashwa kikamilifu.',
                          textAlign: TextAlign.center,
                          style: typography.body.xs2
                              .copyWith(color: colors.mutedForeground),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.secondary.withValues(alpha: 0.5),
                            borderRadius:
                                context.theme.style.borderRadius.md,
                          ),
                          child: Column(
                            children: [
                              _receiptRow(colors, typography, 'Plan', planName),
                              const SizedBox(height: 12),
                              _receiptRow(colors, typography, 'Kiasi',
                                  '$currency ${_formatPrice(amount).replaceAll('TZS ', '')}'),
                              const SizedBox(height: 12),
                              _receiptRow(colors, typography, 'Namba ya Rufaa',
                                  reference.toString().substring(
                                      0,
                                      reference.toString().length > 20
                                          ? 20
                                          : reference.toString().length)),
                              const SizedBox(height: 12),
                              _receiptRow(colors, typography, 'Tarehe',
                                  _formatDateTime(paidAt)),
                              const SizedBox(height: 12),
                              _receiptRow(colors, typography, 'Hali',
                                  'Imekamilika',
                                  valueColor: const Color(0xFF16A34A)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        FButton(
                          variant: .primary,
                          onPress: () {
                            _pollTimer?.cancel();
                            context.go('/landlord/subscription');
                          },
                          child: const Text('Endelea kwa Subscription'),
                        ),
                        const SizedBox(height: 8),
                        FButton(
                          variant: .ghost,
                          size: .sm,
                          onPress: () {
                            _pollTimer?.cancel();
                            context.go('/landlord/subscription/invoices');
                          },
                          child: const Text('Angalia Invoices'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _receiptRow(FColors colors, FTypography typography, String label,
      String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              typography.body.xs2.copyWith(color: colors.mutedForeground),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: typography.body.xs2.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? colors.foreground,
            ),
          ),
        ),
      ],
    );
  }
}
