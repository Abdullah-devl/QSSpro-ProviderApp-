// ???? ?????: lib/features/commissions/views/pay_commissions_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
// import '../../profile/models/profile_model.dart';
import '../viewmodels/pay_commissions_viewmodel.dart';
import 'widgets/reward_points_card.dart';
import 'widgets/payment_method_option_widget.dart';
import 'widgets/total_due_commission_card.dart';
import 'pay_with_points_view.dart';
import 'pay_with_receipt_view.dart';

class PayCommissionsView extends StatefulWidget {
  final double amount;
  final String? orderId;

  const PayCommissionsView({
    super.key,
    required this.amount,
    this.orderId,
  });

  @override
  State<PayCommissionsView> createState() => _PayCommissionsViewState();
}

class _PayCommissionsViewState extends State<PayCommissionsView> {
  @override
  void initState() {
    super.initState();
    // ??? ???????? ??? ????? ?????? ???????? ??? userId ????? ?????????
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = context.read<ProfileViewModel>();
      final userId = profileViewModel.profile?.id ?? 0;
      context.read<PayCommissionsViewModel>().fetchCommissionsData(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PayCommissionsViewModel>(context);
    final Color bgColor = context.qsColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('pay_commissions'),
          style: TextStyle(
            color: context.qsColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: context.qsColors.text),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        leading: const SizedBox.shrink(),
      ),
      body: viewModel.isLoading && viewModel.commissionData == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. ????? ?????? ??????? ????????
                      TotalDueCommissionCard(amount: widget.amount),
                      const SizedBox(height: 16),

                      // 2. ????? ???? ???????? (???????????)
                      RewardPointsCard(
                        pointsBalance:
                            viewModel.commissionData?.summary.bonusPoints ??
                            0,
                      ),
                      const SizedBox(height: 32),

                      // 3. ??? ????? ????? ??????
                      Text(
                        context.tr('select_payment_method'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.qsColors.text,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 16),

                      PaymentMethodOptionWidget(
                        title: context.tr('pay_by_receipt'),
                        subtitle: context.tr('receipt_upload_subtitle'),
                        iconData: Icons.attach_file_rounded,
                        iconColor: context.qsColors.textSub,
                        isSelected:
                            viewModel.selectedMethod ==
                            PaymentMethodType.bankTransfer,
                        onTap: () => viewModel.changePaymentMethod(
                          PaymentMethodType.bankTransfer,
                        ),
                      ),
                      PaymentMethodOptionWidget(
                        title: context.tr('pay_by_points'),
                        subtitle: context.tr('pay_points_subtitle'),
                        iconData: Icons.card_giftcard_rounded,
                        iconColor: context.qsColors.warning,
                        isSelected:
                            viewModel.selectedMethod ==
                            PaymentMethodType.rewardPoints,
                        onTap: () => viewModel.changePaymentMethod(
                          PaymentMethodType.rewardPoints,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (viewModel.selectedMethod ==
                            PaymentMethodType.rewardPoints) {
                          // ????? ??? ??????? ?? ??? ???? ???????? null ????????? ?? ??? ??????
                          // ??????? ??? ???????? ??? ?? ???? ??? API ?? ??? ????????
                          final summary = viewModel.commissionData?.summary;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PayWithPointsView(
                                amount: widget.amount,
                                userId: context.read<ProfileViewModel>().profile?.id ?? 0,
                                bonusPoints: summary?.bonusPoints ?? 0,
                                paidPoints: summary?.paidPoints ?? 0,
                                availablePoints: (summary?.bonusPoints ?? 0) + (summary?.paidPoints ?? 0),
                                equivalentPoints: widget.amount.toInt(),
                                orderId: widget.orderId,
                              ),
                            ),
                          );
                        } else if (viewModel.selectedMethod ==
                            PaymentMethodType.bankTransfer) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PayWithReceiptView(
                                orderId: widget.orderId,
                                amount: widget.amount,
                              ),
                            ),
                          );
                        }
                      },
                      // onPressed: () {
                      //   if (viewModel.selectedMethod ==
                      //       PaymentMethodType.rewardPoints) {
                      //     // ?????? ?? ???? ???????? ??? ????????
                      //     final summary = viewModel.commissionData?.summary;
                      //     if (summary != null) {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (_) => PayWithPointsView(
                      //             amount: widget.amount,
                      //             availablePoints: summary.availablePoints,
                      //             equivalentPoints:
                      //                 (widget.amount *
                      //                         summary.pointsConversionFactor)
                      //                     .toInt(),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   } else if (viewModel.selectedMethod ==
                      //       PaymentMethodType.bankTransfer) {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (_) => const PayWithReceiptView(),
                      //       ),
                      //     );
                      //   }
                      // },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.qsColors.primary,
                        foregroundColor: context.qsColors.card,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('submit_payment'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.payments_outlined, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}



