enum CafeStatus {
  active,
  archived;

  static CafeStatus fromStorage(String value) {
    return CafeStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => CafeStatus.active,
    );
  }
}

class Cafe {
  const Cafe({
    this.id,
    required this.name,
    this.area,
    this.address,
    this.notes,
    this.imagePath,
    this.status = CafeStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String? area;
  final String? address;
  final String? notes;
  final String? imagePath;
  final CafeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == CafeStatus.active;

  Cafe copyWith({
    int? id,
    String? name,
    String? area,
    String? address,
    String? notes,
    String? imagePath,
    CafeStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearArea = false,
    bool clearAddress = false,
    bool clearNotes = false,
    bool clearImagePath = false,
  }) {
    return Cafe(
      id: id ?? this.id,
      name: name ?? this.name,
      area: clearArea ? null : area ?? this.area,
      address: clearAddress ? null : address ?? this.address,
      notes: clearNotes ? null : notes ?? this.notes,
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
      'area': area,
      'address': address,
      'notes': notes,
      'image_path': imagePath,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Cafe.fromMap(Map<String, Object?> map) {
    return Cafe(
      id: map['id'] as int?,
      name: map['name'] as String,
      area: map['area'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      status: CafeStatus.fromStorage(map['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
