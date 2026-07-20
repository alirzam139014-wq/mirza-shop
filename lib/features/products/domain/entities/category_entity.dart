/// موجودیت دسته‌بندی (Entity)
/// نماینده یک دسته‌بندی محصول در لایه Domain
class CategoryEntity {
  final int? id;
  final String name;
  final String? icon;
  final String color;
  final DateTime? createdAt;

  const CategoryEntity({
    this.id,
    required this.name,
    this.icon,
    this.color = '#00E5FF',
    this.createdAt,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
