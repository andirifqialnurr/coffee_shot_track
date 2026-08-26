import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_bean.dart';
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
  final _dose = TextEditingController();
  final _yield = TextEditingController();
  final _time = TextEditingController();
  final _grind = TextEditingController();
  final _temperature = TextEditingController();
  final _notes = TextEditingController();

  int? _beanId;
  int _rating = 0;
  bool _initialized = false;
  bool _touchedDose = false;
  bool _touchedYield = false;

  bool get _isEditing => widget.initialShot?.id != null;
  bool get _isPushedRoute => true;

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
      _temperature.text =
          shot.temperatureC == null ? '' : _formatInputNumber(shot.temperatureC!);
      _rating = shot.rating ?? 0;
      _notes.text = shot.tastingNotes ?? '';
    }
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

  double get _doseValue => _parseDouble(_dose.text) ?? 0;
  double get _yieldValue => _parseDouble(_yield.text) ?? 0;

  String? get _doseError {
    if (!_touchedDose) {
      return null;
    }
    if (_dose.text.trim().isEmpty) {
      return 'Dose wajib diisi';
    }
    if (_doseValue <= 0) {
      return 'Dose > 0';
    }
    return null;
  }

  String? get _yieldError {
    if (!_touchedYield) {
      return null;
    }
    if (_yield.text.trim().isEmpty) {
      return 'Yield wajib diisi';
    }
    if (_yieldValue < 0) {
      return 'Yield >= 0';
    }
    return null;
  }

  bool get _canSave =>
      _beanId != null &&
      _dose.text.trim().isNotEmpty &&
      _doseValue > 0 &&
      _yield.text.trim().isNotEmpty &&
      _yieldValue >= 0;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final beans = store.beans;
      final body = beans.isEmpty
          ? EmptyState(
              icon: Icons.eco_outlined,
              title: 'Tambahkan beans dulu',
              subtitle: 'Anda perlu menambahkan beans sebelum mencatat shot.',
              ctaLabel: 'Add Beans',
              onCta: () => showBeanFormSheet(context),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final compactGrid = constraints.maxWidth < 360;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                  children: [
                    const SectionLabel('Bean'),
                    _BeanSelector(
                      beans: beans,
                      selectedId: _beanId,
                      onChanged: (id) => setState(() => _beanId = id),
                    ),
                    const SectionLabel('Parameter Shot'),
                    ParamGrid(
                      compact: compactGrid,
                      children: [
                        NumberParamField(
                          label: 'Dose in',
                          unit: 'g',
                          controller: _dose,
                          icon: Icons.grain_rounded,
                          onChanged: (_) => setState(() {}),
                          onEditingComplete: () =>
                              setState(() => _touchedDose = true),
                          error: _doseError,
                        ),
                        NumberParamField(
                          label: 'Yield out',
                          unit: 'g',
                          controller: _yield,
                          icon: Icons.local_cafe_outlined,
                          onChanged: (_) => setState(() {}),
                          onEditingComplete: () =>
                              setState(() => _touchedYield = true),
                          error: _yieldError,
                        ),
                        NumberParamField(
                          label: 'Extraction time',
                          unit: 'sec',
                          controller: _time,
                          icon: Icons.timer_outlined,
                          isInt: true,
                        ),
                        TextParamField(
                          label: 'Grind setting',
                          controller: _grind,
                          icon: Icons.tune_rounded,
                          hint: '4.2 / 12 clicks',
                        ),
                        NumberParamField(
                          label: 'Temperature',
                          unit: 'C',
                          controller: _temperature,
                          icon: Icons.thermostat_outlined,
                          optional: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'BREW RATIO',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _doseValue > 0
                                ? formatSpacedRatio(_doseValue, _yieldValue)
                                : '1 : -',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: colors.primary),
                          ),
                          Text(
                            metrics.formatRatio(_doseValue, _yieldValue),
                            style: const TextStyle(fontSize: 0),
                          ),
                        ],
                      ),
                    ),
                    const SectionLabel('Rating'),
                    ShotCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Center(
                        child: StarRatingInput(
                          rating: _rating,
                          onChanged: (value) => setState(() => _rating = value),
                        ),
                      ),
                    ),
                    const SectionLabel('Tasting Notes'),
                    TextField(
                      controller: _notes,
                      maxLines: 4,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: const InputDecoration(
                        hintText:
                            'mis. Manis, jeruk, aftertaste bersih...',
                      ),
                    ),
                  ],
                );
              },
            );

      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          automaticallyImplyLeading: _isPushedRoute,
          title: Text(
            _isEditing
                ? 'Edit Shot'
                : widget.initialShot != null
                    ? 'Brew Again'
                    : 'New Shot',
          ),
        ),
        body: body,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: PrimaryButton(
              label: _isEditing ? 'Simpan Perubahan' : 'Save Shot',
              icon: Icons.check_rounded,
              onPressed: beans.isEmpty ? null : () => _save(context),
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
      );
    });
  }

  Future<void> _save(BuildContext context) async {
    setState(() {
      _touchedDose = true;
      _touchedYield = true;
    });
    if (!_canSave) {
      return;
    }

    final store = Get.find<ShotController>();
    final now = DateTime.now();
    final source = widget.initialShot;
    final shot = EspressoShot(
      id: source?.id,
      beanId: _beanId!,
      doseG: _doseValue,
      yieldG: _yieldValue,
      extractionSec: _parseInt(_time.text),
      temperatureC: _parseDouble(_temperature.text),
      grindSetting: _blankToNull(_grind.text),
      rating: _rating == 0 ? null : _rating,
      tastingNotes: _blankToNull(_notes.text),
      isFavorite: source?.isFavorite ?? false,
      brewedAt: _isEditing ? source!.brewedAt : now,
      createdAt: _isEditing ? source!.createdAt : now,
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
    setState(() {
      _rating = 0;
      _touchedDose = false;
      _touchedYield = false;
    });
  }
}

class _BeanSelector extends StatelessWidget {
  const _BeanSelector({
    required this.beans,
    required this.selectedId,
    required this.onChanged,
  });

  final List<CoffeeBean> beans;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary),
          dropdownColor: colors.surface,
          style: Theme.of(context).textTheme.titleSmall,
          items: [
            for (final bean in beans)
              DropdownMenuItem<int>(
                value: bean.id,
                child: Text(bean.name),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
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
