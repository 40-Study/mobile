/// Predefined cities for weather location selection
class CityModel {
  const CityModel({
    required this.name,
    required this.lat,
    required this.lon,
    this.country = 'VN',
  });

  final String name;
  final double lat;
  final double lon;
  final String country;

  /// Popular Vietnamese cities
  static const List<CityModel> vietnamCities = [
    CityModel(name: 'Hà Nội', lat: 21.0285, lon: 105.8542),
    CityModel(name: 'TP. Hồ Chí Minh', lat: 10.8231, lon: 106.6297),
    CityModel(name: 'Đà Nẵng', lat: 16.0544, lon: 108.2022),
    CityModel(name: 'Hải Phòng', lat: 20.8449, lon: 106.6881),
    CityModel(name: 'Cần Thơ', lat: 10.0452, lon: 105.7469),
    CityModel(name: 'Nha Trang', lat: 12.2388, lon: 109.1967),
    CityModel(name: 'Huế', lat: 16.4637, lon: 107.5909),
    CityModel(name: 'Vũng Tàu', lat: 10.4114, lon: 107.1362),
    CityModel(name: 'Đà Lạt', lat: 11.9404, lon: 108.4583),
    CityModel(name: 'Quy Nhơn', lat: 13.7830, lon: 109.2197),
    CityModel(name: 'Buôn Ma Thuột', lat: 12.6680, lon: 108.0378),
    CityModel(name: 'Vinh', lat: 18.6796, lon: 105.6813),
    CityModel(name: 'Thanh Hóa', lat: 19.8067, lon: 105.7852),
    CityModel(name: 'Thái Nguyên', lat: 21.5942, lon: 105.8482),
    CityModel(name: 'Nam Định', lat: 20.4388, lon: 106.1621),
    CityModel(name: 'Hạ Long', lat: 20.9517, lon: 107.0845),
    CityModel(name: 'Phan Thiết', lat: 10.9804, lon: 108.2615),
    CityModel(name: 'Cà Mau', lat: 9.1769, lon: 105.1524),
    CityModel(name: 'Rạch Giá', lat: 10.0125, lon: 105.0809),
    CityModel(name: 'Long Xuyên', lat: 10.3860, lon: 105.4352),
  ];

  /// Default city (Hanoi)
  static const CityModel defaultCity = CityModel(
    name: 'Hà Nội',
    lat: 21.0285,
    lon: 105.8542,
  );
}
