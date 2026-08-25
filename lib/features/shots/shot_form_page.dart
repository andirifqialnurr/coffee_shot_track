import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/shot_theme.dart';
import '../../data/shot_store.dart';
import '../../domain/espresso_shot.dart';
import '../../domain/shot_metrics.dart' as metrics;
import '../../shared/widgets/shot_ui.dart';
import '../beans/beans_page.dart';

class ShotFormPage extends StatefulWidget {
  const ShotFormPage({
    super.key,
    this.initialBeanId,
    this.initialShot,
  });

  final int? initialBeanId;
  final EspressoShot? initialShot;

  @override
  State<ShotFormPage> createState() => _ShotFormPageState();
}

class _ShotFormPageState extends State<ShotFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dose = TextEditingController();
  final _yield = TextEditingController();
  final _time = TextEditingController();
  final _grind = TextEditingController();
  final _temperature = TextEditingController();
  final _notes = TextEditingController();

  int? _beanId;
  int? _rating;
  bool _initialized = false;

  bool get _isEditing => widget.initialShot?.id != null;

  @override
  void initState() {
    super.initState();
    final shot = widget.initialShot;
    _beanId = widget.initialBeanId ?? shot?.beanId;
    if (shot != null) {
      _dose.text = _formatInputNumber(shot.doseG);
      _yield.text = _formatInputNumber(shot.yieldG);
      _time.text = shot.extractionSec?.toString() ?? '';
      _grind.text = shot.grindSetting ?? '';
      _temperature.text = shot.temperatureC == null
          ? ''
          : _formatInputNumber(shot.temperatureC!);
      _rating = shot.rating;
      _notes.text = shot.tastingNotes ?? '';
    }
    _dose.addListener(_ratioChanged);
    _yield.addListener(_ratioChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final store = Get.find<ShotController>();
    _beanId ??= store.activeBeans.isNotEmpty
        ? store.activeBeans.first.id
        : store.beans.isNotEmpty
            ? store.beans.first.id
            : null;
    _initialized = true;
  }

  @override
  void dispose() {
    _dose.dispose();
    _yield.dispose();
    _time.dispose();
    _grind.dispose();
    _temperature.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _ratioChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();
    final colors = Theme.of(context).extension<ShotColors>()!;

    return Obx(() {
      final beans = store.beans;
      final ratio = metrics.formatRatio(
        _parseDouble(_dose.text) ?? 0,
        _parseDouble(_yield.text) ?? 0,
      );

      if (beans.isEmpty) {
        return ShotPage(
          title: 'New Shot',
          subtitle: 'Add beans before logging espresso.',
          child: EmptyState(
            icon: Icons.coffee_outlined,
            title: 'No beans available',
            message: 'Every shot needs a bean record for comparison.',
            action: FilledButton.icon(
              onPressed: () => showBeanFormSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Bean'),
            ),
          ),
        );
      }

      return ShotPage(
        title: _isEditing ? 'Edit Shot' : 'New Shot',
        subtitle: 'Follow the brewing order and save the actual result.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _beanId,
                decoration: const InputDecoration(
                  labelText: 'Bean',
                  prefixIcon: Icon(Icons.coffee_outlined),
                ),
                items: [
                  for (final bean in beans)
                    DropdownMenuItem(
                      value: bean.id,
                      child: Text(bean.name),
                    ),
                ],
                onChanged: (value) => setState(() => _beanId = value),
                validator: (value) => value == null ? 'Choose a bean' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _dose,
                      label: 'Dose in',
                      suffix: 'g',
                      validator: (value) {
                        final parsed = _parseDouble(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Dose > 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      controller: _yield,
                      label: 'Yield out',
                      suffix: 'g',
                      validator: (value) {
                        final parsed = _parseDouble(value ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Yield >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _time,
                      label: 'Time',
                      suffix: 'sec',
                      allowDecimal: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumberField(
                      controller: _temperature,
                      label: 'Temp',
                      suffix: 'C',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _grind,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Grind setting',
                  prefixIcon: Icon(Icons.tune),
                  hintText: '4.2, 12 clicks, or custom',
                ),
              ),
              const SizedBox(height: 12),
              ShotCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brew ratio',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: colors.mutedText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ratio,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.calculate_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Rating',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final rating in [1, 2, 3, 4, 5])
                    ChoiceChip(
                      label: Text('$rating'),
                      avatar: const Icon(Icons.star, size: 16),
                      selected: _rating == rating,
                      onSelected: (selected) {
                        setState(() => _rating = selected ? rating : null);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Tasting notes',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _save(context),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_isEditing ? 'Update Shot' : 'Save Shot'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final store = Get.find<ShotController>();
    final now = DateTime.now();
    final source = widget.initialShot;
    final shot = EspressoShot(
      id: source?.id,
      beanId: _beanId!,
      doseG: _parseDouble(_dose.text)!,
      yieldG: _parseDouble(_yield.text)!,
      extractionSec: _parseInt(_time.text),
      temperatureC: _parseDouble(_temperature.text),
      grindSetting: _blankToNull(_grind.text),
      rating: _rating,
      tastingNotes: _blankToNull(_notes.text),
      isFavorite: source?.isFavorite ?? false,
      brewedAt: source?.brewedAt ?? now,
      createdAt: source?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      await store.saveShot(shot);
    } else {
      await store.addShot(shot);
    }

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Shot updated.' : 'Shot saved.')),
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _resetForm();
    }
  }

  void _resetForm() {
    _dose.clear();
    _yield.clear();
    _time.clear();
    _grind.clear();
    _temperature.clear();
    _notes.clear();
    setState(() => _rating = null);
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.allowDecimal = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final bool allowDecimal;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      validator: validator,
    );
  }
}

double? _parseDouble(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

int? _parseInt(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return int.tryParse(trimmed);
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _formatInputNumber(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
