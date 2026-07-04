class PropertyModel {
  final String id;
  final String name;
  final String? address;
  final String? type;
  final int? unitsCount;
  final int? occupiedUnits;
  final String? description;
  final String? imageUrl;
  final double? monthlyRevenue;
  final DateTime? createdAt;

  PropertyModel({
    required this.id,
    required this.name,
    this.address,
    this.type,
    this.unitsCount,
    this.occupiedUnits,
    this.description,
    this.imageUrl,
    this.monthlyRevenue,
    this.createdAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? json['uuid'] ?? '',
      name: json['name'] ?? json['business_name'] ?? 'Property',
      address: json['address'],
      type: json['type'],
      unitsCount: json['units_count'] ?? json['total_units'],
      occupiedUnits: json['occupied_units'],
      description: json['description'],
      imageUrl: json['image_url'],
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'type': type,
        'description': description,
      };

  int get vacancyRate {
    if (unitsCount == null || unitsCount == 0) return 0;
    final occupied = occupiedUnits ?? 0;
    return ((occupied / unitsCount!) * 100).round();
  }
}
