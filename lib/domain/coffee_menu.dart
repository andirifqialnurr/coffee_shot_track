enum MenuStatus {
  active,
  archived;

  static MenuStatus fromStorage(String value) {
    return MenuStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => MenuStatus.active,
    );
  }
}

class CoffeeMenu {
  const CoffeeMenu({
    this.id,
    required this.name,
    this.category,
    this.description,
    this.notes,
    this.imagePath,
    this.status = MenuStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String? category;
  final String? description;
  final String? notes;
  final String? imagePath;
  final MenuStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == MenuStatus.active;

  CoffeeMenu copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    String? notes,
    String? imagePath,
    MenuStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCategory = false,
    bool clearDescription = false,
    bool clearNotes = false,
    bool clearImagePath = false,
  }) {
    return CoffeeMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      category: clearCategory ? null : category ?? this.category,
      description: clearDescription ? null : description ?? this.description,
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
      'category': category,
      'description': description,
      'notes': notes,
      'image_path': imagePath,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CoffeeMenu.fromMap(Map<String, Object?> map) {
    return CoffeeMenu(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String?,
      description: map['description'] as String?,
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      status: MenuStatus.fromStorage(map['status'] as String? ?? 'active'),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
