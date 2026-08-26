class CoffeeOrder {
  const CoffeeOrder({
    this.id,
    required this.menuId,
    required this.cafeId,
    this.beanId,
    this.legacyShotId,
    this.imagePath,
    this.price,
    this.rating,
    this.tastingNotes,
    this.doseG,
    this.yieldG,
    this.extractionSec,
    this.temperatureC,
    this.grindSetting,
    this.isFavorite = false,
    required this.orderedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int menuId;
  final int cafeId;
  final int? beanId;
  final int? legacyShotId;
  final String? imagePath;
  final double? price;
  final int? rating;
  final String? tastingNotes;
  final double? doseG;
  final double? yieldG;
  final int? extractionSec;
  final double? temperatureC;
  final String? grindSetting;
  final bool isFavorite;
  final DateTime orderedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  double? get ratio {
    final dose = doseG;
    final yield = yieldG;
    if (dose == null || yield == null || dose <= 0) {
      return null;
    }
    return yield / dose;
  }

  CoffeeOrder copyWith({
    int? id,
    int? menuId,
    int? cafeId,
    int? beanId,
    int? legacyShotId,
    String? imagePath,
    double? price,
    int? rating,
    String? tastingNotes,
    double? doseG,
    double? yieldG,
    int? extractionSec,
    double? temperatureC,
    String? grindSetting,
    bool? isFavorite,
    DateTime? orderedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearBeanId = false,
    bool clearLegacyShotId = false,
    bool clearImagePath = false,
    bool clearPrice = false,
    bool clearRating = false,
    bool clearTastingNotes = false,
    bool clearDoseG = false,
    bool clearYieldG = false,
    bool clearExtractionSec = false,
    bool clearTemperatureC = false,
    bool clearGrindSetting = false,
  }) {
    return CoffeeOrder(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      cafeId: cafeId ?? this.cafeId,
      beanId: clearBeanId ? null : beanId ?? this.beanId,
      legacyShotId:
          clearLegacyShotId ? null : legacyShotId ?? this.legacyShotId,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
      price: clearPrice ? null : price ?? this.price,
      rating: clearRating ? null : rating ?? this.rating,
      tastingNotes:
          clearTastingNotes ? null : tastingNotes ?? this.tastingNotes,
      doseG: clearDoseG ? null : doseG ?? this.doseG,
      yieldG: clearYieldG ? null : yieldG ?? this.yieldG,
      extractionSec:
          clearExtractionSec ? null : extractionSec ?? this.extractionSec,
      temperatureC:
          clearTemperatureC ? null : temperatureC ?? this.temperatureC,
      grindSetting:
          clearGrindSetting ? null : grindSetting ?? this.grindSetting,
      isFavorite: isFavorite ?? this.isFavorite,
      orderedAt: orderedAt ?? this.orderedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CoffeeOrder duplicateForOrderAgain({DateTime? at}) {
    final now = at ?? DateTime.now();
    return CoffeeOrder(
      menuId: menuId,
      cafeId: cafeId,
      beanId: beanId,
      imagePath: imagePath,
      doseG: doseG,
      yieldG: yieldG,
      extractionSec: extractionSec,
      temperatureC: temperatureC,
      grindSetting: grindSetting,
      isFavorite: false,
      orderedAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'menu_id': menuId,
      'cafe_id': cafeId,
      'bean_id': beanId,
      'legacy_shot_id': legacyShotId,
      'image_path': imagePath,
      'price': price,
      'rating': rating,
      'tasting_notes': tastingNotes,
      'dose_g': doseG,
      'yield_g': yieldG,
      'extraction_sec': extractionSec,
      'temperature_c': temperatureC,
      'grind_setting': grindSetting,
      'is_favorite': isFavorite ? 1 : 0,
      'ordered_at': orderedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CoffeeOrder.fromMap(Map<String, Object?> map) {
    return CoffeeOrder(
      id: map['id'] as int?,
      menuId: map['menu_id'] as int,
      cafeId: map['cafe_id'] as int,
      beanId: map['bean_id'] as int?,
      legacyShotId: map['legacy_shot_id'] as int?,
      imagePath: map['image_path'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      rating: map['rating'] as int?,
      tastingNotes: map['tasting_notes'] as String?,
      doseG: (map['dose_g'] as num?)?.toDouble(),
      yieldG: (map['yield_g'] as num?)?.toDouble(),
      extractionSec: map['extraction_sec'] as int?,
      temperatureC: (map['temperature_c'] as num?)?.toDouble(),
      grindSetting: map['grind_setting'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      orderedAt: DateTime.parse(map['ordered_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
