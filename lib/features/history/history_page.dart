import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_order.dart';
import '../../shared/widgets/shot_ui.dart';
import '../orders/order_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? _menuId;
  int? _cafeId;
  int? _beanId;
  int? _rating;
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final filtered = store.orders.where(_matchesFilter).toList();

      return Scaffold(
        backgroundColor: colors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'History',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    ShotIconAction(
                      tooltip: 'Date filter',
                      icon: Icons.calendar_today_outlined,
                      onPressed: () => _pickDate(context),
                    ),
                    ShotIconAction(
                      tooltip: 'Clear filters',
                      icon: Icons.filter_alt_off_outlined,
                      onPressed: () => setState(() {
                        _menuId = null;
                        _cafeId = null;
                        _beanId = null;
                        _rating = null;
                        _date = null;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    FilterPill(
                      label: 'Semua Menu',
                      selected: _menuId == null,
                      onTap: () => setState(() => _menuId = null),
                    ),
                    const SizedBox(width: 8),
                    for (final menu in store.menus)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterPill(
                          label: menu.name,
                          selected: _menuId == menu.id,
                          onTap: () => setState(() => _menuId = menu.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterPill(
                        label: 'Semua Cafe',
                        selected: _cafeId == null,
                        onTap: () => setState(() => _cafeId = null),
                      ),
                      const SizedBox(width: 8),
                      for (final cafe in store.cafes)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterPill(
                            label: cafe.name,
                            selected: _cafeId == cafe.id,
                            onTap: () => setState(() => _cafeId = cafe.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterPill(
                        label: 'Semua Bean',
                        selected: _beanId == null,
                        onTap: () => setState(() => _beanId = null),
                      ),
                      const SizedBox(width: 8),
                      for (final bean in store.beans)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterPill(
                            label: bean.name,
                            selected: _beanId == bean.id,
                            onTap: () => setState(() => _beanId = bean.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterPill(
                        label: 'Semua Rating',
                        selected: _rating == null,
                        onTap: () => setState(() => _rating = null),
                      ),
                      const SizedBox(width: 8),
                      for (var rating = 5; rating >= 1; rating--)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterPill(
                            label: '$rating star',
                            selected: _rating == rating,
                            onTap: () => setState(() => _rating = rating),
                          ),
                        ),
                      if (_date != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: FilterPill(
                            label: formatShortDate(_date!),
                            selected: true,
                            icon: Icons.calendar_today_outlined,
                            onTap: () => setState(() => _date = null),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (store.orders.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Belum ada riwayat',
                  subtitle: 'Order yang Anda catat akan muncul di sini.',
                ),
              )
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'No matching orders',
                  subtitle: 'Try a different menu, cafe, bean, rating, or date.',
                  ctaLabel: 'Clear filters',
                  onCta: () => setState(() {
                    _menuId = null;
                    _cafeId = null;
                    _beanId = null;
                    _rating = null;
                    _date = null;
                  }),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final menu = store.menuById(order.menuId);
                    final cafe = store.cafeById(order.cafeId);
                    final bean = order.beanId == null
                        ? null
                        : store.beanById(order.beanId!);
                    return _OrderHistoryRow(
                      order: order,
                      menuName: menu?.name ?? 'Unknown menu',
                      cafeName: cafe?.name ?? 'Unknown cafe',
                      beanName: bean?.name,
                      imagePath: order.imagePath ?? menu?.imagePath,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => OrderDetailPage(orderId: order.id!),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: _date ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  bool _matchesFilter(CoffeeOrder order) {
    if (_menuId != null && order.menuId != _menuId) {
      return false;
    }
    if (_cafeId != null && order.cafeId != _cafeId) {
      return false;
    }
    if (_beanId != null && order.beanId != _beanId) {
      return false;
    }
    if (_rating != null && order.rating != _rating) {
      return false;
    }
    if (_date != null &&
        (order.orderedAt.year != _date!.year ||
            order.orderedAt.month != _date!.month ||
            order.orderedAt.day != _date!.day)) {
      return false;
    }
    return true;
  }
}

String _formatCurrency(double value) {
  final rounded = value.round();
  final raw = rounded.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp$buffer';
}

class _OrderHistoryRow extends StatelessWidget {
  const _OrderHistoryRow({
    required this.order,
    required this.menuName,
    required this.cafeName,
    required this.onTap,
    this.beanName,
    this.imagePath,
  });

  final CoffeeOrder order;
  final String menuName;
  final String cafeName;
  final String? beanName;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            ShotImageTile(
              label: menuName,
              icon: Icons.local_cafe_outlined,
              imagePath: imagePath,
              width: 54,
              height: 54,
              radius: 13,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    beanName == null ? cafeName : '$cafeName - $beanName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatDateTime(order.orderedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (order.price != null)
                  Text(
                    _formatCurrency(order.price!),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  )
                else
                  Icon(
                    order.isFavorite
                        ? Icons.star_rounded
                        : Icons.chevron_right_rounded,
                    size: 18,
                    color:
                        order.isFavorite ? colors.accent : colors.textSecondary,
                  ),
                const SizedBox(height: 5),
                if (order.rating != null)
                  StarRating(rating: order.rating!, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
