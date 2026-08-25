import 'package:flutter/material.dart';

import '../../app/shot_scope.dart';
import '../../app/shot_theme.dart';
import '../../domain/coffee_bean.dart';
import '../../domain/shot_metrics.dart' as metrics;
import '../../shared/widgets/shot_ui.dart';
import '../shots/shot_detail_page.dart';
import '../shots/shot_form_page.dart';

class BeansPage extends StatefulWidget {
  const BeansPage({super.key});

  @override
  State<BeansPage> createState() => _BeansPageState();
}

class _BeansPageState extends State<BeansPage> {
  String _query = '';
  BeanStatus? _filter = BeanStatus.active;

  @override
  Widget build(BuildContext context) {
    final store = ShotScope.of(context);
    final colors = Theme.of(context).extension<ShotColors>()!;
    final beans = store.beans.where((bean) {
      final matchesQuery = _query.trim().isEmpty ||
          [
            bean.name,
            bean.roaster,
            bean.origin,
            bean.process,
            bean.roastLevel,
          ].whereType<String>().any(
                (value) => value.toLowerCase().contains(_query.toLowerCase()),
              );
      final matchesStatus = _filter == null || bean.status == _filter;
      return matchesQuery && matchesStatus;
    }).toList();

    return ShotPage(
      title: 'Beans',
      subtitle: 'Track the coffee behind each recipe.',
      actions: [
        IconButton.filled(
          tooltip: 'Add Bean',
          onPressed: () => showBeanFormSheet(context),
          icon: const Icon(Icons.add),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search beans',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              ChoiceChip(
                label: const Text('Active'),
                selected: _filter == BeanStatus.active,
                onSelected: (_) => setState(() => _filter = BeanStatus.active),
              ),
              ChoiceChip(
                label: const Text('Finished'),
                selected: _filter == BeanStatus.finished,
                onSelected: (_) =>
                    setState(() => _filter = BeanStatus.finished),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (store.beans.isEmpty)
            EmptyState(
              icon: Icons.coffee_outlined,
              title: 'Start with beans',
              message: 'Add name, roaster, roast level, and notes.',
              action: FilledButton.icon(
                onPressed: () => showBeanFormSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Bean'),
              ),
            )
          else if (beans.isEmpty)
            EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: 'No beans match',
              message: 'Clear search or switch the status filter.',
              action: OutlinedButton(
                onPressed: () => setState(() {
                  _query = '';
                  _filter = null;
                }),
                child: const Text('Clear filter'),
              ),
            )
          else
            Column(
              children: [
                for (final bean in beans) ...[
                  ShotCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BeanDetailPage(beanId: bean.id!),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors.caramel.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.coffee),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bean.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    [
                                      bean.roaster,
                                      bean.roastLevel,
                                      bean.origin,
                                    ].whereType<String>().join(' * '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: colors.mutedText),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${store.shotsForBean(bean.id!).length} shots',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            BeanStatusChip(status: bean.status),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

Future<void> showBeanFormSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const BeanFormSheet(),
  );
}

class BeanFormSheet extends StatefulWidget {
  const BeanFormSheet({super.key});

  @override
  State<BeanFormSheet> createState() => _BeanFormSheetState();
}

class _BeanFormSheetState extends State<BeanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _roaster = TextEditingController();
  final _origin = TextEditingController();
  final _process = TextEditingController();
  final _roastLevel = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _roaster.dispose();
    _origin.dispose();
    _process.dispose();
    _roastLevel.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final store = ShotScope.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Bean',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Bean name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _roaster,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Roaster'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _origin,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Origin'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _process,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Process'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _roastLevel,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Roast level'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Bean notes'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    await store.addBean(
                      name: _name.text,
                      roaster: _roaster.text,
                      origin: _origin.text,
                      process: _process.text,
                      roastLevel: _roastLevel.text,
                      notes: _notes.text,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Save Bean'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BeanDetailPage extends StatelessWidget {
  const BeanDetailPage({super.key, required this.beanId});

  final int beanId;

  @override
  Widget build(BuildContext context) {
    final store = ShotScope.of(context);
    final bean = store.beanById(beanId);
    if (bean == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bean')),
        body: const Center(child: Text('Bean not found.')),
      );
    }

    final shots = store.shotsForBean(beanId);
    final bestShot = store.bestShotForBean(beanId);

    return Scaffold(
      appBar: AppBar(
        title: Text(bean.name),
        actions: [
          IconButton(
            tooltip: bean.status == BeanStatus.active
                ? 'Mark Finished'
                : 'Already Finished',
            onPressed: bean.status == BeanStatus.active
                ? () => store.markBeanFinished(bean)
                : null,
            icon: const Icon(Icons.archive_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ShotCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bean.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      BeanStatusChip(status: bean.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    [
                      bean.roaster,
                      bean.origin,
                      bean.process,
                      bean.roastLevel,
                    ].whereType<String>().join(' * '),
                  ),
                  if (bean.notes?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    Text(bean.notes!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ShotFormPage(initialBeanId: beanId),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Shot'),
            ),
            const SizedBox(height: 16),
            if (bestShot != null)
              ShotCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best shot',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      metrics.formatShotLine(bestShot),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Shot history',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (shots.isEmpty)
              const EmptyState(
                icon: Icons.history_outlined,
                title: 'No shots for this bean',
                message: 'New shots for this bean will appear here.',
              )
            else
              ShotCard(
                child: Column(
                  children: [
                    for (final shot in shots)
                      ShotListTile(
                        shot: shot,
                        bean: bean,
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
      ),
    );
  }
}
