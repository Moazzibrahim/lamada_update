class SupZoneData {
  final String success;
  final List<SupZone> supZone;

  SupZoneData({required this.success, required this.supZone});

  factory SupZoneData.fromJson(Map<String, dynamic> json) {
    return SupZoneData(
      success: json['success'],
      supZone: List<SupZone>.from(json['supZone'].map((x) => SupZone.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'supZone': List<dynamic>.from(supZone.map((x) => x.toJson())),
    };
  }
}

class SupZone {
  final int id;
  final String city;
  final int countryId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double deliveryFees;

  SupZone({
    required this.id,
    required this.city,
    required this.countryId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryFees,
  });

  factory SupZone.fromJson(Map<String, dynamic> json) {
    return SupZone(
      id: json['id'],
      city: json['city'],
      countryId: json['country_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deliveryFees: json['delivery_fees'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'country_id': countryId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_fees': deliveryFees,
    };
  }
}