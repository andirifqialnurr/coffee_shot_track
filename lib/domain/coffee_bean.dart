enum BeanStatus {
  active,
  finished;

  static BeanStatus fromStorage(String value) {
    return BeanStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BeanStatus.active,
    );
  }
}

class CoffeeBean {
  const CoffeeBean({
    this.id,
    required this.name,
    this.roaster,
    this.origin,
    this.process,
    this.roastLevel,
    this.roastDate,
    this.notes,
    this.imagePath,
    this.status = BeanStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String? roaster;
  final String? origin;
  final String? process;
  final String? roastLevel;
  final DateTime? roastDate;
  final String? notes;
  final String? imagePath;
  final BeanStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == BeanStatus.active;

  CoffeeBean copyWith({
    int? id,
    String? name,
    String? roaster,
    String? origin,
    String? process,
    String? roastLevel,
    DateTime? roastDate,
    String? notes,
    String? imagePath,
    BeanStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearRoastDate = false,
    bool clearImagePath = false,
  }) {
    return CoffeeBean(
      id: id ?? this.id,
      name: name ?? this.name,
      roaster: roaster ?? this.roaster,
      origin: origin ?? this.origin,
      process: process ?? this.process,
      roastLevel: roastLevel ?? this.roastLevel,
      roastDate: clearRoastDate ? null : roastDate ?? this.roastDate,
      notes: notes ?? this.notes,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'roaster': roaster,
      'origin': origin,
      'process': process,
      'roast_level': roastLevel,
      'roast_date': roastDate?.toIso8601String(),
      'notes': notes,
      'image_path': imagePath,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CoffeeBean.fromMap(Map<String, Object?> map) {
    return CoffeeBean(
      id: map['id'] as int?,
      name: map['name'] as String,
      roaster: map['roaster'] as String?,
      origin: map['origin'] as String?,
      process: map['process'] as String?,
      roastLevel: map['roast_level'] as String?,
      roastDate: _dateOrNull(map['roast_date']),
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      status: BeanStatus.fromStorage(map['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

DateTime? _dateOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  final text = value.toString();
  if (text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}
