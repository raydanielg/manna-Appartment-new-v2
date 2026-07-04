import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  String? _selectedPlanId;
  bool _isPaying = false;
  bool _showSuccess = false;
  String? _reference;
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

  void _onPlanSelected(String planId) {
    setState(() => _selectedPlanId = planId);
  }

  Future<void> _pay() async {
    if (_selectedPlanId == null) {
      _showSnack('Chagua kwanza mpango wa malipo.');
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Weka namba ya simu ya kulipia.');
      return;
    }

    setState(() => _isPaying = true);

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.initiatePayment(_selectedPlanId!, phone);

      final checkoutUrl = result['checkout_url'] as String?;
      final providerReference = result['provider_reference'] as String?;
      _reference = result['reference'] as String?;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        _showSnack('Imeshindwa kuanzisha malipo. Jaribu tena.');
        return;
      }

      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      _startPolling(providerReference ?? _reference!);
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
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentAsync = ref.watch(currentPlanProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentPlan(currentAsync),
                const SizedBox(height: 24),
                Text(
                  'Chagua mpango',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                plansAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => Text('Kosa: $e', style: TextStyle(color: AppColors.error)),
                  data: (plans) => Column(
                    children: plans.map<Widget>((plan) => _buildPlanCard(plan, isDark)).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Namba ya simu ya kulipia',
                  hint: 'mfano 0712345678',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Lipa sasa',
                  isLoading: _isPaying,
                  onPressed: _pay,
                ),
              ],
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlan(AsyncValue<Map<String, dynamic>> currentAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return currentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (plan) {
        if (plan.isEmpty || plan['plan'] == null) return const SizedBox.shrink();
        final p = plan['plan'] as Map<String, dynamic>? ?? {};
        final endDate = plan['end_date'] ?? '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mpango uliopo',
                style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                p['name'] ?? 'Subscription',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
              ),
              Text(
                'Mwisho: $endDate',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(dynamic plan, bool isDark) {
    final id = plan['id'] as String? ?? '';
    final name = plan['name'] as String? ?? 'Plan';
    final price = plan['price'] ?? 0;
    final cycle = plan['billing_cycle'] as String? ?? 'monthly';
    final selected = _selectedPlanId == id;

    return GestureDetector(
      onTap: () => _onPlanSelected(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.gold : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.gold : (isDark ? AppColors.darkInput : Colors.grey.shade200),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark),
                  ),
                  Text(
                    '${_formatPrice(price)} / $cycle',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textLight),
                  ),
                ],
              ),
            ),
          ],
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
