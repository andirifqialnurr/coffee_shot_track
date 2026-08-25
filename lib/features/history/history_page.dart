import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/espresso_shot.dart';
import '../../shared/widgets/shot_ui.dart';
import '../shots/shot_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? _beanId;
  int? _rating;
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final filtered = store.shots.where(_matchesFilter).toList();

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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
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
            if (store.shots.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Belum ada riwayat',
                  subtitle: 'Shot yang Anda catat akan muncul di sini.',
                ),
              )
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'No matching shots',
                  subtitle: 'Try a different bean, rating, or date filter.',
                  ctaLabel: 'Clear filters',
                  onCta: () => setState(() {
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
                    final shot = filtered[index];
                    return ShotRow(
                      shot: shot,
                      beanName: store.beanById(shot.beanId)?.name ?? '-',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ShotDetailPage(shotId: shot.id!),
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

  bool _matchesFilter(EspressoShot shot) {
    if (_beanId != null && shot.beanId != _beanId) {
      return false;
    }
    if (_rating != null && shot.rating != _rating) {
      return false;
    }
    if (_date != null &&
        (shot.brewedAt.year != _date!.year ||
            shot.brewedAt.month != _date!.month ||
            shot.brewedAt.day != _date!.day)) {
      return false;
    }
    return true;
  }
}
