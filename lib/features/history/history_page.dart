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
      final filtered = store.shots.where(_matchesFilter).toList();

      return ShotPage(
        title: 'History',
        subtitle: 'Compare shots by bean, rating, and brew date.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShotCard(
              child: Column(
                children: [
                  DropdownButtonFormField<int?>(
                    initialValue: _beanId,
                    decoration: const InputDecoration(
                      labelText: 'Bean filter',
                      prefixIcon: Icon(Icons.coffee_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All beans'),
                      ),
                      for (final bean in store.beans)
                        DropdownMenuItem<int?>(
                          value: bean.id,
                          child: Text(bean.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _beanId = value),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: _rating,
                          decoration: const InputDecoration(
                            labelText: 'Rating',
                            prefixIcon: Icon(Icons.star_outline),
                          ),
                          items: const [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Any'),
                            ),
                            DropdownMenuItem(value: 5, child: Text('5')),
                            DropdownMenuItem(value: 4, child: Text('4+')),
                            DropdownMenuItem(value: 3, child: Text('3+')),
                          ],
                          onChanged: (value) => setState(() => _rating = value),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              initialDate: _date ?? DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _date = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            _date == null ? 'Any date' : formatShortDate(_date!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _beanId = null;
                        _rating = null;
                        _date = null;
                      }),
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      label: const Text('Clear filters'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (store.shots.isEmpty)
              const EmptyState(
                icon: Icons.history_outlined,
                title: 'No shots yet',
                message: 'Saved shots will appear in chronological order.',
              )
            else if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.search_off_outlined,
                title: 'No matching shots',
                message: 'Try a different bean, rating, or date filter.',
              )
            else
              ShotCard(
                child: Column(
                  children: [
                    for (final shot in filtered)
                      ShotListTile(
                        shot: shot,
                        bean: store.beanById(shot.beanId),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ShotDetailPage(shotId: shot.id!),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  bool _matchesFilter(EspressoShot shot) {
    if (_beanId != null && shot.beanId != _beanId) {
      return false;
    }
    if (_rating != null && (shot.rating ?? 0) < _rating!) {
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
