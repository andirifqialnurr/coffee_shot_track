import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_order.dart';
import '../../shared/widgets/shot_ui.dart';
import 'order_form_page.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final order = store.orders.where((item) => item.id == orderId).firstOrNull;
      if (order == null) {
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(title: const Text('Order')),
          body: const EmptyState(
            icon: Icons.delete_outline_rounded,
            title: 'Order sudah dihapus',
            subtitle: 'Data order ini tidak lagi tersedia.',
          ),
        );
      }

      final menu = store.menuById(order.menuId);
      final cafe = store.cafeById(order.cafeId);
      final bean = order.beanId == null ? null : store.beanById(order.beanId!);

      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Order Detail'),
          actions: [
            ShotIconAction(
              tooltip:
                  order.isFavorite ? 'Remove Favorite' : 'Set Favorite',
              onPressed: () => store.toggleOrderFavorite(order),
              icon: order.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              selected: order.isFavorite,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
          children: [
            ShotCard(
              radius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShotImagePlaceholder(
                    label: menu?.name ?? 'Coffee order',
                    icon: Icons.local_cafe_outlined,
                    height: 130,
                    radius: 16,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    menu?.name ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      cafe?.name ?? '-',
                      if (bean != null) bean.name,
                    ].join(' * '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDateTime(order.orderedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (order.price != null) ...[
                    const SizedBox(height: 10),
                    UnitChip('Rp ${formatNumber(order.price!)}'),
                  ],
                ],
              ),
            ),
            const SectionLabel('Rating & Notes'),
            ShotCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.rating != null)
                    StarRating(rating: order.rating!, size: 22)
                  else
                    Text(
                      'Belum diberi rating',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if ((order.tastingNotes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      order.tastingNotes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            if (_hasAdvanced(order)) ...[
              const SectionLabel('Advanced Brewing'),
              ShotCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (order.doseG != null)
                      UnitChip('Dose ${formatNumber(order.doseG!)}g'),
                    if (order.yieldG != null)
                      UnitChip('Yield ${formatNumber(order.yieldG!)}g'),
                    if (order.extractionSec != null)
                      UnitChip('${order.extractionSec}s'),
                    if (order.temperatureC != null)
                      UnitChip('${formatNumber(order.temperatureC!)} C'),
                    if ((order.grindSetting ?? '').isNotEmpty)
                      UnitChip('Grind ${order.grindSetting}'),
                    if (order.ratio != null)
                      UnitChip('1 : ${order.ratio!.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: 'Order Again',
                  icon: Icons.replay_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OrderFormPage(
                        initialOrder: order.duplicateForOrderAgain(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OrderFormPage(initialOrder: order),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        danger: true,
                        onPressed: () => _confirmDelete(context, order),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirmDelete(BuildContext context, CoffeeOrder order) async {
    final store = Get.find<ShotController>();
    final colors = shotColors(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus order ini?'),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Data order akan hilang permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Hapus', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.deleteOrder(order);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

bool _hasAdvanced(CoffeeOrder order) {
  return order.doseG != null ||
      order.yieldG != null ||
      order.extractionSec != null ||
      order.temperatureC != null ||
      (order.grindSetting ?? '').isNotEmpty ||
      order.ratio != null;
}
