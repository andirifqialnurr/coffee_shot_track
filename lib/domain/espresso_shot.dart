class EspressoShot {
  const EspressoShot({
    this.id,
    required this.beanId,
    required this.doseG,
    required this.yieldG,
    this.extractionSec,
    this.temperatureC,
    this.grindSetting,
    this.rating,
    this.tastingNotes,
    this.isFavorite = false,
    required this.brewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int beanId;
  final double doseG;
  final double yieldG;
  final int? extractionSec;
  final double? temperatureC;
  final String? grindSetting;
  final int? rating;
  final String? tastingNotes;
  final bool isFavorite;
  final DateTime brewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get ratio => doseG <= 0 ? 0 : yieldG / doseG;

  EspressoShot copyWith({
    int? id,
    int? beanId,
    double? doseG,
    double? yieldG,
    int? extractionSec,
    double? temperatureC,
    String? grindSetting,
    int? rating,
    String? tastingNotes,
    bool? isFavorite,
    DateTime? brewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearExtractionSec = false,
    bool clearTemperatureC = false,
    bool clearGrindSetting = false,
    bool clearRating = false,
    bool clearTastingNotes = false,
  }) {
    return EspressoShot(
      id: id ?? this.id,
      beanId: beanId ?? this.beanId,
      doseG: doseG ?? this.doseG,
      yieldG: yieldG ?? this.yieldG,
      extractionSec: clearExtractionSec
          ? null
          : extractionSec ?? this.extractionSec,
      temperatureC: clearTemperatureC ? null : temperatureC ?? this.temperatureC,
      grindSetting: clearGrindSetting ? null : grindSetting ?? this.grindSetting,
      rating: clearRating ? null : rating ?? this.rating,
      tastingNotes: clearTastingNotes ? null : tastingNotes ?? this.tastingNotes,
      isFavorite: isFavorite ?? this.isFavorite,
      brewedAt: brewedAt ?? this.brewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  EspressoShot duplicateForBrewAgain({DateTime? at}) {
    final now = at ?? DateTime.now();
    return EspressoShot(
      beanId: beanId,
      doseG: doseG,
      yieldG: yieldG,
      extractionSec: extractionSec,
      temperatureC: temperatureC,
      grindSetting: grindSetting,
      rating: null,
      tastingNotes: null,
      isFavorite: false,
      brewedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'bean_id': beanId,
      'dose_g': doseG,
      'yield_g': yieldG,
      'extraction_sec': extractionSec,
      'temperature_c': temperatureC,
      'grind_setting': grindSetting,
      'rating': rating,
      'tasting_notes': tastingNotes,
      'is_favorite': isFavorite ? 1 : 0,
      'brewed_at': brewedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory EspressoShot.fromMap(Map<String, Object?> map) {
    return EspressoShot(
      id: map['id'] as int?,
      beanId: map['bean_id'] as int,
      doseG: (map['dose_g'] as num).toDouble(),
      yieldG: (map['yield_g'] as num).toDouble(),
      extractionSec: map['extraction_sec'] as int?,
      temperatureC: (map['temperature_c'] as num?)?.toDouble(),
      grindSetting: map['grind_setting'] as String?,
      rating: map['rating'] as int?,
      tastingNotes: map['tasting_notes'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      brewedAt: DateTime.parse(map['brewed_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
