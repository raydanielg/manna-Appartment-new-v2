class PropertyModel {
  final String id;
  final String name;
  final String? address;
  final String? type;
  final String? status;
  final int? unitsCount;
  final int? occupiedUnits;
  final int? vacantUnits;
  final String? description;
  final String? imageUrl;
  final List<String> images;
  final double? monthlyRevenue;
  final DateTime? createdAt;

  PropertyModel({
    required this.id,
    required this.name,
    this.address,
    this.type,
    this.status,
    this.unitsCount,
    this.occupiedUnits,
    this.vacantUnits,
    this.description,
    this.imageUrl,
    this.images = const [],
    this.monthlyRevenue,
    this.createdAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    return PropertyModel(
      id: json['id'] ?? json['uuid'] ?? '',
      name: json['name'] ?? json['business_name'] ?? 'Property',
      address: json['address'] ?? json['location'],
      type: json['type'],
      status: json['status']?.toString(),
      unitsCount: json['units_count'] ?? json['total_units'],
      occupiedUnits: json['occupied_units'],
      vacantUnits: json['vacant_units'],
      description: json['description'],
      imageUrl: json['image_url'],
      images: rawImages is List ? rawImages.map((e) => e.toString()).toList() : [],
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'type': type,
        'description': description,
        'images': images,
      };

  int get vacancyRate {
    if (unitsCount == null || unitsCount == 0) return 0;
    final occupied = occupiedUnits ?? 0;
    return ((occupied / unitsCount!) * 100).round();
  }

  bool get isActive => status == 'active';
}
