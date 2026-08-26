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
      final hasActiveFilters = _hasActiveFilters;

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
                      tooltip: 'Filter History',
                      icon: Icons.tune_rounded,
                      selected: hasActiveFilters,
                      onPressed: () => _showFilterSheet(context, store),
                    ),
                    if (hasActiveFilters)
                      ShotIconAction(
                        tooltip: 'Clear filters',
                        icon: Icons.filter_alt_off_outlined,
                        onPressed: _clearFilters,
                      ),
                  ],
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

  bool get _hasActiveFilters {
    return _menuId != null ||
        _cafeId != null ||
        _beanId != null ||
        _rating != null ||
        _date != null;
  }

  void _clearFilters() {
    setState(() {
      _menuId = null;
      _cafeId = null;
      _beanId = null;
      _rating = null;
      _date = null;
    });
  }

  Future<void> _showFilterSheet(
    BuildContext context,
    ShotController store,
  ) async {
    final result = await showModalBottomSheet<_HistoryFilterValue>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryFilterSheet(
        store: store,
        initial: _HistoryFilterValue(
          menuId: _menuId,
          cafeId: _cafeId,
          beanId: _beanId,
          rating: _rating,
          date: _date,
        ),
      ),
    );
    if (result == null) {
      return;
    }

    setState(() {
      _menuId = result.menuId;
      _cafeId = result.cafeId;
      _beanId = result.beanId;
      _rating = result.rating;
      _date = result.date;
    });
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

class _HistoryFilterValue {
  const _HistoryFilterValue({
    this.menuId,
    this.cafeId,
    this.beanId,
    this.rating,
    this.date,
  });

  final int? menuId;
  final int? cafeId;
  final int? beanId;
  final int? rating;
  final DateTime? date;
}

class _HistoryFilterSheet extends StatefulWidget {
  const _HistoryFilterSheet({
    required this.store,
    required this.initial,
  });

  final ShotController store;
  final _HistoryFilterValue initial;

  @override
  State<_HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<_HistoryFilterSheet> {
  late int? _menuId = widget.initial.menuId;
  late int? _cafeId = widget.initial.cafeId;
  late int? _beanId = widget.initial.beanId;
  late int? _rating = widget.initial.rating;
  late DateTime? _date = widget.initial.date;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.84;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ShotIconAction(
                      tooltip: 'Close filters',
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilterGroup(
                          label: 'Menu',
                          child: _FilterWrap(
                            children: [
                              FilterPill(
                                label: 'All Menus',
                                selected: _menuId == null,
                                onTap: () => setState(() => _menuId = null),
                              ),
                              for (final menu in widget.store.menus)
                                FilterPill(
                                  label: menu.name,
                                  selected: _menuId == menu.id,
                                  onTap: () => setState(() => _menuId = menu.id),
                                ),
                            ],
                          ),
                        ),
                        _FilterGroup(
                          label: 'Cafe',
                          child: _FilterWrap(
                            children: [
                              FilterPill(
                                label: 'All Cafes',
                                selected: _cafeId == null,
                                onTap: () => setState(() => _cafeId = null),
                              ),
                              for (final cafe in widget.store.cafes)
                                FilterPill(
                                  label: cafe.name,
                                  selected: _cafeId == cafe.id,
                                  onTap: () => setState(() => _cafeId = cafe.id),
                                ),
                            ],
                          ),
                        ),
                        _FilterGroup(
                          label: 'Bean',
                          child: _FilterWrap(
                            children: [
                              FilterPill(
                                label: 'All Beans',
                                selected: _beanId == null,
                                onTap: () => setState(() => _beanId = null),
                              ),
                              for (final bean in widget.store.beans)
                                FilterPill(
                                  label: bean.name,
                                  selected: _beanId == bean.id,
                                  onTap: () => setState(() => _beanId = bean.id),
                                ),
                            ],
                          ),
                        ),
                        _FilterGroup(
                          label: 'Rating',
                          child: _FilterWrap(
                            children: [
                              FilterPill(
                                label: 'All Ratings',
                                selected: _rating == null,
                                onTap: () => setState(() => _rating = null),
                              ),
                              for (var rating = 5; rating >= 1; rating--)
                                FilterPill(
                                  label: '$rating star',
                                  selected: _rating == rating,
                                  onTap: () =>
                                      setState(() => _rating = rating),
                                ),
                            ],
                          ),
                        ),
                        _FilterGroup(
                          label: 'Date',
                          child: _FilterWrap(
                            children: [
                              FilterPill(
                                label: _date == null
                                    ? 'Any Date'
                                    : formatShortDate(_date!),
                                selected: _date != null,
                                icon: Icons.calendar_today_outlined,
                                onTap: _pickDate,
                              ),
                              if (_date != null)
                                FilterPill(
                                  label: 'Clear Date',
                                  selected: false,
                                  icon: Icons.close_rounded,
                                  onTap: () => setState(() => _date = null),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Clear',
                        icon: Icons.filter_alt_off_outlined,
                        onPressed: () => setState(() {
                          _menuId = null;
                          _cafeId = null;
                          _beanId = null;
                          _rating = null;
                          _date = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Apply',
                        icon: Icons.check_rounded,
                        onPressed: () => Navigator.of(context).pop(
                          _HistoryFilterValue(
                            menuId: _menuId,
                            cafeId: _cafeId,
                            beanId: _beanId,
                            rating: _rating,
                            date: _date,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
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
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label, fontSize: 12),
          child,
        ],
      ),
    );
  }
}

class _FilterWrap extends StatelessWidget {
  const _FilterWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children,
    );
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
