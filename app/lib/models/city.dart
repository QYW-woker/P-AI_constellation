/// 城市模型
class City {
  final String id;
  final String name;
  final String province;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  City({
    required this.id,
    required this.name,
    required this.province,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      province: json['province'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'province': province,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  /// 完整地址
  String get fullAddress => '$province $name';

  /// 是否是中国城市
  bool get isChina => country == 'China' || country == '中国';

  @override
  String toString() => '$name, $province';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
