import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_order.dart';
import '../../shared/widgets/shot_ui.dart';
import '../orders/order_detail_page.dart';
import '../orders/order_form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onNewShot,
    required this.onShowHistory,
    required this.onShowBeans,
    required this.onShowInsights,
    required this.onShowSettings,
  });

  final VoidCallback onNewShot;
  final VoidCallback onShowHistory;
  final VoidCallback onShowBeans;
  final VoidCallback onShowInsights;
  final VoidCallback onShowSettings;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      if (store.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final lastOrders = store.recentOrders.take(2).toList();

      return ShotPageFrame(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greetingLabel(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Shot',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ShotIconAction(
                          tooltip: 'Insights',
                          icon: Icons.insights_rounded,
                          onPressed: onShowInsights,
                        ),
                        ShotIconAction(
                          tooltip: 'Settings',
                          icon: Icons.settings_outlined,
                          onPressed: onShowSettings,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionLabel(
                  'Last Orders',
                  fontSize: 14,
                  trailing: TextButton(
                    onPressed: onShowHistory,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 28),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    child: const Text('See all'),
                  ),
                ),
              ),
            ),
            if (lastOrders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: EmptyState(
                    icon: Icons.local_cafe_outlined,
                    title: 'Belum ada order',
                    subtitle: 'Catat menu kopi pertama Anda.',
                    ctaLabel: 'New Order',
                    onCta: onNewShot,
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 214,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: lastOrders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final order = lastOrders[index];
                      return SizedBox(
                        width: 274,
                        child: _HomeOrderCard(
                          order: order,
                          menuName: store.menuById(order.menuId)?.name ?? '-',
                          imagePath: order.imagePath ??
                              store.menuById(order.menuId)?.imagePath,
                          cafeName: store.cafeById(order.cafeId)?.name ?? '-',
                          beanName: order.beanId == null
                              ? null
                              : store.beanById(order.beanId!)?.name,
                            onOrderAgain: index == 0
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => OrderFormPage(
                                        initialOrder:
                                            order.duplicateForOrderAgain(),
                                      ),
                                    ),
                                  )
                              : null,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  OrderDetailPage(orderId: order.id!),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      );
    });
  }
}

class _HomeOrderCard extends StatelessWidget {
  const _HomeOrderCard({
    required this.order,
    required this.menuName,
    this.imagePath,
    required this.cafeName,
    required this.onTap,
    this.beanName,
    this.onOrderAgain,
  });

  final CoffeeOrder order;
  final String menuName;
  final String? imagePath;
  final String cafeName;
  final String? beanName;
  final VoidCallback onTap;
  final VoidCallback? onOrderAgain;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final notes = order.tastingNotes?.trim();
    final ratio = order.ratio;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShotImageTile(
              label: menuName,
              icon: Icons.local_cafe_outlined,
              imagePath: imagePath,
              height: 66,
              radius: 12,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    menuName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (order.rating != null)
                  StarRating(rating: order.rating!, size: 13),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                cafeName,
                if (beanName != null) beanName,
              ].join(' * '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              formatHumanDate(order.orderedAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                if (ratio != null)
                  Text(
                    '1 : ${ratio.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                  )
                else
                  Text(
                    'Coffee order',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                const Spacer(),
                if (onOrderAgain != null)
                  TextButton.icon(
                    onPressed: onOrderAgain,
                    icon: const Icon(Icons.replay_rounded, size: 14),
                    label: const Text('Order Again'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String greetingLabel() {
  final hour = DateTime.now().hour;
  if (hour < 11) {
    return 'Selamat pagi';
  }
  if (hour < 15) {
    return 'Selamat siang';
  }
  if (hour < 18) {
    return 'Selamat sore';
  }
  return 'Selamat malam';
}
